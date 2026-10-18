#!/usr/bin/env Rscript
# GSE199603: builds paper/cd300ld_screen.tsv from Supplementary Table 1 of
# Wang et al. 2023 Nature (doi 10.1038/s41586-023-06511-9), the authors' MAGeCK
# gene summary for bone marrow vs tumour. MAGeCK's comparison is BM (treatment)
# vs tumour (control), so its "pos" side is depletion in tumour. Columns: gene;
# pos_score, pos_p, pos_fdr (MAGeCK pos|score, pos|p-value, pos|fdr);
# lfc_tumor_vs_bm = -lfc. The count file BARCS reads is the GEO xlsx as deposited.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://media.springernature.com/original/springer-static/esm/art%3A10.1038%2Fs41586-023-06511-9/MediaObjects/41586_2023_6511_MOESM2_ESM.xlsx"
xl <- file.path(workdir, "paper", "41586_2023_6511_MOESM2_ESM.xlsx")
options(timeout = 600)
for (i in 1:5) {
  if (file.exists(xl) && file.size(xl) > 1e4) break
  ok <- tryCatch(utils::download.file(url, xl, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (!ok) Sys.sleep(10 * i)
}
if (!file.exists(xl) || file.size(xl) <= 1e4) stop("download failed: ", url)
d <- as.data.frame(suppressMessages(readxl::read_excel(xl, col_names = FALSE, skip = 2)))
# columns: 1 gene, 2 ratio, 3 gene, 4 num, 5-10 neg, 11-16 pos
out <- data.frame(gene = d[[3]],
                  pos_score = signif(as.numeric(d[[11]]), 6),
                  pos_p = signif(as.numeric(d[[12]]), 6),
                  pos_fdr = signif(as.numeric(d[[13]]), 6),
                  lfc_tumor_vs_bm = -signif(as.numeric(d[[16]]), 6))
out <- out[!is.na(out$gene), ]
out <- out[order(out$pos_score, out$gene, method = "radix"), ]
utils::write.table(out, file.path(workdir, "paper", "cd300ld_screen.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
