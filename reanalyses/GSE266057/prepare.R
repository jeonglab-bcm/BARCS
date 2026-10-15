#!/usr/bin/env Rscript
# GSE266057: builds counts.tsv.gz from the GEO file GSE266057_CRISPRi_counts.tsv.gz.
# The deposited table has an unnamed first column (guide IDs such as
# A1BG_+_58858549.23-P1 or non-targeting_...), which R would read as row names.
# This script names it 'guide', adds 'gene' (the guide ID up to the first
# underscore) and renames the sample columns to short names:
#   "WT, low expression, replicate 1" -> WT_low_1, "77-GA, high expression,
#   replicate 2" -> GA77_high_2, and so on. Counts are unchanged; rows sorted by guide.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
f <- file.path(workdir, "suppl", "GSE266057_CRISPRi_counts.tsv.gz")
con <- gzfile(f)
lines <- readLines(con, warn = FALSE)
close(con)
header <- strsplit(lines[[1]], "\t", fixed = TRUE)[[1]]
header <- header[nzchar(header)]
body <- utils::read.delim(text = lines[-1], header = FALSE, check.names = FALSE,
                          stringsAsFactors = FALSE)
stopifnot(ncol(body) == length(header) + 1L)
short <- sub("^77-GA", "GA77", header)
short <- sub("^(\\w+), (low|high) expression, replicate ([0-9])$", "\\1_\\2_\\3", short)
stopifnot(!anyDuplicated(short), all(grepl("^(WT|GA77)_(low|high)_[12]$", short)))
out <- data.frame(guide = body[[1]], gene = sub("_.*$", "", body[[1]]), body[-1],
                  check.names = FALSE, stringsAsFactors = FALSE)
names(out)[-(1:2)] <- short
out <- out[order(out$guide, method = "radix"), c("guide", "gene", sort(short, method = "radix"))]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
