#!/usr/bin/env Rscript
# GSE206832: (1) rewrites the two genome-wide screen count files without the
# UTF-8 byte-order mark that precedes the first column name in the GEO files
# and the two secondary-screen count files (counts unchanged) ->
# counts_cd86_gw.tsv.gz, counts_pdl1_gw.tsv.gz, counts_cd86_sec.tsv.gz,
# counts_pdl1_sec.tsv.gz.
# (2) builds paper/{cd86,pdl1}_{gw,sec}_mageck.tsv from Supplementary Data 1-4 of Weiss et al. 2023 Nat Commun
# (doi 10.1038/s41467-023-41792-8), sheet "Mageck genes": gene; min_p = smaller
# of MAGeCK neg|p-value and pos|p-value; min_fdr likewise; lfc_low_vs_high =
# MAGeCK lfc (treatment = low bin, control = high bin, e.g. Cd274 +3.46 in the
# PDL1 screen).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 600)
fetch <- function(url, dest) {
  for (i in 1:5) {
    ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > 1e5) return(invisible(dest))
    Sys.sleep(10 * i)
  }
  stop("download failed: ", url)
}
strip_bom <- function(src, dest) {
  x <- utils::read.csv(gzfile(file.path(workdir, "suppl", src)), check.names = FALSE,
                       stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
  names(x)[1] <- "sgRNA"
  con <- gzfile(file.path(workdir, dest), "w")
  utils::write.table(x, con, sep = "\t", quote = FALSE, row.names = FALSE)
  close(con)
}
strip_bom("GSE206832_CD86_GW_Screen.csv.gz", "counts_cd86_gw.tsv.gz")
strip_bom("GSE206832_PDL1_GW_Screen.csv.gz", "counts_pdl1_gw.tsv.gz")
strip_bom("GSE206832_CD86_Secondary_Screen.csv.gz", "counts_cd86_sec.tsv.gz")
strip_bom("GSE206832_PDL1_Secondary_Screen.csv.gz", "counts_pdl1_sec.tsv.gz")

base <- "https://media.springernature.com/original/springer-static/esm/art%3A10.1038%2Fs41467-023-41792-8/MediaObjects/"
for (s in list(c("41467_2023_41792_MOESM4_ESM.xlsx", "cd86_gw_mageck.tsv"),
               c("41467_2023_41792_MOESM5_ESM.xlsx", "cd86_sec_mageck.tsv"),
               c("41467_2023_41792_MOESM6_ESM.xlsx", "pdl1_gw_mageck.tsv"),
               c("41467_2023_41792_MOESM7_ESM.xlsx", "pdl1_sec_mageck.tsv"))) {
  xl <- file.path(workdir, "paper", s[1])
  if (!file.exists(xl)) fetch(paste0(base, s[1]), xl)
  d <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "Mageck genes")))
  out <- data.frame(gene = d[["id"]],
                    min_p = signif(pmin(d[["neg|p-value"]], d[["pos|p-value"]]), 6),
                    min_fdr = signif(pmin(d[["neg|fdr"]], d[["pos|fdr"]]), 6),
                    lfc_low_vs_high = d[["neg|lfc"]])
  out <- out[order(out$min_p, -abs(out$lfc_low_vs_high), out$gene, method = "radix"), ]
  utils::write.table(out, file.path(workdir, "paper", s[2]), sep = "\t", quote = FALSE,
                     row.names = FALSE)
}
