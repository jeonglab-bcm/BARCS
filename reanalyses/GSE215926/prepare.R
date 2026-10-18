#!/usr/bin/env Rscript
# GSE215926: the paper's own MAGeCK gene (element) summaries for the SEM
# day-14 versus day-0 comparisons, from Supplementary Data 2 of
# Nat Commun 14:7779 (2023), doi:10.1038/s41467-023-43264-5.
# Each day-14 sheet holds the MAGeCK gene summary in its first 23 columns,
# followed by a second, narrower table; only the gene summary is kept.
# The count file is the GEO workbook itself (sheet Raw.Count.tsv), read
# directly by run_barcs.R.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
url <- paste0("https://media.springernature.com/original/springer-static/esm/",
              "art%3A10.1038%2Fs41467-023-43264-5/MediaObjects/41467_2023_43264_MOESM5_ESM.xlsx")
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "41467_2023_43264_MOESM5_ESM.xlsx")
options(timeout = 600)
ok <- FALSE
for (attempt in 1:5) {
  ok <- tryCatch(utils::download.file(url, xl, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.size(xl) > 1e6) break
  Sys.sleep(10 * attempt)
}
if (!ok) stop("download failed: ", url)

sheets <- c(SEM_Cas9_day14 = "SEM Cas9 day 14 vs day 0 MAGeCK",
            SEM_dCas9KRAB_day14 = "SEM dCas9 day14 vs day 0 MAGeCK")
for (name in names(sheets)) {
  d <- as.data.frame(readxl::read_excel(xl, sheet = sheets[[name]], .name_repair = "minimal"))
  d <- d[, 1:23]
  d <- d[!is.na(d$id), ]
  d <- d[order(d$id, method = "radix"), ]
  utils::write.table(d, file.path(workdir, "paper", paste0(name, "_mageck.tsv")),
                     sep = "\t", quote = FALSE, row.names = FALSE, na = "")
}
