#!/usr/bin/env Rscript
# GSE222104: writes counts.tsv.gz from the "Raw_counts" sheet of the deposited
# workbook GSE222104_Lihui_Counts_2020_03_05.xlsx (GeCKO v2 A+B merged, MAGeCK
# count output: sgRNA, Gene, initial_rep1/2 = GFP-low sorts, final_rep1/2 =
# GFP-high sorts). The "Normalized_counts" sheet is not used. Counts are
# unchanged; rows are sorted by guide id.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- as.data.frame(readxl::read_excel(
  file.path(workdir, "suppl", "GSE222104_Lihui_Counts_2020_03_05.xlsx"), sheet = "Raw_counts"))
stopifnot(identical(names(x), c("sgRNA", "Gene", "initial_rep1", "initial_rep2", "final_rep1", "final_rep2")))
stopifnot(all(vapply(x[3:6], function(v) all(v == round(v)), logical(1))))
x <- x[order(x$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(x, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
