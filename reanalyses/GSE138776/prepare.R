#!/usr/bin/env Rscript
# GSE138776: builds GSE138776_crispr_counts.tsv from the deposited
# GSE138776_data_crisprScreen.xlsx (sheet "sgRNA_tagcount_above_30"): the
# genome-wide CRISPR m6A-GFP reporter screen in HeLa. Keeps the guide id
# (UID), the gene (gene_id) and the two raw count columns HighGFP and LowGFP;
# the log2 and ratio columns are dropped. Non-targeting guides are "dummyguide".
# (The series' m6A-seq and RNA-seq files are a companion assay and are not used.)
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- as.data.frame(readxl::read_excel(
  file.path(workdir, "suppl", "GSE138776_data_crisprScreen.xlsx"),
  sheet = "sgRNA_tagcount_above_30"))
stopifnot(all(c("UID", "gene_id", "HighGFP", "LowGFP") %in% names(x)),
          all(x$HighGFP == round(x$HighGFP)), all(x$LowGFP == round(x$LowGFP)))
out <- data.frame(UID = x$UID, gene_id = x$gene_id,
                  HighGFP = as.integer(x$HighGFP), LowGFP = as.integer(x$LowGFP))
out <- out[order(out$UID, method = "radix"), ]
utils::write.table(out, file.path(workdir, "GSE138776_crispr_counts.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
