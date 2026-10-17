#!/usr/bin/env Rscript
# GSE217789: adds a gene-symbol column to the GEO count table
# (GSE217789_rbm3-tun-library.csv.gz; gene names are "<Ensembl ID>_<symbol>").
# symbol = the part after the Ensembl ID; for the two symbols shared by two
# Ensembl IDs (RABGEF1, STPG4) the full name is kept so genes are not merged.
# Non-targeting guides keep their names (NonTargetingGuide001..399). Counts are
# unchanged. Writes counts_symbols.tsv.gz.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.csv(gzfile(file.path(workdir, "suppl", "GSE217789_rbm3-tun-library.csv.gz")),
                     check.names = FALSE, stringsAsFactors = FALSE)
sym <- sub("^ENSG[0-9]+_", "", x$geneName)
ids <- unique(x$geneName)
dup <- unique(sub("^ENSG[0-9]+_", "", ids)[duplicated(sub("^ENSG[0-9]+_", "", ids))])
sym[sym %in% dup] <- x$geneName[sym %in% dup]
out <- data.frame(libID = x$libID, gene = sym, x[, -(1:2)], check.names = FALSE)
out <- out[order(out$libID, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts_symbols.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
