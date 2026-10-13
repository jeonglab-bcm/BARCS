# Downloads the paper's supplementary workbook mmc2.xls (gene-level CRISPR
# screen results per drug arm vs DMSO; compare.json reads sheet
# PalboVsDMSO_gene; Cell Rep Med 2026, doi:10.1016/j.xcrm.2025.102526,
# PMC12866115) from the publisher to paper/mmc2.xls, unchanged (76 MB). The
# same file is in the Europe PMC bundle
# https://www.ebi.ac.uk/europepmc/webservices/rest/PMC12866115/supplementaryFiles,
# which is much slower. The count file is the GEO file as deposited.
#
#   Rscript reanalyses/GSE291338/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = max(1800, getOption("timeout")))
utils::download.file("https://ars.els-cdn.com/content/image/1-s2.0-S2666379125005993-mmc2.xls",
                     file.path(workdir, "paper", "mmc2.xls"), mode = "wb", quiet = TRUE)
