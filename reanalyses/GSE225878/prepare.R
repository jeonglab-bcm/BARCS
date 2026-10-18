#!/usr/bin/env Rscript
# GSE225878: builds the primary-screen count table from the per-sample GEO
# files GSM7059705-GSM7059710_Prim_D{4,15}_Rep_{1,2,3}_Counts.xlsx (Brie mouse
# library, 79,633 guides by barcode). Each file holds one biological replicate
# at one day: columns CD200High1..n and CD200Low1..m are PCR/sequencing
# barcodes of the CD200-high (top 10%) and CD200-low (bottom 10%) sorts; they
# are summed per sort (equal to the authors' "High Counts"/"Low Counts"
# columns). Guides are mapped to genes with the Broad GPP Brie library
# contents (Addgene 73633); the 1,000 non-targeting guides of the Brie
# controls file get gene "NonTargeting_<n>" (one pseudo-gene per guide).
# Writes counts_primary.tsv.gz (sgRNA = guide sequence, gene, D4_R1_High, ...).
# Also writes paper/primary_d4.tsv and paper/primary_d15.tsv from the
# authors' series-level GPP hypergeometric results
# (GSE225878_Prim_D{4,15}_Average_LFC_*.txt.gz): gene, avg_lfc (CD200-high
# vs CD200-low), avg_neglog10p.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
options(timeout = 600)
fetch <- function(url, dest, min_size = 1e5) {
  for (i in 1:5) {
    ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > min_size) return(invisible(dest))
    Sys.sleep(10 * i)
  }
  stop("download failed: ", url)
}
raw <- file.path(workdir, "raw"); dir.create(raw, showWarnings = FALSE)
geo <- "https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM7059nnn/"
files <- c(D4_R1 = "GSM7059705_Prim_D4_Rep_1_Counts.xlsx",
           D4_R2 = "GSM7059706_Prim_D4_Rep_2_Counts.xlsx",
           D4_R3 = "GSM7059707_Prim_D4_Rep_3_Counts.xlsx",
           D15_R1 = "GSM7059708_Prim_D15_Rep_1_Counts.xlsx",
           D15_R2 = "GSM7059709_Prim_D15_Rep_2_Counts.xlsx",
           D15_R3 = "GSM7059710_Prim_D15_Rep_3_Counts.xlsx")
lib_url <- c(contents = "https://media.addgene.org/cms/filer_public/be/cd/becdf7c4-ea7a-41a3-96c9-ef2bc3c85979/broadgpp-brie-library-contents.txt",
             controls = "https://media.addgene.org/cms/filer_public/5c/ca/5cca8516-45a7-4d83-bfb2-d960c4ab9de5/broadgpp-brie-library-controls.csv")
for (f in files) {
  dest <- file.path(raw, f)
  if (!file.exists(dest)) fetch(paste0(geo, substr(f, 1, 10), "/suppl/", f), dest)
}
for (n in names(lib_url)) {
  dest <- file.path(raw, basename(lib_url[[n]]))
  if (!file.exists(dest)) fetch(lib_url[[n]], dest, min_size = 1e4)
}
# The Addgene files use carriage-return line endings.
read_cr <- function(path, sep) {
  txt <- unlist(strsplit(readChar(path, file.size(path), useBytes = TRUE), "\r\n|\r|\n"))
  utils::read.table(text = txt, sep = sep, header = TRUE, quote = "\"", comment.char = "",
                    check.names = FALSE, stringsAsFactors = FALSE)
}
contents <- read_cr(file.path(raw, basename(lib_url[["contents"]])), "\t")
controls <- read_cr(file.path(raw, basename(lib_url[["controls"]])), ",")
contents <- contents[order(contents[["sgRNA Target Sequence"]], contents[["Target Gene Symbol"]],
                           method = "radix"), ]
contents <- contents[!duplicated(contents[["sgRNA Target Sequence"]]), ]
counts <- NULL
for (n in names(files)) {
  d <- as.data.frame(suppressMessages(readxl::read_excel(file.path(raw, files[[n]]), sheet = 1)))
  hi <- grep("^CD200High[0-9]+$", names(d), value = TRUE)
  lo <- grep("^CD200Low[0-9]+$", names(d), value = TRUE)
  x <- data.frame(sgRNA = d[["Construct Barcode"]],
                  High = as.integer(rowSums(as.matrix(d[, hi]))),
                  Low = as.integer(rowSums(as.matrix(d[, lo]))))
  names(x)[2:3] <- paste0(n, c("_High", "_Low"))
  counts <- if (is.null(counts)) x else merge(counts, x, by = "sgRNA", all = TRUE, sort = FALSE)
}
gene <- contents[["Target Gene Symbol"]][match(counts$sgRNA, contents[["sgRNA Target Sequence"]])]
ctl <- match(counts$sgRNA, controls[["Target Sequence"]])
gene[!is.na(ctl)] <- sprintf("NonTargeting_%04d", ctl[!is.na(ctl)])
stopifnot(!anyNA(gene), !anyNA(counts))
out <- data.frame(sgRNA = counts$sgRNA, gene = gene, counts[, -1], check.names = FALSE)
out <- out[order(out$gene, out$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts_primary.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
for (day in c("D4", "D15")) {
  f <- list.files(file.path(workdir, "suppl"), pattern = paste0("^GSE225878_Prim_", day, "_Average_LFC"),
                  full.names = TRUE)
  stopifnot(length(f) == 1)
  p <- utils::read.delim(gzfile(f), check.names = FALSE, stringsAsFactors = FALSE)
  pt <- data.frame(gene = p[["Gene Symbol"]], avg_lfc = p[["Average LFC"]],
                   avg_neglog10p = p[["Average -log(p-values)"]])
  pt <- pt[order(-pt$avg_neglog10p, pt$gene, method = "radix"), ]
  utils::write.table(pt, file.path(workdir, "paper", paste0("primary_", tolower(day), ".tsv")),
                     sep = "\t", quote = FALSE, row.names = FALSE)
}
