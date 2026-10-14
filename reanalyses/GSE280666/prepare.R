#!/usr/bin/env Rscript
# GSE280666: builds counts_utf8.tsv.gz, the deposited long-term screen table
# GSE280666_LongTermScreen_raw_counts.txt.gz (UTF-16LE with a byte-order mark
# and CRLF line ends, which read.delim cannot read) converted unchanged to
# UTF-8 text with LF line ends. Same header, rows and values.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
con <- gzfile(file.path(workdir, "suppl", "GSE280666_LongTermScreen_raw_counts.txt.gz"),
              encoding = "UTF-16LE")
lines <- readLines(con, warn = FALSE)
close(con)
lines[1] <- sub("^﻿", "", lines[1])
lines <- sub("\r$", "", lines)
out <- gzfile(file.path(workdir, "counts_utf8.tsv.gz"), "w")
writeLines(lines, out)
close(out)
