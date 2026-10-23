#!/usr/bin/env Rscript
# GSE169108 (Sun et al. 2021 PLoS Pathog, PMID 34871328): focused library (79
# candidate genes, about 1,400 guides) screened with TGEV for five rounds; GEO
# holds one file per sample (control, round 3, round 5), each with two normalized
# columns (<sample>_Read1_norm, <sample>_Read2_norm, two decimals) and their average.
# No raw counts are deposited. Each normalized column is raw reads times one
# constant, so prepare.R recovers the raw reads: it searches the scale
# s = v_min / k (k = 1..1500), refines s by least squares on values whose integer
# multiple is unambiguous, widening the range in doubling steps (the method of
# tools/screen-reanalysis/recover_counts.R with a finer ladder, needed because
# v_min = 0.96 in TGEV_3rd_Read2 is printed too coarsely for its coarser ladder),
# and accepts a column only when at least 99.5% of positive values are within
# 0.02 of an integer. Read1 and Read2 of a library are then summed: they are two
# reads of one library (constant ratio 1.10-1.22, about 4% relative spread, as
# separate PCR or sequencing runs give; mates of the same fragments would agree
# almost exactly).
# The focused files name genes by porcine Ensembl id only; the symbol is taken from
# the genome-wide PigGeCKO control file of the companion series GSE169111, whose
# guide names start with the same Ensembl id (ids without a match are kept).
# Writes counts.tsv (gene = symbol, ensembl = id) and recovery_scales.json.
# Usage: Rscript prepare.R <workdir>   (after fetch_geo.R GSE169108 --sample-files)
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
base <- "https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM5176nnn/"
files <- c(Control = "GSM5176446/suppl/GSM5176446_Focused_Control.txt.gz",
           TGEV3 = "GSM5176447/suppl/GSM5176447_Focused_TGEV3rd.txt.gz",
           TGEV5 = "GSM5176448/suppl/GSM5176448_Focused_TGEV5th.txt.gz")
dir.create(file.path(workdir, "sample_suppl"), showWarnings = FALSE)
tol <- 0.02; need <- 0.995
refine <- function(x, s) {
  for (lim in c(2^(2:20), Inf)) {
    sel <- x / s <= lim
    r <- round(x[sel] / s); ok <- r > 0 & abs(x[sel] / s - r) <= 0.25
    if (sum(ok) < 3) next
    s <- sum(x[sel][ok] * r[ok]) / sum(r[ok]^2)
  }
  s
}
rate <- function(x, s) { r <- x / s; mean(abs(r - round(r)) <= tol) }
recover <- function(x) {
  pos <- x[x > 0]; vmin <- min(pos)
  for (k in 1:1500) {
    s <- refine(pos, vmin / k)
    if (s > 0.05 && rate(pos, s) >= need) return(list(k = k, scale = s, integrality = rate(pos, s),
                                         maxdev = max(abs(pos / s - round(pos / s)))))
  }
  stop("no scale found")
}
scales <- list(); out <- NULL
for (s in names(files)) {
  local <- file.path(workdir, "sample_suppl", basename(files[[s]]))
  if (!file.exists(local)) utils::download.file(paste0(base, files[[s]]), local, mode = "wb", quiet = TRUE)
  x <- utils::read.delim(local, check.names = FALSE, stringsAsFactors = FALSE, strip.white = TRUE)
  x <- x[!is.na(x[[1]]) & nzchar(x[[1]]), ]
  cols <- grep("_Read[12]_norm$", names(x), value = TRUE)
  stopifnot(length(cols) == 2)
  d <- data.frame(sgRNA = x[[1]], gene = x[[2]])
  total <- 0
  for (cl in cols) {
    v <- as.numeric(x[[cl]]); v[is.na(v)] <- 0
    fit <- recover(v)
    scales[[cl]] <- c(list(column = cl, sample = s), fit, list(total = sum(round(v / fit$scale))))
    total <- total + round(v / fit$scale)
  }
  d[[s]] <- as.integer(total)
  out <- if (is.null(out)) d else merge(out, d[, c("sgRNA", s)], by = "sgRNA", all = TRUE)
}
for (s in names(files)) out[[s]][is.na(out[[s]])] <- 0L
pig <- file.path(workdir, "sample_suppl", "GSM5176502_PigGeCKO_Control.txt.gz")
if (!file.exists(pig)) utils::download.file(paste0(base, "GSM5176502/suppl/GSM5176502_PigGeCKO_Control.txt.gz"),
                                            pig, mode = "wb", quiet = TRUE)
p <- utils::read.delim(pig, check.names = FALSE, stringsAsFactors = FALSE)
p <- p[grepl("^ENSSSCG[0-9]+_", p[[1]]), ]
map <- data.frame(ensembl = sub("_.*$", "", p[[1]]), symbol = trimws(p[[2]]))
map <- map[!duplicated(map$ensembl), ]
out$ensembl <- out$gene
hit <- match(out$ensembl, map$ensembl)
out$gene <- ifelse(is.na(hit), out$ensembl, map$symbol[hit])
out <- out[, c("sgRNA", "gene", "ensembl", names(files))]
out <- out[order(out$sgRNA, method = "radix"), ]
stopifnot(!anyDuplicated(out$sgRNA))
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
writeLines(jsonlite::toJSON(unname(scales), auto_unbox = TRUE, pretty = TRUE, digits = 10),
           file.path(workdir, "recovery_scales.json"))
