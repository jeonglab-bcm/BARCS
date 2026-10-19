#!/usr/bin/env Rscript
# GSE241070: the count file is used as GEO serves it. This builds the paper's
# gene table for the comparison: paper/rra.tsv from Supplementary Material 5
# of the paper (Sci Rep 2026, doi 10.1038/s41598-026-36534-x), sheets
# "RRA negative selections" and "RRA positive selections" (MAGeCK RRA, MPA vs
# DMSO control): gene; min_p = smaller of neg|p-value and pos|p-value;
# min_fdr likewise; lfc = MAGeCK gene lfc (MPA vs control).
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
xl <- file.path(workdir, "paper", "41598_2026_36534_MOESM5_ESM.xlsx")
if (!file.exists(xl)) {
  fetch(paste0("https://media.springernature.com/original/springer-static/esm/",
               "art%3A10.1038%2Fs41598-026-36534-x/MediaObjects/41598_2026_36534_MOESM5_ESM.xlsx"), xl)
}
neg <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "RRA negative selections")))
pos <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "RRA positive selections")))
pos <- pos[match(neg$id, pos$id), ]
stopifnot(identical(neg$id, pos$id))
out <- data.frame(gene = neg$id,
                  min_p = signif(pmin(neg[["neg|p-value"]], pos[["pos|p-value"]]), 6),
                  min_fdr = signif(pmin(neg[["neg|fdr"]], pos[["pos|fdr"]]), 6),
                  lfc = neg[["neg|lfc"]], stringsAsFactors = FALSE)
out <- out[order(out$min_p, -abs(out$lfc), out$gene, method = "radix"), ]
utils::write.table(out, file.path(workdir, "paper", "rra.tsv"), sep = "\t", quote = FALSE,
                   row.names = FALSE)
