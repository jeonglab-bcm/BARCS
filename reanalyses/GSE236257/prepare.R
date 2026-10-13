#!/usr/bin/env Rscript
# GSE236257: builds counts.txt.gz from the deposited read-count matrix
# GSE236257_Epigenetic_Screen_2_Read_Counts.xlsx, which is transposed: a title
# row, then a header row of the 542 guide names, then one row per sequencing
# library (L1-L6 x F1-F5 plus L*_unknown, 36 rows). The matrix is turned so
# guides are rows (in workbook order) and the 36 libraries columns (in workbook
# order); Gene = guide name without its "_g<n>" suffix.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- as.data.frame(readxl::read_excel(
  file.path(workdir, "suppl", "GSE236257_Epigenetic_Screen_2_Read_Counts.xlsx"),
  col_names = FALSE, .name_repair = "minimal"))
guides <- unlist(x[2, -1], use.names = FALSE)
libraries <- x[-(1:2), 1]
values <- matrix(as.numeric(as.matrix(x[-(1:2), -1])), nrow = length(libraries))
stopifnot(length(guides) == 542, !anyDuplicated(guides), !anyNA(values),
          all(values == round(values)))
counts <- data.frame(sgRNA = guides, Gene = sub("_g[0-9]+$", "", guides))
counts[libraries] <- t(values)
out <- gzfile(file.path(workdir, "counts.txt.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)
