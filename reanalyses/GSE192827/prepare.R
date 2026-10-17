#!/usr/bin/env Rscript
# GSE192827: downloads paper/MOESM8.xlsx, the supplementary table of Mamedov
# et al. 2023 Nature (doi 10.1038/s41586-023-06482-x) holding the authors'
# MAGeCK RRA gene results for the BTN3A FACS screen (sheet "BTN3A Screen";
# pos = enriched in BTN3A-low cells, neg = enriched in BTN3A-high cells).
# The count file BARCS reads is the GEO supplementary file as deposited.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://media.springernature.com/original/springer-static/esm/art%3A10.1038%2Fs41586-023-06482-x/MediaObjects/41586_2023_6482_MOESM8_ESM.xlsx"
dest <- file.path(workdir, "paper", "MOESM8.xlsx")
options(timeout = 600)
for (i in 1:5) {
  ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.exists(dest) && file.size(dest) > 1e5) break
  Sys.sleep(10 * i)
}
if (!file.exists(dest) || file.size(dest) <= 1e5) stop("download failed: ", url)
