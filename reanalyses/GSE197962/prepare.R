#!/usr/bin/env Rscript
# GSE197962 (Israeli et al. 2022 Nat Commun, PMID 35469023): builds
# paper/gene_results.tsv from Supplementary Data 1 (MOESM4, sheet Gene_results),
# the authors' MAGeCK RRA results for all infected screens combined ("all") and
# per variant (wt, alpha, beta). The count file BARCS reads is the GEO
# supplementary file as deposited (no change).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-022-29896-z/MediaObjects/41467_2022_29896_MOESM4_ESM.xlsx"
xl <- file.path(workdir, "paper", "41467_2022_29896_MOESM4_ESM.xlsx")
if (!file.exists(xl)) utils::download.file(url, xl, mode = "wb", quiet = TRUE)
d <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "Gene_results")))
names(d) <- gsub("\\.", "_", names(d))
d <- d[d$id != "NonTargetControl", ]
names(d)[names(d) == "id"] <- "gene"
d <- d[order(d$pos_score_all), ]
utils::write.table(d, file.path(workdir, "paper", "gene_results.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
