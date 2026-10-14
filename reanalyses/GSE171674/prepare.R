#!/usr/bin/env Rscript
# GSE171674: builds paper/il2ra_screen.tsv, the authors' MAGeCK gene-level
# results for the IL2RA (CD25) sort screen, from Supplementary Table 2 of
# Freimer et al. 2022 Nat Genet (doi 10.1038/s41588-022-01106-y). The count file
# BARCS reads is the GEO supplementary file as deposited (no change).
# Columns: gene; min_p = smaller of MAGeCK neg|p-value and pos|p-value;
# min_fdr likewise; lfc_high_vs_low = -pos|lfc (the paper's pos|lfc is low vs high,
# IL2RA itself has pos|lfc +2.68).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41588-022-01106-y/MediaObjects/41588_2022_1106_MOESM3_ESM.xlsx"
xl <- file.path(workdir, "paper", "41588_2022_1106_MOESM3_ESM.xlsx")
if (!file.exists(xl)) utils::download.file(url, xl, mode = "wb", quiet = TRUE)
d <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "Table 2 screen gene results",
                                                        skip = 2, col_names = FALSE)))
x <- d[d[[15]] == "IL2RA" & d[[1]] != "Non-Targeting", ]
out <- data.frame(gene = x[[1]], n_guides = as.integer(x[[2]]),
                  min_p = signif(pmin(as.numeric(x[[4]]), as.numeric(x[[10]])), 6),
                  min_fdr = signif(pmin(as.numeric(x[[5]]), as.numeric(x[[11]])), 6),
                  lfc_high_vs_low = -as.numeric(x[[14]]))
out <- out[order(out$min_p, -abs(out$lfc_high_vs_low)), ]
utils::write.table(out, file.path(workdir, "paper", "il2ra_screen.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
