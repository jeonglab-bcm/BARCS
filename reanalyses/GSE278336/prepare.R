# Builds counts.tsv.gz for GSE278336: pre-crRNA array read counts for the
# dCas12a CRISPRi fitness screens in A549 cells (four repressors x days
# 5/7/14/21 x three transductions, plus the Lb and As plasmid libraries).
#
# GEO deposits one samtools idxstats file per sample (GSM9085321-GSM9085374);
# column 1 is the array name and column 3 the number of mapped reads, which
# equals the paper's raw counts (Supplementary Data 1, "Lb Raw Counts" /
# "As Raw Counts"). The '*' row (unmapped reads) is dropped. Missing files
# are downloaded from the GEO FTP.
#
# Gene labels follow the paper's MAGeCK gene names: the trailing array index
# (-<n>) is removed; single-target combinatorial arrays (X-k-NT, NT-X-k) are
# labelled X; double-target arrays (A-B, B-A) are labelled by the two genes in
# sorted order; NT (non-targeting) and NEG (intergenic) arrays are controls.
#
# It also fetches the paper's Supplementary Data 1 (raw counts, DESeq2
# results and MAGeCK MLE beta scores) to paper/SupplementaryData1.xlsx for
# compare.json.
#
#   Rscript work/GSE278336/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
screens <- expand.grid(rep = 1:3, day = c(5, 7, 14, 21),
                       rep_name = c("Lb_KRAB", "Lb_SID", "As_KRAB", "As_SID"),
                       stringsAsFactors = FALSE)
labels <- c(sprintf("%s-Day%d-%d", screens$rep_name, screens$day, screens$rep),
            sprintf("Lb_Plasmid-%d", 1:3), sprintf("As_Plasmid-%d", 1:3))
gsm <- sprintf("GSM%d", 9085321 + seq_along(labels) - 1L)
files <- sprintf("%s_%s.idxstats.txt.gz", gsm, labels)
urls <- sprintf("https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM9085nnn/%s/suppl/%s", gsm, files)
dir.create(file.path(workdir, "sample_suppl"), showWarnings = FALSE, recursive = TRUE)

counts <- NULL
for (i in seq_along(files)) {
  path <- file.path(workdir, "sample_suppl", files[i])
  if (!file.exists(path)) utils::download.file(urls[i], path, mode = "wb", quiet = TRUE)
  x <- utils::read.delim(path, header = FALSE, stringsAsFactors = FALSE,
                         col.names = c("array", "length", "mapped", "unmapped"))
  x <- x[x$array != "*", ]
  stopifnot(!anyDuplicated(x$array), nrow(x) == 894L)
  if (is.null(counts)) counts <- data.frame(array = x$array, stringsAsFactors = FALSE)
  stopifnot(setequal(counts$array, x$array))
  counts[[gsub("-", "_", labels[i])]] <- as.integer(x$mapped[match(counts$array, x$array)])
}

base <- sub("-[0-9]+$", "", counts$array)
gene <- base
single_a <- grepl("^NT-.+-[0-9]+$", base)
single_b <- grepl("^.+-[0-9]+-NT$", base)
gene[single_a] <- sub("^NT-(.+)-[0-9]+$", "\\1", base[single_a])
gene[single_b] <- sub("^(.+)-[0-9]+-NT$", "\\1", base[single_b])
pair <- !single_a & !single_b & grepl("-", base)
gene[pair] <- vapply(strsplit(base[pair], "-", fixed = TRUE),
                     function(p) paste(sort(p, method = "radix"), collapse = "-"), "")
stopifnot(!anyNA(gene), all(nzchar(gene)))
counts <- data.frame(array = counts$array, gene = gene, counts[, -1], check.names = FALSE)
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(counts, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

paper <- file.path(workdir, "paper", "SupplementaryData1.xlsx")
if (!file.exists(paper)) {
  dir.create(dirname(paper), showWarnings = FALSE)
  utils::download.file(paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-026-69090-z/",
                              "MediaObjects/41467_2026_69090_MOESM3_ESM.xlsx"), paper, mode = "wb", quiet = TRUE)
}
