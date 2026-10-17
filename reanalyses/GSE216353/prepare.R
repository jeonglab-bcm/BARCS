#!/usr/bin/env Rscript
# GSE216353: merges the three per-sample THP-1 (tMAC) count files into one
# count matrix (counts_thp1.tsv.gz), joined on the sgRNA id present in every
# file (counts unchanged). Columns: sgRNA, Gene, presort, CD80_low, CD80_high.
# The iMAC arm is not merged here: its GSM titles for CD80 high/low are swapped
# relative to the deposited filenames and both deposited headers read "high", so
# its bin labels are not reliable.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
sd <- file.path(workdir, "sample_suppl")
rd <- function(f, col) {
  x <- utils::read.delim(gzfile(file.path(sd, f)), stringsAsFactors = FALSE,
                         check.names = FALSE)
  names(x)[3] <- col
  x[, c("sgRNA", "Gene", col)]
}
pre  <- rd("GSM6670883_presort_count.count.txt.gz", "presort")
low  <- rd("GSM6670884_CD80_low_count.txt.gz",      "CD80_low")
high <- rd("GSM6670885_CD80_high_count.txt.gz",     "CD80_high")
m <- merge(merge(pre, low[, c("sgRNA", "CD80_low")], by = "sgRNA"),
           high[, c("sgRNA", "CD80_high")], by = "sgRNA")
m <- m[order(m$sgRNA, method = "radix"), c("sgRNA", "Gene", "presort", "CD80_low", "CD80_high")]
con <- gzfile(file.path(workdir, "counts_thp1.tsv.gz"), "w")
utils::write.table(m, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
