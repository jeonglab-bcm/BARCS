#!/usr/bin/env Rscript
# GSE219136: builds raw_counts.tsv from GSE219136_NF2-CRISPR-screen.txt.gz.
# The deposited table has two header lines: the first labels column blocks
# ("raw counts", "normalized counts", "ratios", "difference in log2FC"); the
# second names the columns, repeating the sample names in every block. This
# keeps sgRNA, gene and the six raw-count columns (columns 4-9: WT_T0, KO_T0,
# WT_T7_R1, WT_T7_R2, KO_T7_R1, KO_T7_R2), in the deposited row order, and
# drops the final "total" row (column sums, no gene).
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
src <- file.path(workdir, "suppl", "GSE219136_NF2-CRISPR-screen.txt.gz")
blocks <- strsplit(readLines(src, n = 1), "\t")[[1]]
stopifnot(blocks[4] == "raw counts")
x <- utils::read.delim(src, skip = 1, check.names = FALSE, stringsAsFactors = FALSE,
                       colClasses = "character")
raw <- c("WT_T0", "KO_T0", "WT_T7_R1", "WT_T7_R2", "KO_T7_R1", "KO_T7_R2")
stopifnot(identical(names(x)[4:9], raw))
stopifnot(sum(x[[1]] == "total") == 1, x[[1]][nrow(x)] == "total")
x <- x[x[[1]] != "total", , drop = FALSE]
stopifnot(all(nzchar(x[[1]])), all(nzchar(x[[2]])))
counts <- data.frame(sgRNA = x[[1]], gene = x[[2]], stringsAsFactors = FALSE)
for (i in seq_along(raw)) {
  v <- as.numeric(x[[3 + i]])
  stopifnot(!anyNA(v), all(v == round(v)))
  counts[[raw[i]]] <- as.integer(v)
}
stopifnot(!anyDuplicated(counts$sgRNA))
utils::write.table(counts, file.path(workdir, "raw_counts.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
