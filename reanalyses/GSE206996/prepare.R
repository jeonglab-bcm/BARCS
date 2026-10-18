#!/usr/bin/env Rscript
# GSE206996: the GEO count file holds three screens side by side (Spike-mNeonGreen,
# VSVG-mNeonGreen, VSVG-Cre), each block "sgRNA Gene Pre Input Low High" in its
# own row order, under two title lines. This splits it into one count file per
# screen (counts unchanged): counts_spike.tsv.gz, counts_vsvg.tsv.gz,
# counts_vsvgcre.tsv.gz, rows sorted by guide ID.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.delim(gzfile(file.path(workdir, "suppl", "GSE206996_Count.files.txt.gz")),
                       header = FALSE, skip = 3, colClasses = "character",
                       stringsAsFactors = FALSE)
blocks <- list(spike = 1:6, vsvg = 8:13, vsvgcre = 15:20)
for (nm in names(blocks)) {
  b <- x[, blocks[[nm]]]
  names(b) <- c("sgRNA", "Gene", "Pre", "Input", "Low", "High")
  b <- b[b$sgRNA != "", ]
  for (k in 3:6) b[[k]] <- as.integer(b[[k]])
  b <- b[order(b$sgRNA, method = "radix"), ]
  con <- gzfile(file.path(workdir, paste0("counts_", nm, ".tsv.gz")), "w")
  utils::write.table(b, con, sep = "\t", quote = FALSE, row.names = FALSE)
  close(con)
}
