#!/usr/bin/env Rscript
# GSE222531: builds merged_K562_counts.tsv.gz from the 38 per-sample K562
# count files (GSM6925562-GSM6925599; headerless "sgRNA<TAB>count", ids in
# quotes), merged by guide id. Columns are named by sample title (file name
# without the GSM prefix and "_count.txt.gz"); gene = guide id up to the first
# "_" (non-targeting_00000 -> non-targeting). The plasmid and cloning-test
# samples (GSM6925548-61) are left out.
# Usage: Rscript prepare.R <workdir>   (needs fetch_geo.R --sample-files)

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir <- file.path(workdir, "sample_suppl")
files <- sort(list.files(dir, pattern = "^GSM69255(6[2-9]|[7-8][0-9]|9[0-9])_.*_count\\.txt\\.gz$"))
stopifnot(length(files) == 38)
names(files) <- sub("^GSM[0-9]+_(.*)_count\\.txt\\.gz$", "\\1", files)
tables <- lapply(files, function(f) {
  utils::read.delim(file.path(dir, f), header = FALSE, stringsAsFactors = FALSE,
                    colClasses = c("character", "integer"))
})
sgrna <- tables[[1]][[1]]
counts <- lapply(tables, function(x) {
  stopifnot(setequal(x[[1]], sgrna), !anyDuplicated(x[[1]]))
  x[[2]][match(sgrna, x[[1]])]
})
out <- data.frame(sgRNA = sgrna, gene = sub("_.*$", "", sgrna), counts,
                  check.names = FALSE)
con <- gzfile(file.path(workdir, "merged_K562_counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
