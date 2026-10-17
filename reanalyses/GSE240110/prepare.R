#!/usr/bin/env Rscript
# GSE240110: merges the 36 per-sample count files (each "guide_id<TAB>count",
# no header) into one count matrix (counts.tsv.gz). The guide id embeds the gene
# as its first underscore-delimited field (e.g. GRM5_exon_03_..._GRM5_-_SEQ;
# control guides are LacZ_CTRL_..., luciferase_CTRL_..., EGFP_CTRL_...). Column
# names are the sample label from the filename (cell line + condition + replicate,
# e.g. H2030-MRTX1). Counts unchanged; rows sorted by guide id.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
sd <- file.path(workdir, "sample_suppl")
files <- list.files(sd, pattern = "\\.txt\\.gz$")
label <- sub("^GSM[0-9]+_", "", sub("\\.txt\\.gz$", "", files))
label <- sub("_.*$", "", label)              # drop _SM.../_ct suffixes
tabs <- lapply(files, function(f) {
  x <- utils::read.delim(gzfile(file.path(sd, f)), header = FALSE,
                         col.names = c("guide", "count"), stringsAsFactors = FALSE)
  x[order(x$guide, method = "radix"), ]
})
guides <- tabs[[1]]$guide
for (t in tabs) if (!identical(t$guide, guides))
  stop("guide sets differ across files")       # same ids, re-sorted per file above
m <- data.frame(sgRNA = guides,
                Gene = sub("_.*$", "", guides),
                stringsAsFactors = FALSE)
for (i in seq_along(tabs)) m[[label[i]]] <- as.integer(tabs[[i]]$count)
m <- m[order(m$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(m, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
