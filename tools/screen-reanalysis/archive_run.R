#!/usr/bin/env Rscript
# Copy a finished reanalysis from work/<GSE>/ into reanalyses/<GSE>/, the
# tracked record that build_site.R turns into the website.
#
#   Rscript tools/screen-reanalysis/archive_run.R work/GSE123456 [--dest reanalyses]
#
# Needs in the work directory: meta.json, design.json, compare.json, REPORT.md,
# and results/<analysis>/ from run_barcs.R; prepare.R and extra design_*.json
# whose results are kept are copied too, for reproduce.R. Gene tables are trimmed to the
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
# What reproduce.R needs beyond design.json: the script that builds the count
# file and the paper's table, and every other design whose results are kept
# (sensitivity designs that write elsewhere are left out).
# Record the checksum of the count file BARCS read, so reproduce.R can tell a
# changed GEO file or prepare.R from a changed analysis.
design <- fromJSON(file.path(src, "design.json"), simplifyVector = FALSE)
counts_path <- file.path(src, design$counts_file)
if (is.null(design$counts_md5) && file.exists(counts_path)) {
  design$counts_md5 <- unname(tools::md5sum(counts_path))
  writeLines(toJSON(design, auto_unbox = TRUE, pretty = TRUE, null = "null"),
             file.path(dest, "design.json"))
}
if (file.exists(file.path(src, "prepare.R"))) file.copy(file.path(src, "prepare.R"), dest, overwrite = TRUE)
kept_runs <- basename(list.dirs(file.path(src, "results"), recursive = FALSE))
for (extra in list.files(src, pattern = "^design_.*\\.json$")) {
  analyses <- fromJSON(file.path(src, extra), simplifyVector = TRUE)$analyses$name
  if (length(analyses) && all(analyses %in% kept_runs)) file.copy(file.path(src, extra), dest, overwrite = TRUE)
}

for (run in list.dirs(file.path(src, "results"), recursive = FALSE)) {
  out <- file.path(dest, "results", basename(run))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  file.copy(file.path(run, "run_info.json"), out, overwrite = TRUE)
  genes <- utils::read.csv(file.path(run, "genes.csv"), stringsAsFactors = FALSE)
  genes <- genes[, intersect(c("gene", "n_guides", "estimate", "p_value", "fdr",
                               "empirical_p_value", "empirical_fdr"), names(genes))]
  genes$estimate <- signif(genes$estimate, 4)
  for (column in intersect(c("p_value", "fdr", "empirical_p_value", "empirical_fdr"), names(genes))) {
    genes[[column]] <- signif(genes[[column]], 3)
  }
  utils::write.csv(genes, gzfile(file.path(out, "genes.csv.gz")), row.names = FALSE)
}
message("Archived ", meta$gse, " to ", dest, ". Rebuild the site with build_site.R.")
