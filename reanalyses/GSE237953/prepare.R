#!/usr/bin/env Rscript
# GSE237953: builds counts_raw_minus1.tsv and paper/mageck_data.tsv.
# The deposited guide table (GSE237953_data_prepared.csv.gz, semicolon-
# separated) carries a pseudocount: every count is >= 1 and 30% are exactly 1.
# This subtracts the 1 from every sample count to recover the raw counts.
# The published table is the deposited MAGeCK gene summary
# (GSE237953_mageck_data.csv.gz, semicolon-separated with decimal commas),
# rewritten as a plain tab-separated table.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
suppl <- file.path(workdir, "suppl")

x <- utils::read.delim(file.path(suppl, "GSE237953_data_prepared.csv.gz"), sep = ";",
                       check.names = FALSE, stringsAsFactors = FALSE)
samples <- grep("^fkpb5_", names(x))
stopifnot(all(as.matrix(x[samples]) >= 1))
x[samples] <- x[samples] - 1L
utils::write.table(x, file.path(workdir, "counts_raw_minus1.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)

m <- utils::read.delim(file.path(suppl, "GSE237953_mageck_data.csv.gz"), sep = ";", dec = ",",
                       check.names = FALSE, stringsAsFactors = FALSE,
                       fileEncoding = "UTF-8-BOM")
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
utils::write.table(m, file.path(workdir, "paper", "mageck_data.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
