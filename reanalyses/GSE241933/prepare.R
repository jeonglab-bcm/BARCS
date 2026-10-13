# Builds the three count tables used by this record and the paper's gene-level
# CRISPRa table.
#
# Counts: the GEO tables suppl/GSE241933_<screen>.counts.table.csv.gz
# (CRISPRa CCR7 screen and the two TFome knockout screens) are written
# tab-separated as <screen>.counts_with_gene.tsv.gz, with the gRNA sequence
# column replaced by the gene name (the gRNA name without its trailing "_N").
# Counts are unchanged.
#
# Published table: paper/T2F_gene_level_CRISPRa.tsv is sheet "T2F Gene-level
# CRISPRa screen" (Supplementary Table 2F) of the Nature Genetics supplement
# 41588_2023_1554_MOESM3_ESM.xlsx: columns gene, gene_p, gene_padj, gene_effect.
#
#   Rscript reanalyses/GSE241933/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]

for (screen in c("CRISPRa.TF.CCR7", "CRISPR.TFome.ko.with.BATF3",
                 "CRISPR.TFome.ko.without.BATF3")) {
  raw <- utils::read.csv(file.path(workdir, "suppl", sprintf("GSE241933_%s.counts.table.csv.gz", screen)),
                         check.names = FALSE, colClasses = "character")
  raw[["gRNA sequence"]] <- sub("_[^_]*$", "", raw$gRNA)
  names(raw)[names(raw) == "gRNA sequence"] <- "gene"
  out <- gzfile(file.path(workdir, sprintf("%s.counts_with_gene.tsv.gz", screen)), "w")
  utils::write.table(raw, out, sep = "\t", quote = FALSE, row.names = FALSE)
  close(out)
}

xlsx <- file.path(tempdir(), "41588_2023_1554_MOESM3_ESM.xlsx")
utils::download.file(paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs41588-023-01554-0/",
                            "MediaObjects/41588_2023_1554_MOESM3_ESM.xlsx"),
                     xlsx, mode = "wb", quiet = TRUE)
t2f <- as.data.frame(readxl::read_excel(xlsx, sheet = "T2F Gene-level CRISPRa screen",
                                        .name_repair = "minimal"))
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
utils::write.table(t2f[, c("gene", "gene_p", "gene_padj", "gene_effect")],
                   file.path(workdir, "paper", "T2F_gene_level_CRISPRa.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
