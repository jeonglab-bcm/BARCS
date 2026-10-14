#!/usr/bin/env Rscript
# GSE229584: builds GSE229584_merged_counts.tsv.gz from the 11 per-sample
# count files (GSM7165826-35 and GSM7762145; each "sgRNA, Gene, <title>" over
# the same 7,294 guides in the same order), joined by sgRNA and Gene in
# GSM order.
# Usage: Rscript prepare.R <workdir>   (needs fetch_geo.R --sample-files)

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir <- file.path(workdir, "sample_suppl")
files <- sort(list.files(dir, pattern = "^GSM[0-9]+_.*\\.txt\\.gz$"))
stopifnot(length(files) == 11)
tables <- lapply(file.path(dir, files), utils::read.delim, check.names = FALSE,
                 stringsAsFactors = FALSE)
out <- tables[[1]]
for (x in tables[-1]) {
  stopifnot(identical(x$sgRNA, out$sgRNA), identical(x$Gene, out$Gene))
  out <- cbind(out, x[-(1:2)])
}
con <- gzfile(file.path(workdir, "GSE229584_merged_counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
