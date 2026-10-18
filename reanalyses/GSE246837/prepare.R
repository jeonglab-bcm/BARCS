#!/usr/bin/env Rscript
# GSE246837: merges the eleven per-sample guideCounts files (two columns:
# read count, guide id "<Gene>_<transcript>_<position>") into one count matrix
# (counts.tsv.gz). Guides missing from a file had zero reads in that library
# and are filled with 0; the unmapped line ("*") is dropped. Gene is the part
# of the guide id before the first underscore ("Control" for the 1,000 Brie
# non-targeting guides). Counts are unchanged.
# Requires fetch_geo.R --sample-files (design.json "fetch": {"sample_files": true}).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
sd <- file.path(workdir, "sample_suppl")
files <- c(
  ETP         = "GSM7879976_M3i-CCS-AG02-B16-Ova-Cas9-Nil-ETP_S1.guideCounts.txt.gz",
  Ctrl_DMSO   = "GSM7879975_M3i-CCS-AG02-B16-Ova-Cas9-DMSO-Ctrl_S2.guideCounts.txt.gz",
  Ctrl_M3iL   = "GSM7879974_M3i-CCS-AG02-B16-Ova-Cas9-2457L-Ctrl_S3.guideCounts.txt.gz",
  Ctrl_M3iH   = "GSM7879973_M3i-CCS-AG02-B16-Ova-Cas9-2457H-Ctrl_S4.guideCounts.txt.gz",
  ET1_5_DMSO  = "GSM7879972_M3i-CCS-AG02-B16-Ova-Cas9-1-5-DMSO_S5.guideCounts.txt.gz",
  ET1_5_M3iL  = "GSM7879971_M3i-CCS-AG02-B16-Ova-Cas9-1-5-2457L_S6.guideCounts.txt.gz",
  ET1_5_M3iH  = "GSM7879970_M3i-CCS-AG02-B16-Ova-Cas9-1-5-2457H_S7.guideCounts.txt.gz",
  ET1_20_DMSO = "GSM7879969_M3i-CCS-AG02-B16-Ova-Cas9-1-20-DMSO_S8.guideCounts.txt.gz",
  ET1_20_M3iL = "GSM7879968_M3i-CCS-AG02-B16-Ova-Cas9-1-20-2457L_S9.guideCounts.txt.gz",
  ET1_1_DMSO  = "GSM7879967_M3i-CCS-AG02-B16-Ova-Cas9-1-1-DMSO_S10.guideCounts.txt.gz",
  ET1_1_M3iH  = "GSM7879966_M3i-CCS-AG02-B16-Ova-Cas9-1-1-2457H_S11.guideCounts.txt.gz"
)
rd <- function(f) {
  x <- utils::read.table(gzfile(file.path(sd, f)), header = FALSE, sep = "",
                         quote = "", comment.char = "",
                         col.names = c("count", "sgRNA"),
                         colClasses = c("numeric", "character"))
  x <- x[x$sgRNA != "*", ]
  stopifnot(!anyDuplicated(x$sgRNA), all(x$count == round(x$count)))
  stats::setNames(x$count, x$sgRNA)
}
cnt <- lapply(files, rd)
ids <- unique(unlist(lapply(cnt, names), use.names = FALSE))
ids <- ids[order(ids, method = "radix")]
m <- data.frame(sgRNA = ids, Gene = sub("_.*$", "", ids),
                stringsAsFactors = FALSE)
for (s in names(files)) {
  v <- unname(cnt[[s]][ids])
  v[is.na(v)] <- 0
  m[[s]] <- as.integer(v)
}
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(m, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
