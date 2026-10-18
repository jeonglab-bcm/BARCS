#!/usr/bin/env Rscript
# GSE183348 (Kellman et al., Nat Genet 2025, PMID 39962238): CRISPR knockout
# screen of 178 colon-cancer MPRA putative target genes (6 guides each, 100
# safe-targeting guides) in DLD1, HCT116 and SW948 cells: day 0, 2D culture and
# 10 subcutaneous tumours per line. Builds inside <workdir>:
#
# 1. counts.tsv: the three per-line count files (GSE183348_<line>_counts.txt.gz,
#    first column "gene" holds the guide ID sgNNN-<gene>) merged by guide ID,
#    with a Gene column (guide ID without the sgNNN- prefix). Row order differs
#    between the files, so rows are matched by guide ID and sorted.
# 2. paper/SuppTable6_<line>_<2D|Tumor>.tsv: the paper's MAGeCK gene summaries
#    (Supplementary Table 6) split by cell line and experiment, with numeric
#    columns (the sheet stores some numbers as text).
#
# Usage: Rscript prepare.R <workdir>

workdir <- normalizePath(commandArgs(trailingOnly = TRUE)[[1]])
options(timeout = 600)
fetch <- function(url, dest, tries = 5) {
  for (i in seq_len(tries)) {
    ok <- tryCatch({
      utils::download.file(url, dest, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > 0) return(invisible(dest))
    unlink(dest)
    Sys.sleep(10 * i)
  }
  stop("download failed: ", url)
}

## Counts
lines <- c("DLD1", "HCT116", "SW948")
tabs <- lapply(lines, function(l) {
  x <- utils::read.delim(file.path(workdir, "suppl", sprintf("GSE183348_%s_counts.txt.gz", l)),
                         check.names = FALSE, stringsAsFactors = FALSE)
  stopifnot(names(x)[1] == "gene", !anyDuplicated(x$gene))
  x[order(x$gene, method = "radix"), , drop = FALSE]
})
ids <- tabs[[1]]$gene
stopifnot(all(vapply(tabs, function(x) identical(x$gene, ids), TRUE)),
          all(grepl("^sg[0-9]+-.+$", ids)))
out <- data.frame(sgRNA = ids, Gene = sub("^sg[0-9]+-", "", ids), stringsAsFactors = FALSE)
for (x in tabs) {
  for (s in setdiff(names(x), "gene")) {
    v <- x[[s]]
    stopifnot(!anyNA(v), all(v == round(v)), !s %in% names(out))
    out[[s]] <- as.integer(v)
  }
}
num <- as.integer(sub("sample_", "", setdiff(names(out), c("sgRNA", "Gene"))))
out <- out[, c("sgRNA", "Gene", paste0("sample_", sort(num)))]
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE,
                   row.names = FALSE)

## Paper table: Supplementary Table 6 (MAGeCK gene summaries)
paper <- file.path(workdir, "paper")
dir.create(paper, showWarnings = FALSE)
xl <- file.path(paper, "41588_2024_2070_MOESM3_ESM.xlsx")
if (!file.exists(xl)) {
  fetch(paste0("https://media.springernature.com/original/springer-static/esm/",
               "art%3A10.1038%2Fs41588-024-02070-5/MediaObjects/41588_2024_2070_MOESM3_ESM.xlsx"),
        xl)
}
s6 <- as.data.frame(readxl::read_excel(xl, sheet = "SuppTable6_CRISPRKO", skip = 5,
                                       col_types = "text"), check.names = FALSE)
stopifnot(identical(names(s6)[1:3], c("gene", "guide number", "neg|score")))
s6 <- s6[!is.na(s6$gene) & nzchar(s6$gene), , drop = FALSE]
for (k in setdiff(names(s6), c("gene", "cell_line", "experiment_type", "gene_type"))) {
  s6[[k]] <- as.numeric(s6[[k]])
  stopifnot(!anyNA(s6[[k]]))
}
for (key in unique(paste(s6$cell_line, s6$experiment_type, sep = "_"))) {
  y <- s6[paste(s6$cell_line, s6$experiment_type, sep = "_") == key, , drop = FALSE]
  y <- y[order(y$gene, method = "radix"), , drop = FALSE]
  utils::write.table(y, file.path(paper, sprintf("SuppTable6_%s.tsv", key)), sep = "\t",
                     quote = FALSE, row.names = FALSE)
}
message(sprintf("counts: %d guides x %d libraries; Supp Table 6: %s", nrow(out), ncol(out) - 2,
                paste(unique(paste(s6$cell_line, s6$experiment_type, sep = "_")), collapse = ", ")))
