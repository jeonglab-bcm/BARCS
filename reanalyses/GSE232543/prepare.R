#!/usr/bin/env Rscript
# GSE232543: the paper's own MAGeCK gene summaries for the three screens in
# this series, from Nat Commun 14:6352 (2023), doi:10.1038/s41467-023-41792-8:
# Supplementary Data 11 (genome-wide screen in Cebpb-KO DCs) and
# Supplementary Data 12 (661-gene Cebpb-DEG library in Cebpb-KO and WT DCs).
# Each sheet is written unchanged as a tab-separated file sorted by gene id.
# The count files are the GEO supplementary files, read directly.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 600)
download <- function(moesm) {
  url <- sprintf(paste0("https://static-content.springer.com/esm/art%%3A10.1038%%2Fs41467-023-41792-8/",
                        "MediaObjects/41467_2023_41792_MOESM%d_ESM.xlsx"), moesm)
  xl <- file.path(workdir, "paper", basename(url))
  ok <- FALSE
  for (attempt in 1:5) {
    ok <- tryCatch(utils::download.file(url, xl, mode = "wb", quiet = TRUE) == 0,
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.size(xl) > 1e5) break
    Sys.sleep(10 * attempt)
  }
  if (!ok) stop("download failed: ", url)
  xl
}
write_sheet <- function(xl, sheet, out) {
  d <- as.data.frame(readxl::read_excel(xl, sheet = sheet))
  d <- d[order(d$id, method = "radix"), ]
  utils::write.table(d, file.path(workdir, "paper", out), sep = "\t", quote = FALSE,
                     row.names = FALSE, na = "")
}
sd11 <- download(14)
write_sheet(sd11, "Mageck genes", "CebpbKO_GW_mageck.tsv")
sd12 <- download(15)
write_sheet(sd12, "Mageck genes CebpbKO DCs", "CebpbKO_secondary_mageck.tsv")
write_sheet(sd12, "Mageck genes WT DCs", "WT_secondary_mageck.tsv")
