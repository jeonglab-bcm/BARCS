#!/usr/bin/env Rscript
# GSE210422: builds GSE210422_merged_counts.txt.gz by joining the ten
# per-sample count files (sample_suppl/, from fetch_geo.R --sample-files) on
# sgRNA and Gene. Columns are named <GSM>_<cell line>_<day>_<rep> from the
# file names; counts are unchanged. Rows are sorted by sgRNA.
# Also writes paper/A375_day21_mageck.tsv, the authors' significant
# enhancers for A375 day 21 versus day 0 (MAGeCK; Table S7, Additional file 8
# of Genome Biol 24:248 (2023), doi:10.1186/s13059-023-03087-5).
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
files <- sort(list.files(file.path(workdir, "sample_suppl"), pattern = "\\.count\\.txt\\.gz$",
                         full.names = TRUE), method = "radix")
stopifnot(length(files) == 10)
counts <- NULL
for (file in files) {
  sample <- utils::read.delim(file, check.names = FALSE, stringsAsFactors = FALSE)
  base <- sub("\\.count\\.txt\\.gz$", "", basename(file))
  name <- if (grepl("^GSM643003[6-9]_", base)) sub("^(GSM[0-9]+)_", "\\1_A375_", base) else base
  name <- gsub("-", "", name)
  stopifnot(all(sample[[3]] == round(sample[[3]])))
  sample <- sample[, 1:3]
  names(sample)[3] <- name
  counts <- if (is.null(counts)) sample else merge(counts, sample, by = c("sgRNA", "Gene"), all = TRUE)
}
stopifnot(nrow(counts) == 9977, !anyNA(counts))
counts <- counts[order(counts$sgRNA, method = "radix"), ]
out <- gzfile(file.path(workdir, "GSE210422_merged_counts.txt.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)

url <- paste0("https://static-content.springer.com/esm/art%3A10.1186%2Fs13059-023-03087-5/",
              "MediaObjects/13059_2023_3087_MOESM8_ESM.xlsx")
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "13059_2023_3087_MOESM8_ESM.xlsx")
options(timeout = 600)
ok <- FALSE
for (attempt in 1:5) {
  ok <- tryCatch(utils::download.file(url, xl, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.size(xl) > 10000) break
  Sys.sleep(10 * attempt)
}
if (!ok) stop("download failed: ", url)
tab <- as.data.frame(readxl::read_excel(xl, sheet = "A375 day21", skip = 2))
tab <- tab[!is.na(tab[["Enhancer ID"]]), ]
tab <- tab[order(tab[["Rank"]], tab[["Enhancer core region"]], method = "radix"), ]
utils::write.table(tab, file.path(workdir, "paper", "A375_day21_mageck.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE, na = "")
pos <- tab[tab[["Direction"]] == "Positive", ]
utils::write.table(pos, file.path(workdir, "paper", "A375_day21_mageck_positive.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE, na = "")
