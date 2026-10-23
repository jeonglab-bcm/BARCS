#!/usr/bin/env Rscript
# GSE159278: builds GSE159278_counts.tsv from the deposited GSE159278_CAS_TF_sgASCL1_Screen_Rawcounts_DESeq2.csv.gz
# (old Mac line endings; guide counts plus the authors' DESeq2 guide results).
# Keeps the guide id, adds a Gene column (the guide id without its ".N"
# suffix) and keeps the raw count columns; the DESeq2 columns are dropped.
# One guide (neg_ctrl.2) has "n/a" in every count column and is dropped.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.csv(file.path(workdir, "suppl", "GSE159278_CAS_TF_sgASCL1_Screen_Rawcounts_DESeq2.csv.gz"),
                     check.names = FALSE, stringsAsFactors = FALSE, colClasses = "character")
count_cols <- grep("^R[0-9]_", names(x), value = TRUE)
counts <- as.data.frame(lapply(x[count_cols], function(v) suppressWarnings(as.numeric(v))),
                        check.names = FALSE)
bad <- !stats::complete.cases(counts)
if (any(bad)) message("dropped guide(s) with a non-numeric count: ", paste(x$gRNA[bad], collapse = ", "))
stopifnot(sum(bad) <= 1, all(counts[!bad, ] == round(counts[!bad, ])))
out <- data.frame(gRNA = x$gRNA, Gene = sub("\\.[0-9]+$", "", x$gRNA), counts,
                  check.names = FALSE)[!bad, ]
utils::write.table(out, file.path(workdir, "GSE159278_counts.tsv"), sep = "\t", quote = FALSE,
                   row.names = FALSE)
