#!/usr/bin/env Rscript
# Recover raw read counts from a table normalized by one constant per sample
# (MAGeCK median normalization, CPM). For each column: v_min = smallest positive
# value; for k in 1..10, s = v_min / k; accept the smallest k for which x / s is
# within `tol` of an integer for >= 99.5% of positive values.
#
#   Rscript tools/screen-reanalysis/recover_counts.R <table> <out.tsv> <id_cols (comma)> <sample_cols (comma) | ALL> [sheet] [skip]
suppressPackageStartupMessages(library(jsonlite))
args <- commandArgs(trailingOnly = TRUE)
path <- args[[1]]; out <- args[[2]]
id_cols <- strsplit(args[[3]], ",")[[1]]
sheet <- if (length(args) >= 5 && nzchar(args[[5]])) args[[5]] else 1
skip <- if (length(args) >= 6) as.integer(args[[6]]) else 0L
tol <- 0.02; need <- 0.995
kmax <- as.integer(Sys.getenv("RECOVER_KMAX", "10"))
offset <- as.numeric(Sys.getenv("RECOVER_OFFSET", "0"))  # pseudocount added after scaling (subtracted first)
read_tab <- function(p) {
  if (grepl("\\.xlsx?$", p)) {
    sh <- suppressWarnings(as.integer(sheet)); if (is.na(sh)) sh <- sheet
    return(as.data.frame(readxl::read_excel(p, sheet = sh, skip = skip)))
  }
  con <- if (grepl("\\.gz$", p)) gzfile(p) else p
  first <- readLines(if (grepl("\\.gz$", p)) gzfile(p) else p, n = 1L)
  utils::read.delim(con, sep = if (grepl("\t", first)) "\t" else ",", check.names = FALSE,
                    stringsAsFactors = FALSE, skip = skip)
}
tab <- read_tab(path)
sample_cols <- if (identical(args[[4]], "ALL")) setdiff(names(tab), id_cols) else strsplit(args[[4]], ",")[[1]]
check <- function(x, s) { r <- x / s; mean(abs(r - round(r)) <= tol) }
# v_min may itself be printed with limited precision; refine s by least squares
# on values whose integer is unambiguous, widening the range step by step.
refine <- function(x, s) {
  for (lim in c(20, 100, 1000, 1e4, 1e5, Inf)) {
    sel <- x / s <= lim
    r <- round(x[sel] / s); ok <- r > 0 & abs(x[sel] / s - r) <= 0.25
    if (sum(ok) < 10) next
    s <- sum(x[sel][ok] * r[ok]) / sum(r[ok]^2)
  }
  s
}
# Decimal quantum of the printed values: a "scale" equal to a small multiple of it
# only says the values are rounded to that many decimals (trivial pass).
quantum <- function(x) { d <- 0; while (d < 12 && any(abs(x * 10^d - round(x * 10^d)) > 1e-7 * pmax(1, x * 10^d))) d <- d + 1; 10^-d }
res <- list(); rec <- tab[, id_cols, drop = FALSE]
for (col in sample_cols) {
  x <- suppressWarnings(as.numeric(tab[[col]])); x[is.na(x)] <- 0
  if (offset != 0) x <- x - offset
  x[abs(x) < 1e-9] <- 0
  pos <- x[x > 0]; vmin <- min(pos)
  q <- quantum(pos)
  scales <- sapply(seq_len(kmax), function(k) refine(pos, vmin / k))
  trivial <- abs(scales / q - round(scales / q)) < 1e-6 & scales / q < 10.5
  rates <- sapply(seq_len(kmax), function(k) check(pos, scales[k]))
  rates[trivial] <- 0
  k <- which(rates >= need)[1]
  ok <- !is.na(k)
  s <- if (ok) scales[k] else NA
  int_rate <- if (ok) rates[k] else max(rates)
  maxdev <- if (ok) max(abs(pos / s - round(pos / s))) else NA
  res[[col]] <- list(column = col, offset = offset, v_min = vmin, k = if (ok) k else NA, scale = s,
                     integrality = int_rate, rates_k1_10 = round(rates, 4), max_dev = maxdev,
                     recovered_total = if (ok) sum(round(x / s)) else NA,
                     nonzero = length(pos), n = length(x))
  cat(sprintf("%-30s vmin=%-12.6g best k=%-3s scale=%-12.6g integrality=%.4f maxdev=%s total=%s\n",
              col, vmin, ifelse(ok, k, "NA"), ifelse(ok, s, NA), int_rate,
              format(maxdev, digits = 3), format(res[[col]]$recovered_total, big.mark = ",")))
  cat("   rates k=1..10:", paste(round(head(rates,10), 3), collapse = " "), "\n")
  if (ok) rec[[col]] <- as.integer(round(x / s))
}
all_ok <- all(vapply(res, function(r) !is.na(r$scale), logical(1)))
if (out != "-") {
  if (all_ok) {
    utils::write.table(rec, out, sep = "\t", quote = FALSE, row.names = FALSE)
    write_json(unname(res), sub("\\.tsv$", "_scales.json", out), auto_unbox = TRUE, pretty = TRUE, digits = NA)
    cat("Wrote", out, "\n")
  } else cat("Not all columns pass; nothing written.\n")
}
