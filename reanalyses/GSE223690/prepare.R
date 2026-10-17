#!/usr/bin/env Rscript
# GSE223690: downloads paper/mmc2.xlsx, Table S1 of Kim et al. 2023 Cell Rep
# 42:112987 (doi 10.1016/j.celrep.2023.112987): the authors' MAGeCK RRA gene
# results for the day 7 and day 14 -1 PRF reporter sorts (sheets "Day_7" and
# "Day_14"). The count files BARCS reads are the GEO supplementary files as
# deposited (no change).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://ars.els-cdn.com/content/image/1-s2.0-S2211124723009981-mmc2.xlsx"
dest <- file.path(workdir, "paper", "mmc2.xlsx")
options(timeout = 600)
for (i in 1:5) {
  ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.exists(dest) && file.size(dest) > 1e5) break
  Sys.sleep(10 * i)
}
if (!file.exists(dest) || file.size(dest) <= 1e5) stop("download failed: ", url)
