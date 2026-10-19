#!/usr/bin/env Rscript
# GSE253884 (Toxoplasma Unassigned_1 in vivo CRISPR screen, PMID 39082802).
# Builds counts.tsv by joining the 12 per-sample GEO count files
# (sample_suppl/, from fetch_geo.R --sample-files) on the gRNA id. Each file
# has two unlabelled columns: gRNA id and read count. Column labels come from
# the file names: lib -> Lib (plasmid input), P4 (in vitro passage 4),
# WT_01..WT_10 (parasites recovered from ten infected mouse spleens). The gene
# id is the gRNA id with its trailing _<n> stripped (verified identical to the
# Un1_gRNA sheet mapping). Counts are unchanged; rows sorted by gRNA id.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
files <- list.files(file.path(workdir, "sample_suppl"),
                    pattern = "\\.txt\\.gz$", full.names = TRUE)
stopifnot(length(files) == 12)
tag_of <- function(f) {
  t <- sub("^GSM[0-9]+_unassigned_1_(.*)\\.txt\\.gz$", "\\1", basename(f))
  if (identical(t, "lib")) "Lib" else t
}
counts <- NULL
for (f in files) {
  d <- utils::read.delim(f, header = FALSE, stringsAsFactors = FALSE)
  stopifnot(ncol(d) == 2L, all(d[[2]] == round(d[[2]])))
  names(d) <- c("guide", tag_of(f))
  counts <- if (is.null(counts)) d else merge(counts, d, by = "guide", all = TRUE)
}
stopifnot(!anyNA(counts), nrow(counts) == 2944)
counts$gene <- sub("_[0-9]+$", "", counts$guide)
order_cols <- c("guide", "gene", "Lib", "P4", sprintf("WT_%02d", 1:10))
counts <- counts[, order_cols]
counts <- counts[order(counts$guide, method = "radix"), ]
out <- file.path(workdir, "counts.tsv")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
