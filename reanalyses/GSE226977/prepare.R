#!/usr/bin/env Rscript
# GSE226977: builds merged_counts.txt.gz, one guide table from the twelve
# per-sample count files (sample_suppl/, from fetch_geo.R --sample-files; each
# has sgRNA, Gene and one count column named after the sample, whitespace-
# separated). Samples are merged on sgRNA + Gene in GSM order; guide order is
# that of the first file. Column names are the files' own (e.g. T0-DMSO-Rep1).
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
files <- sort(list.files(file.path(workdir, "sample_suppl"), pattern = "^GSM[0-9]+_.*\\.txt\\.gz$",
                         full.names = TRUE))
stopifnot(length(files) == 12)
tables <- lapply(files, utils::read.table, header = TRUE, sep = "", check.names = FALSE,
                 stringsAsFactors = FALSE)
merged <- tables[[1]]
for (x in tables[-1]) {
  stopifnot(!anyDuplicated(x$sgRNA), setequal(x$sgRNA, merged$sgRNA))
  merged <- merge(merged, x, by = c("sgRNA", "Gene"), all = TRUE, sort = FALSE)
}
merged <- merged[match(tables[[1]]$sgRNA, merged$sgRNA), ]
stopifnot(!anyNA(merged))
out <- gzfile(file.path(workdir, "merged_counts.txt.gz"), "w")
utils::write.table(merged, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)
