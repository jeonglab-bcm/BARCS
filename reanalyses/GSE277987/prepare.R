# Builds counts_lanes_summed.tsv.gz from the per-lane count table.
#
# suppl/GSE277987_mapped.count.txt.gz (GEO series supplement) has one column
# per sample and sequencing lane (R{screen}_{B,H,L,T0}_L{1-4}; each lane is
# its own GSM) plus unassigned_L1-4 (reads without a sample index). Lanes of
# one sample are technical re-reads of the same library (r = 0.98), so they
# are summed per sample; the unassigned columns are dropped.
#
# Published table: paper/fig3b_high_vs_low.csv is sheet "Fig.3b" of the
# Source Data for Fig. 3 (41589_2025_1949_MOESM6_ESM.xlsx, Nature Chemical
# Biology): the paper's limma gene results for the 'high' vs 'low' Kinprola
# PKA-labeled populations (Geneid, gene_name, mean_fc, pval, fdr), unchanged.
#
#   Rscript work/GSE277987/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.delim(gzfile(file.path(workdir, "suppl", "GSE277987_mapped.count.txt.gz")),
                       check.names = FALSE, stringsAsFactors = FALSE)
lanes <- grep("^R[0-9]+_(B|H|L|T0)_L[1-4]$", names(x), value = TRUE)
sample <- sub("_L[1-4]$", "", lanes)
summed <- sapply(unique(sample), function(s) rowSums(as.matrix(x[, lanes[sample == s], drop = FALSE])))
out <- data.frame(sgRNA = x$sgRNA, Gene = x$Gene, summed, check.names = FALSE, stringsAsFactors = FALSE)
con <- gzfile(file.path(workdir, "counts_lanes_summed.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

xlsx <- file.path(tempdir(), "41589_2025_1949_MOESM6_ESM.xlsx")
utils::download.file(paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs41589-025-01949-6/",
                            "MediaObjects/41589_2025_1949_MOESM6_ESM.xlsx"),
                     xlsx, mode = "wb", quiet = TRUE)
fig3b <- as.data.frame(readxl::read_excel(xlsx, sheet = "Fig.3b"))
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
utils::write.csv(fig3b[, c("Geneid", "gene_name", "R1", "R2", "pval", "tstat", "fdr", "mean_fc", "significant")],
                 file.path(workdir, "paper", "fig3b_high_vs_low.csv"), row.names = FALSE)
