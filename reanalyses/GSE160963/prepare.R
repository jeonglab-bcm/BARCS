#!/usr/bin/env Rscript
# GSE160963: builds GSE160963_merged_counts.txt.gz by joining the five
# per-sample count files (sample_suppl/, from fetch_geo.R --sample-files) on
# the guide uid, Gene and guide sequence. Columns are named after the files
# (Maxiprep_R1, Maxiprep_R2, ES_day5, ES_day8, ES_day12); counts are unchanged.
# A Plasmid column holds Maxiprep_R1 + Maxiprep_R2.
# Also writes paper/TableS2_mageck.tsv and paper/TableS2_linear_model.tsv, the
# authors' depleted TFs (MAGeCK RRA p-values and mixed linear model FDRs;
# Table S2 of Cell Rep 38:110524 (2022), doi:10.1016/j.celrep.2022.110524).
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
files <- sort(list.files(file.path(workdir, "sample_suppl"), pattern = "_counts.*\\.txt\\.gz$",
                         full.names = TRUE), method = "radix")
stopifnot(length(files) == 5)
counts <- NULL
for (file in files) {
  x <- utils::read.delim(file, check.names = FALSE, stringsAsFactors = FALSE)
  stopifnot(identical(names(x), c("uid", "counts", "Gene", "guides")),
            all(x$counts == round(x$counts)))
  name <- sub("^GSM[0-9]+_(.*)_counts(_(R[12]))?\\.txt\\.gz$", "\\1_\\3", basename(file))
  name <- sub("_$", "", name)
  x <- x[, c("uid", "Gene", "guides", "counts")]
  names(x)[4] <- name
  counts <- if (is.null(counts)) x else merge(counts, x, by = c("uid", "Gene", "guides"), all = TRUE)
}
stopifnot(nrow(counts) == 17820, !anyNA(counts))
counts <- counts[order(counts$uid, method = "radix"),
                 c("uid", "Gene", "guides", "Maxiprep_R1", "Maxiprep_R2", "ES_day5", "ES_day8", "ES_day12")]
# The two maxiprep libraries are re-reads of one plasmid pool (near-Poisson
# agreement), so their sum is the plasmid reference library.
counts$Plasmid <- counts$Maxiprep_R1 + counts$Maxiprep_R2
out <- gzfile(file.path(workdir, "GSE160963_merged_counts.txt.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)

url <- "https://ars.els-cdn.com/content/image/1-s2.0-S2211124722002601-mmc3.xlsx"
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "mmc3.xlsx")
options(timeout = 600)
ok <- FALSE
for (attempt in 1:5) {
  ok <- tryCatch(utils::download.file(url, xl, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.size(xl) > 10000) break
  Sys.sleep(10 * attempt)
}
if (!ok) stop("download failed: ", url)
mageck <- as.data.frame(readxl::read_excel(xl, sheet = "302 TFs - MaGECK"))
mageck <- mageck[order(mageck$Mageck_pvalue, mageck$Gene, method = "radix"), ]
utils::write.table(mageck, file.path(workdir, "paper", "TableS2_mageck.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
lm <- as.data.frame(readxl::read_excel(xl, sheet = "218 TFs - Linear Modeling "))
lm <- lm[order(lm$FDR, lm$TF, method = "radix"), ]
utils::write.table(lm, file.path(workdir, "paper", "TableS2_linear_model.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
