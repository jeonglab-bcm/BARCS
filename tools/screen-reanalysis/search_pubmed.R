#!/usr/bin/env Rscript
# Find recent pooled CRISPR screen papers in PubMed that link to a GEO series
# with supplementary files, and list the candidate series.
#
#   Rscript tools/screen-reanalysis/search_pubmed.R [--days 365] [--max 40]
#       [--query '<extra PubMed terms>'] [--out screens.tsv]
#
# Uses NCBI E-utilities (esearch -> esummary -> elink -> esummary). Set
# NCBI_API_KEY to raise the rate limit from 3 to 10 requests per second.

suppressPackageStartupMessages(library(jsonlite))

`%||%` <- function(a, b) if (is.null(a) || !length(a)) b else a

args <- commandArgs(trailingOnly = TRUE)
option <- function(name, default) {
  hit <- match(paste0("--", name), args)
  if (is.na(hit)) default else args[[hit + 1L]]
}
days <- as.integer(option("days", "365"))
max_papers <- as.integer(option("max", "40"))
extra <- option("query", "")
out_path <- option("out", "screens.tsv")

eutils <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
api_key <- Sys.getenv("NCBI_API_KEY")
pause <- if (nzchar(api_key)) 0.12 else 0.4

call_eutils <- function(tool, params) {
  if (nzchar(api_key)) params$api_key <- api_key
  params$retmode <- "json"
  query <- paste(
    names(params),
    vapply(params, function(x) utils::URLencode(as.character(x), reserved = TRUE), ""),
    sep = "=", collapse = "&"
  )
  Sys.sleep(pause)
  for (attempt in 1:3) {
    result <- tryCatch(
      fromJSON(paste0(eutils, tool, ".fcgi?", query), simplifyVector = FALSE),
      error = function(e) NULL
    )
    if (!is.null(result)) return(result)
    Sys.sleep(2 * attempt)
  }
  stop("E-utilities request failed: ", tool, call. = FALSE)
}

term <- paste(
  '("CRISPR screen"[Title/Abstract] OR "CRISPR screening"[Title/Abstract]',
  'OR "pooled screen"[Title/Abstract] OR "genome-wide screen"[Title/Abstract])',
  "AND pubmed_gds[filter]",
  if (nzchar(extra)) paste("AND", extra) else ""
)
search <- call_eutils("esearch", list(
  db = "pubmed", term = term, sort = "pub_date",
  datetype = "pdat", reldate = days, retmax = max_papers
))
pmids <- unlist(search$esearchresult$idlist)
if (!length(pmids)) {
  message("No PubMed records matched in the last ", days, " days.")
  quit(status = 0)
}
message(length(pmids), " PubMed records with linked GEO data.")

# esummary takes ids in the URL; batch them so long searches stay under the
# URL length limit.
papers <- list()
for (batch in split(pmids, ceiling(seq_along(pmids) / 100))) {
  papers <- c(papers, call_eutils("esummary", list(db = "pubmed", id = paste(batch, collapse = ",")))$result)
}

rows <- list()
for (pmid in pmids) {
  paper <- papers[[pmid]]
  links <- call_eutils("elink", list(dbfrom = "pubmed", db = "gds", id = pmid))
  linksets <- links$linksets[[1]]$linksetdbs
  gds_ids <- if (length(linksets)) unlist(linksets[[1]]$links) else character()
  if (!length(gds_ids)) next
  series <- call_eutils("esummary", list(db = "gds", id = paste(gds_ids, collapse = ",")))$result
  for (uid in gds_ids) {
    s <- series[[uid]]
    if (is.null(s) || !identical(s$entrytype, "GSE")) next
    rows[[length(rows) + 1L]] <- data.frame(
      pmid = pmid,
      pub_date = paper$pubdate %||% NA,
      journal = paper$source %||% NA,
      paper_title = paper$title %||% NA,
      gse = s$accession,
      gse_title = s$title,
      gds_type = s$gdstype,
      n_samples = as.integer(s$n_samples),
      supp_files = s$suppfile %||% "",
      looks_like_screen = grepl(
        "crispr|sgrna|guide|screen|knockout library|brunello|gecko|tkov|cas13|crispri|crispra",
        tolower(paste(s$title, s$summary)), perl = TRUE
      ),
      stringsAsFactors = FALSE
    )
  }
}
if (!length(rows)) {
  message("No linked GEO series found.")
  quit(status = 0)
}
table <- do.call(rbind, rows)
table <- table[nzchar(table$supp_files), , drop = FALSE]
# GEO files pooled screens under "Other"; RNA-seq companions of a screen paper
# share its keywords but not that type. Rank on both, newest first.
table$screen_score <- 2L * (table$gds_type == "Other") + table$looks_like_screen
table <- table[order(-table$screen_score, -as.numeric(table$pmid)), ]
utils::write.table(table, out_path, sep = "\t", quote = FALSE, row.names = FALSE)
message("Wrote ", nrow(table), " candidate series to ", out_path)
shown <- table[table$screen_score >= 2L, , drop = FALSE]
shown$gse_title <- substr(shown$gse_title, 1L, 70L)
print(shown[, c("pmid", "pub_date", "gse", "n_samples", "supp_files", "screen_score", "gse_title")],
      row.names = FALSE, right = FALSE)
