#!/usr/bin/env Rscript
# GSE287048: fetches the paper's published gene table. The count files are the
# GEO supplementary files as deposited (GSE287048_HCC1806-INX315.count.txt.gz,
# GSE287048_MIA-PaCa-TKOv3.count.txt.gz), so nothing is built for the counts.
# Published table: Supplementary Data 2 of the paper (DrugZ results of the
# INX-315 versus control screens, sheets "HCC1806" and "MiaPaCa-2"; Nat Commun
# 2025, doi:10.1038/s41467-025-56674-4), copied unchanged to
# paper/SupplementaryData2.xlsx.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
paper <- file.path(workdir, "paper")
dir.create(paper, showWarnings = FALSE)
url <- paste0("https://media.springernature.com/original/springer-static/esm/",
              "art%3A10.1038%2Fs41467-025-56674-4/MediaObjects/41467_2025_56674_MOESM5_ESM.xlsx")
dest <- file.path(paper, "SupplementaryData2.xlsx")
options(timeout = max(1800, getOption("timeout")))
for (attempt in 1:3) {
  ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE)
  if (ok) break
  Sys.sleep(30 * attempt)
}
stopifnot(ok, identical(readxl::excel_sheets(dest), c("MiaPaCa-2", "HCC1806")))
