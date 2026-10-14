# Builds paper/mageck.tsv, the authors' published gene-level result (Dox+ vs
# Dox-), from the GEO MAGeCK gene summary suppl/GSE316868_MAGeCK.txt.gz. It
# keeps one row per gene with p_min = the smaller of the negative and positive
# MAGeCK p-values, lfc = the MAGeCK log fold change (neg|lfc) and both MAGeCK
# ranks. The count file is the GEO file as deposited.
#
#   Rscript reanalyses/GSE316868/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.delim(file.path(workdir, "suppl", "GSE316868_MAGeCK.txt.gz"), check.names = FALSE)
out <- data.frame(gene = x$id, p_min = pmin(x[["neg|p-value"]], x[["pos|p-value"]]),
                  lfc = x[["neg|lfc"]], neg_rank = x[["neg|rank"]], pos_rank = x[["pos|rank"]])
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
utils::write.table(out, file.path(workdir, "paper", "mageck.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
