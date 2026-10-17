#!/usr/bin/env Rscript
# GSE233401: builds paper/minipool_screen.tsv, the authors' minipool CRISPR
# screen gene table (Supplementary Data 10 of Kostyrko et al. 2023 Nat Commun
# 14:3966, doi 10.1038/s41467-023-39591-2): depletion z-scores, p-values and
# FDRs for each gene in the sgNeg and the sgUHRF1 background. The sheet has a
# one-line title above the header (read with skip = 1). The count file BARCS
# reads is the GEO supplementary file as deposited (no change).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 600)
url <- paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-023-39591-2/",
              "MediaObjects/41467_2023_39591_MOESM4_ESM.xlsx")
xl <- file.path(workdir, "paper", "MOESM4.xlsx")
ok <- FALSE
for (i in 1:5) {
  ok <- tryCatch(utils::download.file(url, xl, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.exists(xl) && file.size(xl) > 1e5) break
  Sys.sleep(10 * i)
}
if (!ok || file.size(xl) <= 1e5) stop("download failed: ", url)
tab <- as.data.frame(readxl::read_excel(xl, sheet = "Data_S10", skip = 1))
tab <- tab[!is.na(tab$Gene), ]
tab <- tab[order(tab$Gene, method = "radix"), ]
utils::write.table(tab, file.path(workdir, "paper", "minipool_screen.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE, na = "")
