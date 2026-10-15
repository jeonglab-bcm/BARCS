#!/usr/bin/env Rscript
# GSE252651: builds merged_counts.tsv from the four per-sample guide count files
# (headerless "<count> <guide>" lines, uniq -c style), merged by guide name;
# guides absent from a file get 0. Gene = guide name up to the first "_"
# (Control_Control_1 -> Control). Columns are named by the file letters, which
# the authors' MAGeCK configuration uses (zenodo 10.5281/zenodo.10229339:
# exp1 test S8 vs control L8, exp2 test S7 vs control L7): S = FACS-sorted,
# L = unsorted library. GEO attaches L7/L8 to the "FACS" GSMs and S7/S8 to the
# "no FACS" GSMs; the file letters are followed here.
# Also writes paper/EV1_<screen>.tsv from Dataset EV1 of Pauzaite et al. 2024
# EMBO J (MAGeCK gene summaries of both screens).
# Usage: Rscript prepare.R <workdir>   (needs fetch_geo.R --sample-files)
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir <- file.path(workdir, "sample_suppl")
files <- c(L8 = "GSM8004837_L8.guidecounts.txt.gz", S8 = "GSM8004838_S8.guidecounts.txt.gz",
           L7 = "GSM8004839_L7.guidecounts.txt.gz", S7 = "GSM8004840_S7.guidecounts.txt.gz")
tables <- lapply(files, function(f) {
  x <- utils::read.table(file.path(dir, f), header = FALSE, stringsAsFactors = FALSE,
                         colClasses = c("integer", "character"))
  stopifnot(!anyDuplicated(x[[2]]))
  x
})
guides <- sort(unique(unlist(lapply(tables, `[[`, 2))), method = "radix")
counts <- lapply(tables, function(x) {
  v <- x[[1]][match(guides, x[[2]])]
  v[is.na(v)] <- 0L
  v
})
out <- data.frame(sgRNA = guides, gene = sub("_.*$", "", guides), counts,
                  check.names = FALSE)
utils::write.table(out, file.path(workdir, "merged_counts.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)

dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs44318-024-00166-6/MediaObjects/44318_2024_166_MOESM3_ESM.xlsx"
xl <- file.path(workdir, "paper", "EV1.xlsx")
if (!file.exists(xl)) utils::download.file(url, xl, mode = "wb", quiet = TRUE)
sheets <- readxl::excel_sheets(xl)
screens <- c(GFP_high = "Expanded_View_Dataset _GFP_high", GFP_low = "Expanded_View_Dataset _GFP_low")
for (k in names(screens)) {
  stopifnot(screens[[k]] %in% sheets)
  d <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = screens[[k]], col_names = FALSE,
                                                          col_types = "text")))
  head_row <- which(d[[1]] == "id")[1]
  names(d) <- d[head_row, ]
  d <- d[-seq_len(head_row), 1:14]
  d <- d[!is.na(d$id), ]
  for (j in 2:14) d[[j]] <- signif(as.numeric(d[[j]]), 6)
  d <- d[order(d[["pos|rank"]], method = "radix"), ]
  utils::write.table(d, file.path(workdir, "paper", paste0("EV1_", k, ".tsv")),
                     sep = "\t", quote = FALSE, row.names = FALSE)
}
