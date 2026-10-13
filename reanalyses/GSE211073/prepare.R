#!/usr/bin/env Rscript
# GSE211073: builds counts.txt.gz from the 19 per-sample CSVs (sample_suppl/,
# from fetch_geo.R --sample-files; columns Guide_1, Guide_2, count) of this
# dual-guide screen. One row per guide pair ("construct" = Guide_1__Guide_2,
# 4,761 pairs in file order), one column per sample in GSM order.
# A guide's gene is its name without "-KO-<n>" (wildtype-PacI and wildtype-I-SceI,
# the non-cutting guides at the two positions, -> "wildtype").
# A construct's "gene" is the sorted, "_"-joined set of its non-control genes:
# control + control -> "control", X + control or X + X -> "X", X + Y -> "X_Y".
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
files <- sort(list.files(file.path(workdir, "sample_suppl"), pattern = "^GSM[0-9]+_.*\\.csv\\.gz$",
                         full.names = TRUE))
stopifnot(length(files) == 19)
tables <- lapply(files, utils::read.csv, check.names = FALSE, stringsAsFactors = FALSE)
pair <- function(x) paste(x$Guide_1, x$Guide_2, sep = "__")
construct <- pair(tables[[1]])
stopifnot(!anyDuplicated(construct))

guide_gene <- function(guide) sub("^wildtype-.*$", "wildtype", sub("-KO-[0-9]+$", "", guide))
label <- mapply(function(a, b) {
  genes <- sort(unique(setdiff(guide_gene(c(a, b)), "control")))
  if (length(genes)) paste(genes, collapse = "_") else "control"
}, tables[[1]]$Guide_1, tables[[1]]$Guide_2, USE.NAMES = FALSE)

counts <- data.frame(construct = construct, guide1 = tables[[1]]$Guide_1,
                     guide2 = tables[[1]]$Guide_2, gene = label)
for (x in tables) {
  stopifnot(setequal(pair(x), construct), all(x[[3]] == round(x[[3]])))
  counts[[names(x)[3]]] <- as.integer(x[[3]][match(construct, pair(x))])
}
out <- gzfile(file.path(workdir, "counts.txt.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)
