#!/usr/bin/env Rscript
# GSE226447: the count file is used as GEO serves it
# (suppl/GSE226447_AMA.count.txt.gz). This script only fetches the paper's
# gene-level results for the comparison: Supplementary Data 1 of Wang et al.
# 2023 Nat Commun (doi 10.1038/s41467-023-37714-3), the MAGeCK RRA
# gene_summary (positive selection, AMA vs PBS), sheet "AMA_gene_summary",
# saved unchanged as paper/41467_2023_37714_MOESM3_ESM.xlsx.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
options(timeout = 1800)  # the Europe PMC and GEO bundles are large
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "41467_2023_37714_MOESM3_ESM.xlsx")
if (!file.exists(xl)) {
  utils::download.file("https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-023-37714-3/MediaObjects/41467_2023_37714_MOESM3_ESM.xlsx",
                       xl, mode = "wb", quiet = TRUE)
}
stopifnot(file.size(xl) > 1e5)
