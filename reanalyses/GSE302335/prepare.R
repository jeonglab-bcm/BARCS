#!/usr/bin/env Rscript
# GSE302335: builds ICAM1_screen_guide_counts.tsv, one row per guide.
# The deposited table splits each guide over ~41 cell-barcode rows (30-mer =
# 19-nt spacer + barcode); this sums the rows of each guide, keyed on the
# first 19 nt and the gene, and names the guide "<spacer>_<gene>".
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
src <- file.path(workdir, "suppl", "GSE302335_counts_ICAM1_screen_barcode.csv.gz")
x <- utils::read.csv(src, check.names = FALSE, fileEncoding = "UTF-8-BOM",
                     stringsAsFactors = FALSE)
guide <- paste0(substr(x$sgRNA, 1, 19), "_", x$gene)
counts <- rowsum(as.matrix(x[, -(1:2)]), guide, reorder = FALSE)
out <- data.frame(sgRNA = rownames(counts),
                  gene = x$gene[match(rownames(counts), guide)],
                  counts, check.names = FALSE)
utils::write.table(out, file.path(workdir, "ICAM1_screen_guide_counts.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
