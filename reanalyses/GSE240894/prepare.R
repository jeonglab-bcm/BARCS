#!/usr/bin/env Rscript
# GSE240894: builds paper/SuppFileS1_v1.xlsx, Supplemental File 1 of Hafer et
# al. 2023 (bioRxiv 2023.07.28.551016, PMC10402164): the authors' MAGeCK gene
# summaries for the Latency HIV-CRISPR screen in J-Lat 10.6 and 5A8 cells
# (sheets JLat106_GeneSummary, JLat5A8_GeneSummary). The file is fetched from
# the Europe PMC supplementary archive (a zip whose media-1.zip contains the
# Excel file). The count file BARCS reads is the GEO supplementary file as
# deposited (no change).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 600)
url <- "https://www.ebi.ac.uk/europepmc/webservices/rest/PMC10402164/supplementaryFiles"
outer <- file.path(workdir, "paper", "supp.zip")
for (i in 1:5) {
  ok <- tryCatch(utils::download.file(url, outer, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.exists(outer) && file.size(outer) > 1e5) break
  Sys.sleep(10 * i)
}
if (!file.exists(outer) || file.size(outer) <= 1e5) stop("download failed: ", url)
tmp <- file.path(workdir, "paper", "unzip")
unlink(tmp, recursive = TRUE); dir.create(tmp)
utils::unzip(outer, exdir = tmp)
inner <- file.path(tmp, "media-1.zip")
stopifnot(file.exists(inner))
utils::unzip(inner, exdir = tmp)
xl <- list.files(tmp, pattern = "SuppFileS1.*\\.xlsx$", full.names = TRUE, recursive = TRUE)
xl <- xl[!grepl("__MACOSX", xl)]
stopifnot(length(xl) == 1)
file.copy(xl, file.path(workdir, "paper", "SuppFileS1_v1.xlsx"), overwrite = TRUE)
unlink(tmp, recursive = TRUE); unlink(outer)
