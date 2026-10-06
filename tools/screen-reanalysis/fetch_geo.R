#!/usr/bin/env Rscript
# Download a GEO series' supplementary files and sample metadata.
#
#   Rscript tools/screen-reanalysis/fetch_geo.R GSE123456 [--dir work]
#       [--max-mb 300] [--sample-files]
#
# Writes into <dir>/<GSE>/:
#   series.json      title, summary, overall design, PubMed IDs
#   samples.tsv      one row per GSM: title, source, characteristics,
#                    description, supplementary file URLs
#   suppl/           the series-level supplementary files (size-capped)
#   sample_suppl/    per-sample supplementary files, with --sample-files
#
# Nothing here decides the design; it only gathers what the agent reads.

suppressPackageStartupMessages(library(jsonlite))

`%||%` <- function(a, b) if (is.null(a) || !length(a) || all(!nzchar(a))) b else a

args <- commandArgs(trailingOnly = TRUE)
if (!length(args) || !grepl("^GSE[0-9]+$", args[[1]])) {
  stop("Usage: fetch_geo.R GSE123456 [--dir work] [--max-mb 300] [--sample-files]",
       call. = FALSE)
}
gse <- args[[1]]
option <- function(name, default) {
  hit <- match(paste0("--", name), args)
  if (is.na(hit)) default else args[[hit + 1L]]
}
work <- option("dir", "work")
max_mb <- as.numeric(option("max-mb", "300"))
sample_files <- "--sample-files" %in% args

stub <- sub("[0-9]{1,3}$", "nnn", gse)
base <- sprintf("https://ftp.ncbi.nlm.nih.gov/geo/series/%s/%s", stub, gse)
out <- file.path(work, gse)
dir.create(file.path(out, "suppl"), recursive = TRUE, showWarnings = FALSE)

# Directory listings are plain HTML; pull out file links and sizes.
list_directory <- function(url) {
  page <- tryCatch(readLines(url, warn = FALSE), error = function(e) character())
  hits <- regmatches(page, regexpr('href="[^"?/][^"]*"', page))
  files <- sub('^href="', "", sub('"$', "", hits))
  # Keep plain file names in this directory; drop page-chrome links.
  unique(files[!grepl("/", files, fixed = TRUE) & grepl("\\.", files)])
}

download <- function(url, dest) {
  for (attempt in 1:3) {
    status <- tryCatch(
      utils::download.file(url, dest, mode = "wb", quiet = TRUE),
      error = function(e) 1L
    )
    if (identical(status, 0L) && file.exists(dest) && file.size(dest) > 0) {
      return(TRUE)
    }
    Sys.sleep(2 * attempt)
  }
  FALSE
}

remote_mb <- function(url) {
  header <- tryCatch(
    curlGetHeaders(url),
    error = function(e) character()
  )
  length_line <- grep("^content-length:", header, ignore.case = TRUE, value = TRUE)
  if (!length(length_line)) return(NA_real_)
  as.numeric(sub("^[^:]+:\\s*", "", tail(length_line, 1))) / 1e6
}

# ---- series matrix: metadata for every sample --------------------------------
matrix_files <- list_directory(paste0(base, "/matrix/"))
matrix_files <- grep("series_matrix\\.txt\\.gz$", matrix_files, value = TRUE)
if (!length(matrix_files)) stop("No series matrix found for ", gse, call. = FALSE)

samples <- list()
series <- list(gse = gse, title = NULL, summary = NULL, overall_design = NULL,
               pubmed_ids = character())
for (mf in matrix_files) {
  local <- file.path(out, mf)
  if (!download(paste0(base, "/matrix/", mf), local)) {
    stop("Could not download ", mf, call. = FALSE)
  }
  lines <- readLines(gzfile(local), warn = FALSE)
  lines <- lines[startsWith(lines, "!")]
  field <- function(key) {
    rows <- lines[startsWith(lines, paste0(key, "\t"))]
    lapply(strsplit(rows, "\t", fixed = TRUE), function(x) gsub('^"|"$', "", x[-1]))
  }
  series$title <- series$title %||% unlist(field("!Series_title"))[1]
  series$summary <- series$summary %||% paste(unlist(field("!Series_summary")), collapse = " ")
  series$overall_design <- series$overall_design %||%
    paste(unlist(field("!Series_overall_design")), collapse = " ")
  series$pubmed_ids <- unique(c(series$pubmed_ids, unlist(field("!Series_pubmed_id"))))

  gsm <- unlist(field("!Sample_geo_accession"))
  collapse_rows <- function(key) {
    rows <- field(key)
    if (!length(rows)) return(rep("", length(gsm)))
    apply(do.call(rbind, rows), 2, function(x) paste(x[nzchar(x)], collapse = " | "))
  }
  samples[[mf]] <- data.frame(
    gsm = gsm,
    title = collapse_rows("!Sample_title"),
    source = collapse_rows("!Sample_source_name_ch1"),
    characteristics = collapse_rows("!Sample_characteristics_ch1"),
    description = collapse_rows("!Sample_description"),
    supplementary_files = collapse_rows("!Sample_supplementary_file_1"),
    stringsAsFactors = FALSE
  )
}
samples <- do.call(rbind, samples)
rownames(samples) <- NULL
utils::write.table(samples, file.path(out, "samples.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
writeLines(toJSON(series, auto_unbox = TRUE, pretty = TRUE), file.path(out, "series.json"))
message(gse, ": ", nrow(samples), " samples; metadata written.")

# ---- series-level supplementary files ---------------------------------------
fetched <- character()
for (file in list_directory(paste0(base, "/suppl/"))) {
  url <- paste0(base, "/suppl/", file)
  size <- remote_mb(url)
  if (grepl("_RAW\\.tar$", file)) {
    message("  skip ", file, " (per-sample archive; use --sample-files instead)")
    next
  }
  if (is.finite(size) && size > max_mb) {
    message(sprintf("  skip %s (%.0f MB > %.0f MB cap)", file, size, max_mb))
    next
  }
  if (download(url, file.path(out, "suppl", file))) {
    fetched <- c(fetched, file)
    message("  got  ", file)
  }
}

# ---- optional per-sample files ---------------------------------------------
if (sample_files) {
  dir.create(file.path(out, "sample_suppl"), showWarnings = FALSE)
  urls <- unlist(strsplit(samples$supplementary_files, " | ", fixed = TRUE))
  urls <- sub("^ftp://", "https://", urls[nzchar(urls) & urls != "NONE"])
  for (url in urls) {
    if (download(url, file.path(out, "sample_suppl", basename(url)))) {
      message("  got  ", basename(url))
    }
  }
}

if (!length(fetched) && !sample_files) {
  message("No series-level supplementary files were fetched. ",
          "Check samples.tsv and rerun with --sample-files if counts are per sample.")
}
