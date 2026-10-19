#!/usr/bin/env Rscript
# GSE213184: the count file (GSE213184_S6612_summary.xlsx) is used as GEO
# serves it. This builds the paper's gene table for the comparison:
# paper/mageck_mle.tsv from Data S1 of Li et al. 2026 Cell Rep
# (doi 10.1016/j.celrep.2025.116903, PMC13034653; NIHMS2151702-supplement-2.xlsx,
# MAGeCK MLE gene summary for the top-10% GFP bin, baseline = next-25% and
# static libraries), downloaded from the Europe PMC supplementary-files
# service: gene, beta, Wald p-value and Wald FDR (the paper's "adjusted p <
# 0.05" list of 1,628 genes matches Wald p < 0.05 with beta < 0), and the
# permutation p-value and FDR MAGeCK also reports.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 900)
zip <- file.path(workdir, "paper", "PMC13034653_supplementary.zip")
member <- "NIHMS2151702-supplement-2.xlsx"
for (i in 1:5) {
  if (file.exists(zip) && member %in% utils::unzip(zip, list = TRUE)$Name) break
  unlink(zip)
  tryCatch(utils::download.file("https://www.ebi.ac.uk/europepmc/webservices/rest/PMC13034653/supplementaryFiles",
                                zip, mode = "wb", quiet = TRUE),
           error = function(e) NULL, warning = function(w) NULL)
  ok <- file.exists(zip) && tryCatch(member %in% utils::unzip(zip, list = TRUE)$Name,
                                     error = function(e) FALSE)
  if (ok) break
  Sys.sleep(15 * i)
}
utils::unzip(zip, files = member, exdir = file.path(workdir, "paper"), overwrite = TRUE)
d <- as.data.frame(suppressMessages(readxl::read_excel(file.path(workdir, "paper", member))))
out <- data.frame(gene = d[["Gene"]], beta = d[["LH2_top10|beta"]],
                  wald_p = d[["LH2_top10|wald-p-value"]], wald_fdr = d[["LH2_top10|wald-fdr"]],
                  perm_p = d[["LH2_top10|p-value"]], perm_fdr = d[["LH2_top10|fdr"]],
                  stringsAsFactors = FALSE)
utils::write.table(out, file.path(workdir, "paper", "mageck_mle.tsv"), sep = "\t", quote = FALSE,
                   row.names = FALSE)
