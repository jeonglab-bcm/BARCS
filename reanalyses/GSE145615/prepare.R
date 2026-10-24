#!/usr/bin/env Rscript
# GSE145615: the deposited count file (suppl/GSE145615_CRISPR_count.tsv.gz) is
# raw integer counts served by GEO as is, so it is not rebuilt here. This
# script only builds paper/screenII_late_mageck.tsv, the authors' MAGeCK
# positive-selection results for Screen II (late selection); Supplementary
# Table 4 of Nature 591:312 (2021), doi:10.1038/s41586-020-03135-1, sheet
# "IAP Screen_II (late selection)", its two-row header collapsed to one.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
url <- paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-020-03135-1/",
              "MediaObjects/41586_2020_3135_MOESM7_ESM.xlsx")
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "41586_2020_3135_MOESM7_ESM.xlsx")
options(timeout = 600)
ok <- FALSE
for (attempt in 1:5) {
  ok <- tryCatch(utils::download.file(url, xl, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.size(xl) > 10000) break
  Sys.sleep(10 * attempt)
}
if (!ok) stop("download failed: ", url)
tab <- as.data.frame(readxl::read_excel(xl, sheet = "IAP Screen_II (late selection)", skip = 2))
tab <- tab[!is.na(tab$id), ]
tab <- tab[order(as.numeric(tab[["pos|rank"]]), tab$id, method = "radix"), ]
utils::write.table(tab, file.path(workdir, "paper", "screenII_late_mageck.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE, na = "")
