#!/usr/bin/env Rscript
# Record each paper's publication date from PubMed.
#
#   Rscript tools/screen-reanalysis/pub_dates.R [reanalyses]
#
# For every reanalyses/<GSE>/meta.json with a pmid, adds
#   published_date   first publication date, ISO (YYYY-MM-DD, or YYYY-MM /
#                    YYYY when PubMed has no day): the online (epub) date when
#                    PubMed has one, otherwise the issue date
#   published_issue  the issue date as PubMed prints it (e.g. "2026 Jan 20")
# and fills a published_date column in reanalyses/excluded.tsv. Existing
# values are kept, so the script only queries PubMed for new records.

suppressPackageStartupMessages(library(jsonlite))
args <- commandArgs(trailingOnly = TRUE)
root <- if (length(args)) args[[1]] else "reanalyses"
`%||%` <- function(a, b) if (is.null(a) || !length(a) || identical(a, "")) b else a

iso_date <- function(text) {
  if (is.null(text) || !nzchar(text)) return(NA_character_)
  parts <- strsplit(trimws(text), "[ /-]+")[[1]]
  year <- parts[1]
  if (!grepl("^[0-9]{4}$", year)) return(NA_character_)
  if (length(parts) < 2L) return(year)
  month <- match(substr(parts[2], 1L, 3L), month.abb)
  if (is.na(month)) month <- suppressWarnings(as.integer(parts[2]))
  if (is.na(month)) return(year)
  if (length(parts) < 3L || !grepl("^[0-9]{1,2}$", parts[3])) return(sprintf("%s-%02d", year, month))
  sprintf("%s-%02d-%02d", year, month, as.integer(parts[3]))
}

summaries <- function(pmids) {
  pmids <- unique(pmids[!is.na(pmids) & nzchar(pmids)])
  out <- list()
  for (chunk in split(pmids, ceiling(seq_along(pmids) / 150))) {
    url <- sprintf("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&retmode=json&id=%s",
                   paste(chunk, collapse = ","))
    result <- fromJSON(url, simplifyVector = FALSE)$result
    for (id in chunk) out[[id]] <- result[[id]]
    Sys.sleep(0.4)
  }
  out
}

dates_for <- function(record) {
  if (is.null(record)) return(list(date = NA_character_, issue = NA_character_))
  online <- iso_date(record$epubdate)
  issue <- iso_date(record$pubdate)
  first <- if (!is.na(online) && (is.na(issue) || online <= issue)) online else issue
  list(date = first, issue = record$pubdate %||% NA_character_)
}

meta_files <- Sys.glob(file.path(root, "*", "meta.json"))
metas <- lapply(meta_files, fromJSON, simplifyVector = TRUE)
need <- vapply(metas, function(m) is.null(m$published_date) && !is.null(m$pmid), logical(1))

excluded_path <- file.path(root, "excluded.tsv")
excluded <- if (file.exists(excluded_path)) {
  utils::read.delim(excluded_path, colClasses = "character", check.names = FALSE, quote = "")
} else NULL
if (!is.null(excluded) && !"published_date" %in% names(excluded)) excluded$published_date <- NA_character_
excluded_need <- if (is.null(excluded)) character() else
  excluded$pmid[is.na(excluded$published_date) | !nzchar(excluded$published_date)]

pmids <- c(vapply(metas[need], function(m) as.character(m$pmid), character(1)), excluded_need)
info <- if (length(pmids)) summaries(pmids) else list()

for (i in which(need)) {
  d <- dates_for(info[[as.character(metas[[i]]$pmid)]])
  meta <- fromJSON(meta_files[i], simplifyVector = FALSE)
  meta$published_date <- d$date
  meta$published_issue <- d$issue
  writeLines(toJSON(meta, auto_unbox = TRUE, pretty = TRUE, null = "null"), meta_files[i])
  message(sprintf("%s  PMID %s  %s", basename(dirname(meta_files[i])), meta$pmid, d$date))
}
if (!is.null(excluded)) {
  missing <- is.na(excluded$published_date) | !nzchar(excluded$published_date)
  excluded$published_date[missing] <- vapply(excluded$pmid[missing], function(id)
    dates_for(info[[id]])$date, character(1))
  utils::write.table(excluded, excluded_path, sep = "\t", quote = FALSE, row.names = FALSE, na = "")
  message(sprintf("excluded.tsv: %d dates filled", sum(missing)))
}
