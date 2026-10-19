#!/usr/bin/env Rscript
# GSE237122 (Yousefi et al. 2023, Emerg Microbes Infect, PMID 37672505):
# the count file BARCS reads is the GEO supplementary file as deposited (no
# change). This builds the paper's own gene-level MAGeCK tables for the
# comparison, from Supplementary Table 4 of the paper (doi 10.1080/22221751.2023.2256416,
# PMC10512916), fetched through the Europe PMC supplementary-file bundle.
# Sheets "SARS-CoV-2" and "HCoV-OC43" are MAGeCK gene_summary tables; the
# screen is positive-selection (host factors enriched on infection), so the
# paper's call is pos|score / pos|fdr. Writes paper/mageck_SARS2.tsv and
# paper/mageck_OC43.tsv with id, pos|score, pos|fdr, pos|rank, pos|lfc.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "SM8734.xlsx")
if (!file.exists(xl)) {
  url <- "https://www.ebi.ac.uk/europepmc/webservices/rest/PMC10512916/supplementaryFiles"
  zipf <- file.path(workdir, "paper", "epmc_suppl.zip")
  old <- options(timeout = 600); on.exit(options(old))
  for (attempt in 1:5) {
    ok <- tryCatch({utils::download.file(url, zipf, mode = "wb", quiet = TRUE); TRUE},
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(zipf) && file.size(zipf) > 0) break
    unlink(zipf); Sys.sleep(10 * attempt)
  }
  utils::unzip(zipf, files = "TEMI_A_2256416_SM8734.xlsx", exdir = file.path(workdir, "paper"))
  file.rename(file.path(workdir, "paper", "TEMI_A_2256416_SM8734.xlsx"), xl)
  unlink(zipf)
}
for (sh in c("SARS-CoV-2", "HCoV-OC43")) {
  d <- as.data.frame(readxl::read_excel(xl, sheet = sh))
  out <- data.frame(id = d$id,
                    pos_score = signif(as.numeric(d[["pos|score"]]), 6),
                    pos_fdr   = signif(as.numeric(d[["pos|fdr"]]), 6),
                    pos_rank  = as.integer(d[["pos|rank"]]),
                    pos_lfc   = signif(as.numeric(d[["pos|lfc"]]), 6),
                    check.names = FALSE)
  out <- out[order(out$pos_rank), ]
  f <- if (sh == "SARS-CoV-2") "mageck_SARS2.tsv" else "mageck_OC43.tsv"
  utils::write.table(out, file.path(workdir, "paper", f), sep = "\t", quote = FALSE, row.names = FALSE)
}
