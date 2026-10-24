#!/usr/bin/env Rscript
# GSE146841 (You et al. 2021 Science, PMID 33384352): GEO lists one sample
# (GSM4407718) whose supplementary files hold the guide count matrix
# (GSM4407718_count.tsv.gz: 12 libraries, Tm/DMSO x XBP1s-GFP high/low x 3
# replicates, integer reads) and the authors' MAGeCK-MLE results for each sort
# (Tm_H-Tm_L and DMSO_H-DMSO_L). The series matrix links only the first file, so
# this script downloads the count file and the Tm MLE table, and writes the latter
# as paper/tm_mle.tsv (non-targeting row and genes with undefined statistics dropped).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
base <- "https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4407nnn/GSM4407718/suppl/"
dir.create(file.path(workdir, "sample_suppl"), showWarnings = FALSE)
for (f in c("GSM4407718_count.tsv.gz", "GSM4407718_Tm_H-Tm_L.tsv.gz")) {
  dest <- file.path(workdir, "sample_suppl", f)
  if (!file.exists(dest)) utils::download.file(paste0(base, f), dest, mode = "wb", quiet = TRUE)
}
m <- utils::read.delim(file.path(workdir, "sample_suppl", "GSM4407718_Tm_H-Tm_L.tsv.gz"),
                       check.names = FALSE, stringsAsFactors = FALSE)
p <- suppressWarnings(as.numeric(m[["beta_1|wald-p-value"]]))
out <- data.frame(gene = m$Gene, n_guides = m$sgRNA,
                  beta_high_vs_low = suppressWarnings(as.numeric(m[["beta_1|beta"]])),
                  wald_p = p, wald_fdr = suppressWarnings(as.numeric(m[["beta_1|wald-fdr"]])))
out <- out[!is.na(out$wald_p) & out$gene != "NON-TARGETING-CONTROL", ]
out <- out[order(out$wald_p), ]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
utils::write.table(out, file.path(workdir, "paper", "tm_mle.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
