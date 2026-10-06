#!/usr/bin/env Rscript
# Describe a candidate count file so the agent can decide whether it holds raw
# guide counts and how its columns map to samples.
#
#   Rscript tools/screen-reanalysis/inspect_counts.R <file> [--sheet NAME]
#
# Reports: shape, header, numeric columns with totals and integer check,
# likely guide/gene columns, control-like gene labels, and the correlation of
# log counts between numeric columns (replicates of one condition usually
# correlate most strongly with each other).

args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: inspect_counts.R <file> [--sheet NAME]", call. = FALSE)
path <- args[[1]]
sheet_hit <- match("--sheet", args)
sheet <- if (is.na(sheet_hit)) NULL else args[[sheet_hit + 1L]]

read_any <- function(path, sheet = NULL) {
  if (grepl("\\.xlsx?$", path, ignore.case = TRUE)) {
    if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl to read Excel files.")
    message("Sheets: ", paste(readxl::excel_sheets(path), collapse = ", "))
    return(as.data.frame(readxl::read_excel(path, sheet = sheet %||% 1L)))
  }
  connection <- if (grepl("\\.gz$", path)) gzfile(path) else path
  first <- readLines(connection, n = 1L)
  sep <- if (grepl("\t", first)) "\t" else ","
  utils::read.delim(if (grepl("\\.gz$", path)) gzfile(path) else path,
                    sep = sep, check.names = FALSE, stringsAsFactors = FALSE)
}
`%||%` <- function(a, b) if (is.null(a)) b else a

x <- read_any(path, sheet)
cat(sprintf("File: %s\nRows: %d  Columns: %d\n\n", path, nrow(x), ncol(x)))
cat("Header and first rows:\n")
print(utils::head(x, 4L), row.names = FALSE)

numeric <- vapply(x, is.numeric, logical(1))
text <- names(x)[!numeric]
cat("\nText columns:", paste(text, collapse = ", "), "\n")
for (column in text) {
  values <- x[[column]]
  cat(sprintf("  %-20s %d unique values; e.g. %s\n", column, length(unique(values)),
              paste(utils::head(unique(values), 3L), collapse = ", ")))
}

if (any(numeric)) {
  counts <- as.matrix(x[, numeric, drop = FALSE])
  cat("\nNumeric columns (candidate samples):\n")
  summary_table <- data.frame(
    column = colnames(counts),
    total = colSums(counts, na.rm = TRUE),
    zero_fraction = round(colMeans(counts == 0, na.rm = TRUE), 3),
    integer_valued = apply(counts, 2, function(v) all(abs(v - round(v)) < 1e-8, na.rm = TRUE)),
    row.names = NULL
  )
  print(summary_table, row.names = FALSE)
  if (!all(summary_table$integer_valued)) {
    cat("\nNOTE: some columns are not integer-valued. BARCS needs raw read counts;",
        "normalized values must not be used as counts.\n")
  }
  if (ncol(counts) >= 2L) {
    cat("\nSpearman correlation of log2(count + 1) between columns:\n")
    print(round(stats::cor(log2(counts + 1), method = "spearman"), 2))
  }
}

for (column in text) {
  values <- unique(x[[column]])
  controls <- grep("non.?target|^ntc|control|safe.?harbor|^nt[_-]|intergenic|luciferase|lacz|egfp",
                   values, ignore.case = TRUE, value = TRUE)
  if (length(controls)) {
    cat(sprintf("\nControl-like labels in %s (%d): %s\n", column, length(controls),
                paste(utils::head(controls, 10L), collapse = ", ")))
  }
}
