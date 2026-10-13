#!/usr/bin/env Rscript
# GSE243761: builds GSE243761_MYH9_counts_with_element.tsv, the deposited
# MYH9 count table with an "element" column added after the guide label.
# The element is the label without its trailing "_N" ("gRNA_45__3" -> "gRNA_45"),
# with "gRNA_N" renamed "DHS_N" and all non-targeting guides "non-targeting".
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.delim(file.path(workdir, "suppl", "GSE243761_MYH9.counts.txt.gz"),
                       check.names = FALSE, stringsAsFactors = FALSE)
element <- sub("_+[0-9]+$", "", x$grna)
element <- sub("^gRNA_([0-9]+)$", "DHS_\\1", element)
out <- data.frame(x[1], element = element, x[-1], check.names = FALSE)
utils::write.table(out, file.path(workdir, "GSE243761_MYH9_counts_with_element.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
