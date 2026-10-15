#!/usr/bin/env Rscript
# GSE270368: builds paper/mageck_gsi_vs_dmso.tsv, the authors' MAGeCK test (RRA)
# gene summary for GSI vs DMSO in MB157R cells, from Dataset EV2 of the EMBO
# Molecular Medicine paper (doi 10.1038/s44321-024-00161-8), sheet
# 'CRISPR-Cas9 screen'. Columns as in MAGeCK's gene_summary (id, num,
# neg|score ... pos|lfc), sorted by neg|rank. The count file BARCS reads is the
# GEO file as deposited (no change).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs44321-024-00161-8/MediaObjects/44321_2024_161_MOESM6_ESM.xlsx"
xl <- file.path(workdir, "paper", "44321_2024_161_MOESM6_ESM.xlsx")
if (!file.exists(xl)) utils::download.file(url, xl, mode = "wb", quiet = TRUE)
x <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "CRISPR-Cas9 screen")))
for (j in setdiff(names(x), "id")) x[[j]] <- signif(as.numeric(x[[j]]), 6)
x <- x[order(x[["neg|rank"]], x$id, method = "radix"), ]
utils::write.table(x, file.path(workdir, "paper", "mageck_gsi_vs_dmso.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
