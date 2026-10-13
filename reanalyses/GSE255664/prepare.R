# Builds merged_counts.tsv.gz and the paper's day-16 MAGeCK table.
#
# Counts: GEO gives two count files per sample, one per read strand. fetch_geo.R
# --sample-files downloads only the "+" strand files (sample_suppl/); this
# downloads the matching "-" strand files from the GEO sample FTP and sums the
# two per sgRNA (the "-" strand adds 14-198 reads per library). Columns are
# named from the file names, GSM prefix and strand removed (e.g. WT_D16_R1).
#
# Published table: paper/SD2_day16_ko_depleted.tsv is Supplementary Data 2 of
# the Nature Communications paper (MAGeCK test, labelled "WT vs EXO1 KO"), so
# its "pos" side is depletion in EXO1 KO. Kept: id, the pos score, p, FDR and
# rank, and the log fold change with its sign flipped to read EXO1 KO vs WT.
#
#   Rscript reanalyses/GSE255664/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
samples <- utils::read.delim(file.path(workdir, "samples.tsv"), stringsAsFactors = FALSE)
plus_urls <- sub("^ftp://", "https://", samples$supplementary_files[grepl("_\\+_", samples$supplementary_files)])
plus_urls <- plus_urls[order(basename(plus_urls))]

minus_dir <- file.path(workdir, "sample_suppl_minus")
dir.create(minus_dir, showWarnings = FALSE)
counts <- NULL
for (url in plus_urls) {
  plus_file <- file.path(workdir, "sample_suppl", basename(url))
  minus_file <- file.path(minus_dir, sub("_+_", "_-_", basename(url), fixed = TRUE))
  utils::download.file(sub("_+_", "_-_", url, fixed = TRUE), minus_file, mode = "wb", quiet = TRUE)
  plus <- utils::read.delim(plus_file, check.names = FALSE)
  minus <- utils::read.delim(minus_file, check.names = FALSE)
  stopifnot(identical(plus$sgRNA, minus$sgRNA))
  if (is.null(counts)) counts <- data.frame(sgRNA = plus$sgRNA, gene = plus$gene)
  stopifnot(identical(counts$sgRNA, plus$sgRNA))
  name <- sub("^GSM[0-9]+_", "", sub("_+_", "_", sub("_sgRNA_counts.txt.gz$", "", basename(url)), fixed = TRUE))
  counts[[name]] <- as.integer(round(plus[[3]] + minus[[3]]))
}
out <- gzfile(file.path(workdir, "merged_counts.tsv.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)

xlsx <- file.path(tempdir(), "41467_2025_63349_MOESM5_ESM.xlsx")
utils::download.file(paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-025-63349-7/",
                            "MediaObjects/41467_2025_63349_MOESM5_ESM.xlsx"),
                     xlsx, mode = "wb", quiet = TRUE)
sd2 <- as.data.frame(readxl::read_excel(xlsx, sheet = 1))
published <- data.frame(gene = sd2$id,
                        ko_depleted_score = sd2[["pos|score"]],
                        ko_depleted_p = sd2[["pos|p-value"]],
                        ko_depleted_fdr = sd2[["pos|fdr"]],
                        ko_depleted_rank = sd2[["pos|rank"]],
                        lfc_ko_vs_wt = -sd2[["pos|lfc"]])
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
utils::write.table(published, file.path(workdir, "paper", "SD2_day16_ko_depleted.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
