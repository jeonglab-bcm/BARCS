#!/usr/bin/env Rscript
# GSE162473 (Zhang et al. 2021 Clin Cancer Res, PMID 33542077): GEO deposits only
# GSE162473_KPT9274.count_normalized.txt.gz, a MAGeCK count_normalized table
# (space-separated, trailing spaces; columns sgRNA, Gene, Day.0, DMSO.R1,
# KPT9274.R1). The values are raw reads scaled by one constant per sample (median
# normalization), so prepare.R recovers the integer reads with the method of
# tools/screen-reanalysis/recover_counts.R (scale s = v_min/k refined by least
# squares; accept the smallest k for which >= 99.5% of positive values are within
# 0.02 of an integer; here every column recovers to 100% integers). Writes
# counts.tsv and recovery_scales.json.
# Usage: Rscript prepare.R <workdir>   (after fetch_geo.R GSE162473)
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
f <- file.path(workdir, "suppl", "GSE162473_KPT9274.count_normalized.txt.gz")
lines <- readLines(gzfile(f), warn = FALSE)
lines <- sub(" +$", "", lines); lines <- gsub(" +", "\t", lines)
con <- textConnection(lines)
x <- utils::read.delim(con, check.names = FALSE, stringsAsFactors = FALSE)
close(con)
tol <- 0.02; need <- 0.995
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
samples <- c("Day.0", "DMSO.R1", "KPT9274.R1")
out <- data.frame(sgRNA = x$sgRNA, gene = x$Gene, stringsAsFactors = FALSE)
scales <- list()
for (col in samples) {
  v <- suppressWarnings(as.numeric(x[[col]])); v[is.na(v)] <- 0
  pos <- v[v > 0]; vmin <- min(pos)
  chosen <- NA; s <- NA
  for (k in 1:10) { ss <- refine(pos, vmin / k); if (rate(pos, ss) >= need) { chosen <- k; s <- ss; break } }
  if (is.na(chosen)) stop("recovery failed for ", col)
  out[[col]] <- as.integer(round(v / s))
  scales[[col]] <- list(column = col, v_min = vmin, k = chosen, scale = s,
                        integrality = rate(pos, s), recovered_total = sum(round(v / s)))
}
stopifnot(!anyDuplicated(out$sgRNA))
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
writeLines(jsonlite::toJSON(unname(scales), auto_unbox = TRUE, pretty = TRUE, digits = 10),
           file.path(workdir, "recovery_scales.json"))
