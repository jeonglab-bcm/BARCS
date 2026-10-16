#!/usr/bin/env Rscript
# GSE179799 (Jones et al. 2024 Cancer Res, PMID 38535994): adds a gene column to
# the GEO combined count matrix. GSE179799_combined_counts.txt.gz has one sgRNA
# column (GENE_<position>_<sense|antisense>) and 90 sample columns of raw counts.
# The gene is the sgRNA name up to "_<digits>_<sense|antisense>"; there are no
# non-targeting guides in this custom whole-genome library. Usage:
# Rscript prepare.R <workdir>   (after fetch_geo.R GSE179799)
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
f <- file.path(workdir, "suppl", "GSE179799_combined_counts.txt.gz")
x <- utils::read.delim(f, check.names = FALSE, stringsAsFactors = FALSE)
names(x)[1] <- "sgRNA"
gene <- sub("_[0-9]+_(sense|antisense)$", "", x$sgRNA)
out <- data.frame(sgRNA = x$sgRNA, gene = gene, x[, -1, drop = FALSE], check.names = FALSE)
out <- out[order(out$sgRNA, method = "radix"), ]
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
