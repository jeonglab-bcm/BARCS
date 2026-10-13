# Builds paper/mle_kpk_minus_kp.tsv, the authors' ranking for KPK-specific
# dependencies, from the GEO MAGeCK-MLE gene summary
# suppl/GSE220831_KP_KPK_mle_normalized3.gene_summary.txt.gz: per gene the KP
# and KPK beta scores, their difference KPK - KP (the score the paper ranks
# by, to 6 significant digits) and the two MAGeCK-MLE FDRs. The count file is
# the GEO file as deposited.
#
#   Rscript reanalyses/GSE220831/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.delim(file.path(workdir, "suppl", "GSE220831_KP_KPK_mle_normalized3.gene_summary.txt.gz"),
                       check.names = FALSE)
out <- data.frame(gene = x$Gene, KP_beta = x[["KP|beta"]], KPK_beta = x[["KPK|beta"]],
                  KPK_minus_KP_beta = signif(x[["KPK|beta"]] - x[["KP|beta"]], 6),
                  KP_fdr = x[["KP|fdr"]], KPK_fdr = x[["KPK|fdr"]])
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
utils::write.table(out, file.path(workdir, "paper", "mle_kpk_minus_kp.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
