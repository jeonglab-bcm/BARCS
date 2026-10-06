#!/usr/bin/env Rscript
# Copy a finished reanalysis from work/<GSE>/ into reanalyses/<GSE>/, the
# tracked record that build_site.R turns into the website.
#
#   Rscript tools/screen-reanalysis/archive_run.R work/GSE123456 [--dest reanalyses]
#
# Needs in the work directory: meta.json, design.json, compare.json, REPORT.md,
# and results/<analysis>/ from run_barcs.R. Gene tables are trimmed to the
# columns the site uses and gzipped; guide tables and raw counts stay behind.

suppressPackageStartupMessages(library(jsonlite))

args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: archive_run.R work/<GSE> [--dest reanalyses]", call. = FALSE)
src <- sub("/$", "", args[[1]])
hit <- match("--dest", args)
dest_root <- if (is.na(hit)) "reanalyses" else args[[hit + 1L]]

needed <- c("meta.json", "design.json", "compare.json", "REPORT.md")
absent <- needed[!file.exists(file.path(src, needed))]
if (length(absent)) stop("Missing in ", src, ": ", paste(absent, collapse = ", "), call. = FALSE)
meta <- fromJSON(file.path(src, "meta.json"))
for (field in c("gse", "pmid", "title", "journal", "published", "contrast", "verdict", "agreement")) {
  if (is.null(meta[[field]])) stop("meta.json is missing '", field, "'.", call. = FALSE)
}
if (!meta$agreement %in% c("agree", "partial", "differ")) {
  stop("meta.json 'agreement' must be agree, partial, or differ.", call. = FALSE)
}

dest <- file.path(dest_root, meta$gse)
dir.create(dest, recursive = TRUE, showWarnings = FALSE)
invisible(file.copy(file.path(src, c(needed, "comparison.md")), dest, overwrite = TRUE))

for (run in list.dirs(file.path(src, "results"), recursive = FALSE)) {
  out <- file.path(dest, "results", basename(run))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  file.copy(file.path(run, "run_info.json"), out, overwrite = TRUE)
  genes <- utils::read.csv(file.path(run, "genes.csv"), stringsAsFactors = FALSE)
  genes <- genes[, intersect(c("gene", "n_guides", "estimate", "p_value", "fdr"), names(genes))]
  genes$estimate <- signif(genes$estimate, 4)
  genes$p_value <- signif(genes$p_value, 3)
  genes$fdr <- signif(genes$fdr, 3)
  utils::write.csv(genes, gzfile(file.path(out, "genes.csv.gz")), row.names = FALSE)
}
message("Archived ", meta$gse, " to ", dest, ". Rebuild the site with build_site.R.")
