#!/usr/bin/env Rscript
# GSE243882: the count files BARCS reads are the GEO supplementary files as
# deposited (no change). This script builds the paper's gene-level table from
# Supplementary Data 1 of Pinilla et al. 2024 Commun Biol
# (doi 10.1038/s42003-024-06555-1): MAGeCK-MLE betas for 2D and 3D vs T0 and the
# 3D-2D beta difference, protein-coding genes and miRNAs combined, one file per
# cell line: paper/supp1_<cell line>.tsv with columns gene, beta_2D, fdr_2D,
# beta_3D, fdr_3D, diff_3D_2D, abs_diff.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs42003-024-06555-1/MediaObjects/42003_2024_6555_MOESM4_ESM.xlsx"
xl <- file.path(workdir, "paper", "SupplementaryData1.xlsx")
if (!file.exists(xl)) utils::download.file(url, xl, mode = "wb", quiet = TRUE)
for (cl in c("MCF7", "HCC1395")) {
  parts <- lapply(paste0(cl, c("_PCGs", "_miRNAs")), function(s) {
    d <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = s, col_types = "text")))
    stopifnot(ncol(d) == 6)
    data.frame(gene = d[[1]], beta_2D = as.numeric(d[[2]]), fdr_2D = as.numeric(d[[3]]),
               beta_3D = as.numeric(d[[4]]), fdr_3D = as.numeric(d[[5]]),
               diff_3D_2D = as.numeric(d[[6]]))
  })
  out <- do.call(rbind, parts)
  out <- out[!is.na(out$gene) & !is.na(out$diff_3D_2D), ]
  out[-1] <- lapply(out[-1], signif, 6)
  out$abs_diff <- abs(out$diff_3D_2D)
  out <- out[order(-out$abs_diff, out$gene, method = "radix"), ]
  utils::write.table(out, file.path(workdir, "paper", paste0("supp1_", cl, ".tsv")),
                     sep = "\t", quote = FALSE, row.names = FALSE)
}
