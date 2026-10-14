# Builds genomewide_counts.tsv.gz for GSE253290: the genome-wide lncRNA
# CRISPRa count table with one row per sgRNA and Ensembl gene.
#
# GSE253290_totalcount_CDK_genomewide.csv.gz lists each sgRNA once per
# GENCODE v19 transcript it was annotated to (134,177 rows, 52,303 sgRNAs;
# the counts of repeated rows are identical). Transcripts are mapped to genes
# with the paper's Supplementary Dataset 1 (Transcript -> Gene); transcripts
# not in that table keep their ENST ID. Rows are then collapsed to one per
# sgRNA and gene (65,015 rows): an sgRNA annotated to transcripts of several
# overlapping genes stays in each of them, as in the paper's MAGeCK analysis,
# with the ID '<sgRNA>:<gene>'. This counts those reads more than once in the
# library totals, by the same factor in every library (1.306-1.309 for S2-S5),
# so the relative totals are unaffected. Non-targeting guides keep the label
# 'nontargeting'.
#
# It also fetches the paper's Supplementary Datasets 1 (genome-wide MAGeCK MLE
# results, one row per transcript) and 2 (focused-screen results) into paper/,
# and writes paper/Dataset1_genes.csv for compare.json: one row per gene, the
# transcript with the smallest palbociclib ('treatment') Wald p-value.
#
#   Rscript work/GSE253290/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
fetch <- function(path, url) {
  if (!file.exists(path)) {
    dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
    utils::download.file(url, path, mode = "wb", quiet = TRUE)
  }
  path
}
esm <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-026-70816-2/MediaObjects/41467_2026_70816_MOESM"
ds1 <- fetch(file.path(workdir, "paper", "SupplementaryDataset1_genomewide.xlsx"), paste0(esm, "3_ESM.xlsx"))
invisible(fetch(file.path(workdir, "paper", "SupplementaryDataset2_focused.xlsx"), paste0(esm, "4_ESM.xlsx")))
counts_path <- fetch(file.path(workdir, "suppl", "GSE253290_totalcount_CDK_genomewide.csv.gz"),
                     "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE253nnn/GSE253290/suppl/GSE253290_totalcount_CDK_genomewide.csv.gz")

map <- as.data.frame(suppressWarnings(readxl::read_excel(ds1, skip = 26)))
stopifnot(identical(names(map)[1:2], c("Transcript", "Gene")), !anyDuplicated(map$Transcript))
x <- utils::read.csv(counts_path, stringsAsFactors = FALSE)
samples <- c("S1", "S2", "S3", "S4", "S5")
stopifnot(identical(names(x), c("sgRNA", "Gene", samples)))
# Repeated rows of one sgRNA must carry identical counts.
first <- x[!duplicated(x$sgRNA), c("sgRNA", samples)]
stopifnot(all(as.matrix(x[, samples]) == as.matrix(first[match(x$sgRNA, first$sgRNA), samples])))
gene <- map$Gene[match(x$Gene, map$Transcript)]
gene[is.na(gene)] <- x$Gene[is.na(gene)]
keep <- !duplicated(paste(x$sgRNA, gene))
out <- data.frame(guide = paste0(x$sgRNA[keep], ":", gene[keep]), gene = gene[keep],
                  x[keep, samples], stringsAsFactors = FALSE)
stopifnot(!anyDuplicated(out$guide))
con <- gzfile(file.path(workdir, "genomewide_counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

res <- map[, c("Gene", "gene_name", "treatment|beta", "treatment|wald-p-value", "treatment|wald-fdr")]
names(res) <- c("gene", "gene_name", "beta", "p_value", "fdr")
for (v in c("beta", "p_value", "fdr")) res[[v]] <- as.numeric(res[[v]])
res <- res[order(res$gene, res$p_value), ]
res <- res[!duplicated(res$gene), ]
utils::write.csv(res, file.path(workdir, "paper", "Dataset1_genes.csv"), row.names = FALSE)
