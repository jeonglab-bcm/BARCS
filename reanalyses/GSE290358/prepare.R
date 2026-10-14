#!/usr/bin/env Rscript
# GSE290358: builds paper/mageck_high_vs_low.tsv from the authors' per-replicate
# MAGeCK RRA gene summaries (Supplementary Tables mmc2 = replicate 1, mmc3 =
# replicate 2; Dam et al. 2025 Mol Ther Oncol, PMC12617759), fetched as the
# Europe PMC supplementary-file bundle. MAGeCK "pos" = enriched in JAM-A high.
# Columns: gene; rep1_p / rep2_p = smaller of neg|p-value and pos|p-value in that
# replicate; score = the larger of the two (a gene must be strong in both
# replicates, as the paper requires); lfc = mean pos|lfc (high vs low).
# The count file BARCS reads is the GEO supplementary file as deposited.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
pdir <- file.path(workdir, "paper"); dir.create(pdir, showWarnings = FALSE)
zip <- file.path(pdir, "PMC12617759_supplementary.zip")
if (!file.exists(file.path(pdir, "mmc2.xlsx")) || !file.exists(file.path(pdir, "mmc3.xlsx"))) {
  options(timeout = 1200)
  utils::download.file("https://www.ebi.ac.uk/europepmc/webservices/rest/PMC12617759/supplementaryFiles",
                       zip, mode = "wb", quiet = TRUE)
  utils::unzip(zip, files = c("mmc2.xlsx", "mmc3.xlsx"), exdir = pdir)
  unlink(zip)
}
rd <- function(f) {
  d <- as.data.frame(suppressMessages(readxl::read_excel(file.path(pdir, f), sheet = 1)))
  data.frame(gene = d$id, p = pmin(as.numeric(d[["neg|p-value"]]), as.numeric(d[["pos|p-value"]])),
             lfc = as.numeric(d[["pos|lfc"]]))
}
r1 <- rd("mmc2.xlsx"); r2 <- rd("mmc3.xlsx")
m <- merge(r1, r2, by = "gene", suffixes = c("_rep1", "_rep2"))
out <- data.frame(gene = m$gene, rep1_p = signif(m$p_rep1, 6), rep2_p = signif(m$p_rep2, 6),
                  score = signif(pmax(m$p_rep1, m$p_rep2), 6),
                  lfc = signif((m$lfc_rep1 + m$lfc_rep2) / 2, 6))
out <- out[order(out$score, -abs(out$lfc), out$gene), ]
utils::write.table(out, file.path(pdir, "mageck_high_vs_low.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
