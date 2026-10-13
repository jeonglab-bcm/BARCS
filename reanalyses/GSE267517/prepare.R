# Builds paper/mageck_et1_ctrl.tsv, the authors' published gene-level result
# for the ET1 (T cells, effector:target 1) vs no-T-cell comparison, from the
# GEO MAGeCK gene summary suppl/GSE267517_Mouse_v2_CRISPR_191205_ET1_Ctrl.
# gene_summary.txt.gz. It keeps one row per gene with p_min = the smaller of
# the negative and positive MAGeCK p-values, lfc = the MAGeCK log fold change
# (neg|lfc) and both MAGeCK ranks. The count file is the GEO file as deposited.
#
#   Rscript reanalyses/GSE267517/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.delim(file.path(workdir, "suppl",
                                 "GSE267517_Mouse_v2_CRISPR_191205_ET1_Ctrl.gene_summary.txt.gz"),
                       check.names = FALSE)
out <- data.frame(gene = x$id, p_min = pmin(x[["neg|p-value"]], x[["pos|p-value"]]),
                  lfc = x[["neg|lfc"]], neg_rank = x[["neg|rank"]], pos_rank = x[["pos|rank"]])
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
utils::write.table(out, file.path(workdir, "paper", "mageck_et1_ctrl.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
