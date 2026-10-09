#!/usr/bin/env Rscript
# Reproduce recorded reanalyses from scratch and check them against the
# record in reanalyses/<GSE>/.
#
#   Rscript tools/screen-reanalysis/reproduce.R GSE123456 [GSE...] [--all]
#       [--src reanalyses] [--work work/reproduce] [--keep]
#
# For each series it
#   1. copies the record's design, compare and prepare files to <work>/<GSE>/;
#   2. downloads the GEO inputs with fetch_geo.R, using the record's
#      "fetch" options from design.json (sample_files, max_mb);
#   3. runs reanalyses/<GSE>/prepare.R <work>/<GSE> when the record has one
#      (count tables that need merging, summing or cleaning, and the paper's
#      published table for the comparison);
#   4. checks the count file against design.json "counts_md5";
#   5. runs run_barcs.R on design.json and every recorded design_*.json, and
#      compare_results.R on compare.json;
#   6. compares every archived results/<analysis>/genes.csv.gz and the call
#      counts in run_info.json with the new run.
#
# Prints one line per series and exits non-zero if any series differs. Needs
# BARCS installed (the version in the record's run_info.json for an exact
# match), jsonlite, and readxl for records whose prepare.R reads Excel files.

suppressPackageStartupMessages(library(jsonlite))
`%||%` <- function(a, b) if (is.null(a) || !length(a)) b else a

args <- commandArgs(trailingOnly = TRUE)
option <- function(name, default) {
  hit <- match(paste0("--", name), args)
  if (is.na(hit)) default else args[[hit + 1L]]
}
src <- option("src", "reanalyses")
work <- option("work", file.path("work", "reproduce"))
keep <- "--keep" %in% args
series <- grep("^GSE[0-9]+$", args, value = TRUE)
if ("--all" %in% args) {
  series <- basename(list.dirs(src, recursive = FALSE))
  series <- series[grepl("^GSE[0-9]+$", series)]
}
if (!length(series)) {
  stop("Usage: reproduce.R GSE123456 [GSE...] | --all [--src reanalyses] [--work work/reproduce]",
       call. = FALSE)
}
tools_dir <- file.path("tools", "screen-reanalysis")
rscript <- file.path(R.home("bin"), "Rscript")

run <- function(script, ...) {
  status <- system2(rscript, c(script, ...), stdout = TRUE, stderr = TRUE)
  code <- attr(status, "status") %||% 0L
  list(ok = identical(as.integer(code), 0L), log = status)
}


# Archived gene tables are trimmed and rounded by archive_run.R; apply the same
# to the new run before comparing.
trim_genes <- function(genes) {
  keep_cols <- intersect(c("gene", "n_guides", "estimate", "p_value", "fdr",
                           "empirical_p_value", "empirical_fdr"), names(genes))
  genes <- genes[, keep_cols, drop = FALSE]
  genes$estimate <- signif(genes$estimate, 4)
  for (column in intersect(c("p_value", "fdr", "empirical_p_value", "empirical_fdr"), names(genes))) {
    genes[[column]] <- signif(genes[[column]], 3)
  }
  genes
}

same_table <- function(old, new) {
  if (!identical(sort(names(old)), sort(names(new)))) return("columns differ")
  new <- new[, names(old), drop = FALSE]
  old <- old[order(old$gene), , drop = FALSE]
  new <- new[order(new$gene), , drop = FALSE]
  if (nrow(old) != nrow(new) || !identical(old$gene, new$gene)) return("genes differ")
  for (column in setdiff(names(old), "gene")) {
    a <- old[[column]]; b <- new[[column]]
    if (!identical(is.na(a), is.na(b))) return(paste0(column, ": missing values differ"))
    ok <- is.na(a) | abs(a - b) <= 1e-12 + 1e-6 * abs(a)
    if (!all(ok)) return(sprintf("%s: %d values differ", column, sum(!ok)))
  }
  ""
}

call_fields <- c("libraries", "residual_df", "guides", "genes", "genes_fdr_0_05",
                 "genes_fdr_0_10", "genes_empirical_fdr_0_10", "control_guides")

reproduce_one <- function(gse) {
  record <- file.path(src, gse)
  out <- file.path(work, gse)
  if (!keep) unlink(out, recursive = TRUE)
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  design_files <- list.files(record, pattern = "^design.*\\.json$")
  file.copy(file.path(record, c(design_files, "compare.json")), out, overwrite = TRUE)
  design <- fromJSON(file.path(record, "design.json"), simplifyVector = TRUE)

  fetch <- design$fetch %||% list()
  fetch_args <- c(gse, "--dir", work)
  if (isTRUE(fetch$sample_files)) fetch_args <- c(fetch_args, "--sample-files")
  if (!is.null(fetch$max_mb)) fetch_args <- c(fetch_args, "--max-mb", fetch$max_mb)
  step <- run(file.path(tools_dir, "fetch_geo.R"), fetch_args)
  if (!step$ok) return(c(gse, "FAIL", "fetch_geo.R failed"))

  prepare <- file.path(record, "prepare.R")
  if (file.exists(prepare)) {
    step <- run(prepare, out)
    if (!step$ok) {
      return(c(gse, "FAIL", paste("prepare.R failed:", utils::tail(step$log, 1))))
    }
  }

  counts <- file.path(out, design$counts_file)
  if (!file.exists(counts)) return(c(gse, "FAIL", paste("missing", design$counts_file)))
  if (!is.null(design$counts_md5) && !identical(unname(tools::md5sum(counts)), design$counts_md5)) {
    return(c(gse, "FAIL", paste("count file checksum differs:", design$counts_file)))
  }

  for (file in design_files) {
    step <- run(file.path(tools_dir, "run_barcs.R"), file.path(out, file))
    if (!step$ok) return(c(gse, "FAIL", paste("run_barcs.R failed on", file)))
  }
  step <- run(file.path(tools_dir, "compare_results.R"), file.path(out, "compare.json"))
  if (!step$ok) return(c(gse, "FAIL", "compare_results.R failed"))

  problems <- character()
  for (run_dir in list.dirs(file.path(record, "results"), recursive = FALSE)) {
    name <- basename(run_dir)
    new_dir <- file.path(out, "results", name)
    if (!dir.exists(new_dir)) {
      problems <- c(problems, paste(name, "not produced"))
      next
    }
    old <- utils::read.csv(file.path(run_dir, "genes.csv.gz"), stringsAsFactors = FALSE)
    new <- trim_genes(utils::read.csv(file.path(new_dir, "genes.csv"), stringsAsFactors = FALSE))
    diff <- same_table(old, new)
    if (nzchar(diff)) problems <- c(problems, paste0(name, ": ", diff))
    old_info <- fromJSON(file.path(run_dir, "run_info.json"))
    new_info <- fromJSON(file.path(new_dir, "run_info.json"))
    for (field in call_fields) {
      if (!identical(old_info[[field]], new_info[[field]])) {
        problems <- c(problems, sprintf("%s: %s %s -> %s", name, field,
                                        format(old_info[[field]] %||% "none"),
                                        format(new_info[[field]] %||% "none")))
      }
    }
  }
  if (length(problems)) return(c(gse, "DIFFERS", paste(problems, collapse = "; ")))
  c(gse, "OK", sprintf("%d analyses match", length(list.dirs(file.path(record, "results"), recursive = FALSE))))
}

results <- t(vapply(series, function(gse) {
  message("== ", gse)
  result <- tryCatch(reproduce_one(gse), error = function(e) c(gse, "FAIL", conditionMessage(e)))
  message("   ", result[[2]], ": ", result[[3]])
  result
}, character(3)))
cat(sprintf("%-10s %-8s %s\n", results[, 1], results[, 2], results[, 3]), sep = "")
cat(sprintf("\n%d of %d series reproduced.\n", sum(results[, 2] == "OK"), nrow(results)))
quit(status = if (all(results[, 2] == "OK")) 0L else 1L)
