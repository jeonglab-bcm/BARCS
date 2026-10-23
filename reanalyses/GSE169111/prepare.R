#!/usr/bin/env Rscript
# GSE169111 (Sun et al. 2021 PLoS Pathog, PMID 34871328): builds counts.tsv from
# the four per-sample files of the PigGeCKO screen (control PK-15-Cas9 library
# and three successive rounds of TGEV challenge). Each file has integer read
# counts in two columns, <sample>_read1 and <sample>_read2. In the control
# library they agree at the Poisson level (ratio 1.005, dispersion index 0.94),
# as two independent reads of one library do (mates of the same fragments would
# be near-identical), so they are summed into one library. The normalized and
# average columns are ignored. A trailing empty line is dropped.
# Usage: Rscript prepare.R <workdir>   (after fetch_geo.R GSE169111 --sample-files)
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
base <- "https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM5176nnn/"
files <- c(Control = "GSM5176502/suppl/GSM5176502_PigGeCKO_Control.txt.gz",
           TGEV1 = "GSM5176503/suppl/GSM5176503_PigGeCKO_TGEV1th.txt.gz",
           TGEV2 = "GSM5176504/suppl/GSM5176504_PigGeCKO_TGEV2nd.txt.gz",
           TGEV3 = "GSM5176505/suppl/GSM5176505_PigGeCKO_TGEV3rd.txt.gz")
dir.create(file.path(workdir, "sample_suppl"), showWarnings = FALSE)
out <- NULL
for (s in names(files)) {
  local <- file.path(workdir, "sample_suppl", basename(files[[s]]))
  if (!file.exists(local)) utils::download.file(paste0(base, files[[s]]), local, mode = "wb", quiet = TRUE)
  x <- utils::read.delim(local, check.names = FALSE, stringsAsFactors = FALSE)
  x <- x[!is.na(x[[1]]) & nzchar(x[[1]]), ]
  r1 <- grep("_read1$", names(x), value = TRUE); r2 <- grep("_read2$", names(x), value = TRUE)
  stopifnot(length(r1) == 1, length(r2) == 1)
  d <- data.frame(sgRNA = x[[1]], gene = trimws(x[[2]]))
  d[[s]] <- as.integer(x[[r1]] + x[[r2]])
  out <- if (is.null(out)) d else merge(out, d[, c("sgRNA", s)], by = "sgRNA", all = TRUE)
}
for (s in names(files)) out[[s]][is.na(out[[s]])] <- 0L
out <- out[order(out$sgRNA, method = "radix"), ]
stopifnot(!anyDuplicated(out$sgRNA), !anyNA(out$gene))
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
