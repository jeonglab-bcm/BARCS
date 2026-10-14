#!/usr/bin/env Rscript
# GSE290153: builds coupled_counts.tsv.gz, the merged paired-construct count
# matrix for this combinatorial dual-guide DNA-repair screen (Olivieri et al.,
# PMID 41546867). GEO deposits two files with no series-level matrix:
#   GSE290153_IR_grna1_coupled_counts.tsv.gz    (IR_day15_rep1, IR_day15_rep2)
#   GSE290153_fullbasal_grna1_coupled_counts.tsv.gz (day0/day14 rep1-3)
# They are merged on the construct id (gene1_sgX;gene2_sgY) over the 809,460
# constructs shared by both. Kept columns: day14_rep1, day14_rep2 (control end
# point) and IR_day15_rep1, IR_day15_rep2 (irradiated). A construct's "gene" is
# the sorted, "_"-joined set of its non-control target genes (guide "Gene_sgN"
# -> "Gene", control guide "nt_N" -> dropped): nt+nt -> "nt" (control), G+nt or
# G+G -> "G" (single-gene abundance), A+B -> "A_B" (pair label; its genetic-
# interaction meaning is OUT OF SCOPE for BARCS's single-construct model).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
rd <- function(f) {
  d <- utils::read.delim(gzfile(file.path(workdir, "suppl", f)), check.names = FALSE,
                         stringsAsFactors = FALSE)
  names(d)[1] <- "construct"; d
}
ir <- rd("GSE290153_IR_grna1_coupled_counts.tsv.gz")
ba <- rd("GSE290153_fullbasal_grna1_coupled_counts.tsv.gz")
m <- merge(ba[, c("construct", "day14_rep1", "day14_rep2")],
           ir[, c("construct", "IR_day15_rep1", "IR_day15_rep2")], by = "construct")
m <- m[order(m$construct), ]
gene_of <- function(ids) {
  parts <- strsplit(ids, ";", fixed = TRUE)
  vapply(parts, function(p) {
    g <- sub("_sg[0-9]+$", "", p)
    g <- g[!grepl("^nt_[0-9]+$", p)]
    g <- sort(unique(g))
    if (length(g)) paste(g, collapse = "_") else "nt"
  }, character(1))
}
gene <- gene_of(m$construct)
# Keep only single-gene constructs (a gene paired with a non-targeting guide, or
# the same gene twice) and the nt+nt controls. The gene-pair constructs ("A_B",
# ~94% of the library) are the paper's genetic-interaction units, which BARCS's
# single-gene model cannot represent, and aggregating hundreds of thousands of
# singleton pair groups is both meaningless here and intractable; they are
# dropped so the gene-level output is purely single-gene abundance.
keep <- !grepl("_", gene)
out <- data.frame(construct = m$construct[keep], gene = gene[keep],
                  m[keep, c("day14_rep1", "day14_rep2", "IR_day15_rep1", "IR_day15_rep2")],
                  check.names = FALSE)
gz <- gzfile(file.path(workdir, "coupled_counts.tsv.gz"), "w")
utils::write.table(out, gz, sep = "\t", quote = FALSE, row.names = FALSE)
close(gz)
cat("Wrote coupled_counts.tsv.gz:", nrow(out), "constructs\n")
