#!/usr/bin/env Rscript
# GSE232340: builds the authors' MAGeCK gene tables from Supplementary Tables 1
# and 2 of Dvorscek... Flugel et al. 2023 Nat Neurosci
# (doi 10.1038/s41593-023-01432-2). Supplementary Table 1 (MOESM4) is the
# genome-wide screen, Table 2 (MOESM5) the validation screen; each workbook has
# one sheet per pairwise comparison. We keep the parenchyma-vs-blood (PvsB) and
# meninges-vs-blood (MvsB) sheets, the depletion comparisons BARCS reproduces.
# Output per comparison: gene; neg_score, neg_p, neg_fdr (MAGeCK, depleted in
# tissue); lfc_tissue_vs_blood = neg|lfc. The count files BARCS reads are the
# GEO supplementary files as deposited (no change).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 600)
base <- "https://media.springernature.com/original/springer-static/esm/art%3A10.1038%2Fs41593-023-01432-2/MediaObjects/"
fetch <- function(f) {
  dest <- file.path(workdir, "paper", f)
  for (i in 1:5) {
    if (file.exists(dest) && file.size(dest) > 1e4) return(dest)
    ok <- tryCatch(utils::download.file(paste0(base, f), dest, mode = "wb", quiet = TRUE) == 0,
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (!ok) Sys.sleep(10 * i)
  }
  if (!file.exists(dest) || file.size(dest) <= 1e4) stop("download failed: ", f)
  dest
}
write_sheet <- function(xl, sheet, out) {
  d <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = sheet)))
  o <- data.frame(gene = d[["id"]],
                  neg_score = signif(d[["neg|score"]], 6),
                  neg_p = signif(d[["neg|p-value"]], 6),
                  neg_fdr = signif(d[["neg|fdr"]], 6),
                  lfc_tissue_vs_blood = signif(d[["neg|lfc"]], 6))
  o <- o[order(o$neg_score, o$gene, method = "radix"), ]
  utils::write.table(o, file.path(workdir, "paper", out), sep = "\t", quote = FALSE,
                     row.names = FALSE)
}
gw <- fetch("41593_2023_1432_MOESM4_ESM.xlsx")
va <- fetch("41593_2023_1432_MOESM5_ESM.xlsx")
write_sheet(gw, "PvsB", "gw_PvsB_mageck.tsv")
write_sheet(gw, "MvsB", "gw_MvsB_mageck.tsv")
write_sheet(va, "PvsB", "val_PvsB_mageck.tsv")
