#!/usr/bin/env Rscript
# GSE328470 (Gierisch et al., Nat Commun 2026, PMID 42098118): the count file is
# the GEO file as deposited (suppl/GSE328470_Readcount_per_guide.txt.gz). This
# script builds only the paper's table: it downloads Supplementary Data 1
# (MAGeCK positive-selection gene summaries per experiment and sorted bin) and
# writes paper/SD1_YFPlow_combined.tsv, one row per gene with the YFP-low
# results of both experiments side by side and a combined score: the larger of
# the two MAGeCK pos|p-values (a gene must score in both experiments, as the
# paper requires) and the mean pos|lfc.
#
#   Rscript work/GSE328470/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
paper <- file.path(workdir, "paper")
dir.create(paper, recursive = TRUE, showWarnings = FALSE)
options(timeout = max(600, getOption("timeout")))
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-026-72783-0/MediaObjects/41467_2026_72783_MOESM3_ESM.xlsx"
xlsx <- file.path(paper, "SupplementaryData1.xlsx")
tryCatch(utils::download.file(url, xlsx, mode = "wb", quiet = TRUE),
         error = function(e) stop("could not download Supplementary Data 1 (", url, "): ",
                                  conditionMessage(e), call. = FALSE))

read_sheet <- function(sheet) {
  d <- as.data.frame(readxl::read_excel(xlsx, sheet = sheet))
  d[, c("id", "pos|p-value", "pos|fdr", "pos|rank", "pos|lfc")]
}
r1 <- read_sheet("R1_YFP_Low")
r2 <- read_sheet("R2_YFP_Low")
names(r1) <- c("gene", "r1_pos_p", "r1_pos_fdr", "r1_pos_rank", "r1_pos_lfc")
names(r2) <- c("gene", "r2_pos_p", "r2_pos_fdr", "r2_pos_rank", "r2_pos_lfc")
m <- merge(r1, r2, by = "gene")
m$combined_p <- pmax(m$r1_pos_p, m$r2_pos_p)
m$mean_lfc <- (m$r1_pos_lfc + m$r2_pos_lfc) / 2
m <- m[order(m$combined_p, -m$mean_lfc, m$gene), ]
utils::write.table(m, file.path(paper, "SD1_YFPlow_combined.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
unlink(xlsx)
