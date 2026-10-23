#!/usr/bin/env Rscript
# GSE192525 (Llanos et al. 2022 Cell Death Dis, PMID 35184131): GEO deposits only
# GSE192525_transformedRPKM_DEF.txt.gz (CR line endings, a "Number of Alignments"
# header row, then one row per guide "<GENE>|<n>|<strand>(<id>)" with four columns
# 2W-1, 2W-2, CTL-1, CTL-2). The values are raw reads scaled per sample with a
# 0.001 pseudocount added after scaling (an unrounded RPKM/CPM table; the guides
# are a fixed length, so RPKM reduces to one constant per column). This script
# recovers the integer reads with the method of tools/screen-reanalysis/
# recover_counts.R (subtract the offset; scale s = v_min/k refined by least
# squares; accept the smallest k for which >= 99.5% of positive values are within
# 0.02 of an integer), writes counts.tsv and recovery_scales.json, and sets the
# gene to the symbol before the first "|". No non-targeting controls are present.
# Usage: Rscript prepare.R <workdir>   (after fetch_geo.R GSE192525)
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
f <- file.path(workdir, "suppl", "GSE192525_transformedRPKM_DEF.txt.gz")
lines <- readLines(gzfile(f), warn = FALSE)
lines <- unlist(strsplit(lines, "\r"))
lines <- lines[nzchar(lines) & !grepl("^Number of Alignments", lines)]
con <- textConnection(lines)
x <- utils::read.delim(con, check.names = FALSE, stringsAsFactors = FALSE)
close(con)
offset <- 0.001; tol <- 0.02; need <- 0.995
refine <- function(x, s) {
  for (lim in c(20, 100, 1000, 1e4, 1e5, Inf)) {
    sel <- x / s <= lim
    r <- round(x[sel] / s); ok <- r > 0 & abs(x[sel] / s - r) <= 0.25
    if (sum(ok) < 10) next
    s <- sum(x[sel][ok] * r[ok]) / sum(r[ok]^2)
  }
  s
}
rate <- function(x, s) { r <- x / s; mean(abs(r - round(r)) <= tol) }
samples <- setdiff(names(x), "ID")
out <- data.frame(guide = x$ID, gene = sub("\\|.*$", "", x$ID), stringsAsFactors = FALSE)
scales <- list()
for (col in samples) {
  v <- suppressWarnings(as.numeric(x[[col]])); v[is.na(v)] <- 0
  v <- v - offset; v[v < 1e-9] <- 0
  pos <- v[v > 0]; vmin <- min(pos)
  chosen <- NA; s <- NA
  for (k in 1:10) { ss <- refine(pos, vmin / k); if (rate(pos, ss) >= need) { chosen <- k; s <- ss; break } }
  if (is.na(chosen)) stop("recovery failed for ", col)
  out[[col]] <- as.integer(round(v / s))
  scales[[col]] <- list(column = col, offset = offset, v_min = vmin, k = chosen, scale = s,
                        integrality = rate(pos, s), recovered_total = sum(round(v / s)))
}
stopifnot(!anyDuplicated(out$guide))
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
writeLines(jsonlite::toJSON(unname(scales), auto_unbox = TRUE, pretty = TRUE, digits = 10),
           file.path(workdir, "recovery_scales.json"))
