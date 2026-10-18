#!/usr/bin/env Rscript
# GSE223086: builds GSE223086_K562_Brunello_counts.txt.gz by joining the four
# per-sample Brunello-library K562 proliferation count files (day0 x2, day24 x2;
# from fetch_geo.R --sample-files) on the guide id. Each deposited file has two
# unnamed columns: guide id (<Gene>_<20nt>_Brunello) and raw read count, no
# header. The gene is the id with the _<sequence>_Brunello suffix removed;
# NO_CURRENT_* are the library's non-targeting controls. Counts are unchanged.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir <- file.path(workdir, "sample_suppl")
samples <- c(day0_1 = "GSM6939410_K562_Brunello_day0_1",
             day0_2 = "GSM6939411_K562_Brunello_day0_2",
             day24_1 = "GSM6939418_K562_Brunello_day24_1",
             day24_2 = "GSM6939419_K562_Brunello_day24_2")
counts <- NULL
for (nm in names(samples)) {
  f <- file.path(dir, paste0(samples[[nm]], ".count.txt.gz"))
  d <- utils::read.delim(f, header = FALSE, stringsAsFactors = FALSE,
                         col.names = c("sgRNA", nm))
  counts <- if (is.null(counts)) d else merge(counts, d, by = "sgRNA", all = TRUE)
}
stopifnot(!anyNA(counts))
counts$Gene <- sub("_[ACGT]+_Brunello$", "", counts$sgRNA)
stopifnot(all(counts$Gene != counts$sgRNA))
counts <- counts[, c("sgRNA", "Gene", names(samples))]
counts <- counts[order(counts$sgRNA, method = "radix"), ]
out <- gzfile(file.path(workdir, "GSE223086_K562_Brunello_counts.txt.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)
