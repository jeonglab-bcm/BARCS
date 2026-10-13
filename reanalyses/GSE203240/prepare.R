# Builds paper/TableS7_in_vivo.tsv, the paper's Table S7 (in vivo CRISPR
# screen hits: score, p-value and rank for the 15 hits; Cell Genomics 2025,
# doi:10.1016/j.xgen.2025.100876, PMC12230241). Table S7 is the publisher's
# mmc8.xlsx; it is kept as paper/TableS7_in_vivo.xlsx and converted to a
# tab-separated table with columns gene, gene_id, score, p_value, rank. The
# paper's PEAK3 is renamed C19orf35, its symbol in the library. The count file
# is the GEO file as deposited.
#
#   Rscript reanalyses/GSE203240/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
paper <- file.path(workdir, "paper")
dir.create(paper, showWarnings = FALSE)
xlsx <- file.path(paper, "TableS7_in_vivo.xlsx")
utils::download.file("https://ars.els-cdn.com/content/image/1-s2.0-S2666979X25001326-mmc8.xlsx",
                     xlsx, mode = "wb", quiet = TRUE)

x <- as.data.frame(readxl::read_excel(xlsx, skip = 2))
out <- data.frame(gene = sub("^PEAK3$", "C19orf35", x[["Gene Symbol"]]), gene_id = x[["Gene ID"]],
                  score = x[["Score"]], p_value = x[["p-value"]], rank = x[["Rank"]])
utils::write.table(out, file.path(paper, "TableS7_in_vivo.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
