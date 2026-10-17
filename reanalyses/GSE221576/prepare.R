#!/usr/bin/env Rscript
# GSE221576: builds the paper's MAGeCK gene tables from Supplementary Table 1
# (mmc2.xlsx) of Cao et al. 2023 Blood Adv (doi 10.1182/bloodadvances.2023010380,
# PMC10589794), sheets "GSIvsDMSO_gene_Fig1C1E" and "CB103vsDMSO_gene_Fig1B1D".
# Each sheet has a title row, then Gene, LFC, FDR, P, RRA.Score, Rank (one row
# per gene; FDR and P are those of the direction the gene was called in, LFC
# is signed drug vs DMSO). Writes paper/gsi_vs_dmso.tsv and
# paper/cb103_vs_dmso.tsv with gene, lfc, p, fdr. Counts are used as deposited.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 600)
fetch <- function(url, dest, min_size = 1e5) {
  for (i in 1:5) {
    ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > min_size) return(invisible(dest))
    Sys.sleep(10 * i)
  }
  stop("download failed: ", url)
}
xl <- file.path(workdir, "paper", "BLOODA_ADV-2023-010380-mmc2.xlsx")
if (!file.exists(xl)) {
  zip <- file.path(workdir, "paper", "supp.zip")
  if (!file.exists(zip)) {
    fetch("https://www.ebi.ac.uk/europepmc/webservices/rest/PMC10589794/supplementaryFiles", zip)
  }
  utils::unzip(zip, files = basename(xl), exdir = file.path(workdir, "paper"))
}
for (s in list(c("GSIvsDMSO_gene_Fig1C1E", "gsi_vs_dmso.tsv"),
               c("CB103vsDMSO_gene_Fig1B1D", "cb103_vs_dmso.tsv"))) {
  d <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = s[1], skip = 1)))
  out <- data.frame(gene = as.character(d$Gene), lfc = as.numeric(d$LFC),
                    p = as.numeric(d$P), fdr = as.numeric(d$FDR))
  out <- out[order(out$p, -abs(out$lfc), out$gene, method = "radix"), ]
  utils::write.table(out, file.path(workdir, "paper", s[2]), sep = "\t", quote = FALSE,
                     row.names = FALSE)
}
