#!/usr/bin/env Rscript
# GSE212152: builds GSE212152_combined_counts.tsv.gz, the establishment and
# maintenance count files (same 5,950-guide library, same guide order) put
# side by side in one table so both analyses read one counts_file.
# The published table (MAGeCK establishment gene summary) is a GEO file.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
read_counts <- function(screen) {
  utils::read.delim(file.path(workdir, "suppl",
                              sprintf("GSE212152_EpiChromo_Screen_%s_counts.txt.gz", screen)),
                    check.names = FALSE, stringsAsFactors = FALSE)
}
est <- read_counts("establishment")
mnt <- read_counts("maintenance")
stopifnot(identical(est$sgRNA, mnt$sgRNA), identical(est$Gene, mnt$Gene))
out <- cbind(est, mnt[-(1:2)])
con <- gzfile(file.path(workdir, "GSE212152_combined_counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
