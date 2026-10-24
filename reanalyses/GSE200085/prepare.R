#!/usr/bin/env Rscript
# GSE200085: builds counts.tsv.gz for the in vivo Brunello knockout screen in
# SC-islet grafts. GEO lists only one of the sample's files, so the series
# RAW tar is downloaded from the GEO FTP site and the PoolQ condition-level
# count table (GSM6008413_counts-JD_GPP2373_2901507_Sintov_20210224.txt.gz:
# guide sequence, Broad id, one column per mouse graft plus pre-transplant,
# NTC and plasmid libraries) is taken from it. PoolQ's counts table already
# sums the PCR barcodes of each condition. It carries no gene, so genes come
# from another GEO deposit of the same Brunello library with gene labels
# (GSE226447_AMA.count.txt.gz, guide ids <Gene>_<n>_<20nt sequence>, joined on
# the sequence); Brunello's non-targeting guides are labelled
# "Non-Targeting-Control" there. Counts are unchanged; columns are renamed to
# syntactic names (Ms #64 Ctrl -> Ms64_Ctrl) and rows sorted by sequence.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
options(timeout = 1800)  # the Europe PMC and GEO bundles are large
raw_dir <- file.path(workdir, "raw")
dir.create(raw_dir, showWarnings = FALSE)
tar <- file.path(raw_dir, "GSE200085_RAW.tar")
if (!file.exists(tar)) {
  utils::download.file("https://ftp.ncbi.nlm.nih.gov/geo/series/GSE200nnn/GSE200085/suppl/GSE200085_RAW.tar",
                       tar, mode = "wb", quiet = TRUE)
}
member <- "GSM6008413_counts-JD_GPP2373_2901507_Sintov_20210224.txt.gz"
utils::untar(tar, files = member, exdir = raw_dir)
counts <- utils::read.delim(file.path(raw_dir, member), check.names = FALSE,
                            stringsAsFactors = FALSE)
counts <- counts[, nzchar(names(counts)), drop = FALSE]
samples <- setdiff(names(counts), c("Construct Barcode", "Construct IDs"))
stopifnot(length(samples) == 15)
stopifnot(all(vapply(counts[samples], function(v) all(v == round(v)), logical(1))))

annot_file <- file.path(raw_dir, "GSE226447_AMA.count.txt.gz")
if (!file.exists(annot_file)) {
  utils::download.file("https://ftp.ncbi.nlm.nih.gov/geo/series/GSE226nnn/GSE226447/suppl/GSE226447_AMA.count.txt.gz",
                       annot_file, mode = "wb", quiet = TRUE)
}
annot <- utils::read.delim(annot_file, stringsAsFactors = FALSE)[, c("sgRNA", "Gene")]
annot$seq <- sub("^.*_", "", annot$sgRNA)
stopifnot(all(nchar(annot$seq) == 20), !anyDuplicated(annot$seq))
gene <- annot$Gene[match(counts[["Construct Barcode"]], annot$seq)]
stopifnot(!anyNA(gene))

clean <- gsub("[^A-Za-z0-9]+", "_", sub("^Ms #", "Ms", samples))
clean <- sub("_$", "", clean)
out <- data.frame(sgRNA = counts[["Construct Barcode"]], Gene = gene, counts[samples],
                  check.names = FALSE, stringsAsFactors = FALSE)
names(out) <- c("sgRNA", "Gene", clean)
out <- out[order(out$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

# The paper's gene-level results: Data S1 of Sintov et al. 2022 Stem Cell
# Reports (doi 10.1016/j.stemcr.2022.08.002), sheet "Fig3 - in vivo CRISPR
# screen" (gene, fold change, -log10 BH FDR of the KO x PBMC interaction from
# a negative-binomial mixed model; 11,689 genes after an expression filter).
# Downloaded from the Europe PMC supplementary-file bundle of PMC9481918 and
# written to paper/invivo_screen.tsv with a signed score
# sign(fold change) * -log10(FDR) (positive = enriched in hPi grafts).
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "mmc2.xlsx")
if (!file.exists(xl)) {
  zip <- tempfile(fileext = ".zip")
  utils::download.file("https://www.ebi.ac.uk/europepmc/webservices/rest/PMC9481918/supplementaryFiles",
                       zip, mode = "wb", quiet = TRUE)
  utils::unzip(zip, files = "mmc2.xlsx", exdir = file.path(workdir, "paper"))
  unlink(zip)
}
p <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "Fig3 - in vivo CRISPR screen", skip = 1)))
names(p) <- c("gene", "fold_change", "neg_log10_fdr")
p <- p[!is.na(p$gene), ]
p$fdr <- signif(10^-p$neg_log10_fdr, 6)
p$signed_score <- signif(sign(p$fold_change) * p$neg_log10_fdr, 6)
utils::write.table(p, file.path(workdir, "paper", "invivo_screen.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
