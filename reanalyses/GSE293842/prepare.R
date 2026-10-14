# Builds counts_by_pool.tsv.gz for GSE293842: the kinome Brunello count
# matrix with one Day 0 and one Day 14 column per half-pool.
#
# GSE293842_counts_matrix.txt.gz holds both half-pools (sgRNA sets 1-4 and
# 5-8, column 'pool') in two columns, but the half-pools were sequenced as
# separate libraries (GSM8891594/5 = A = sets 1-4, GSM8891596/7 = B = sets
# 5-8) whose Day14/Day0 read ratios differ (0.92 vs 1.07). To give each
# half-pool its own library total, every guide's counts go in its own pool's
# columns (Day0_A, Day14_A or Day0_B, Day14_B) and 0 in the other pool's.
# The 100 non-targeting guides occur in both half-pools under the same
# sgrna_id, so every ID gets its pool appended (_A / _B) to stay unique.
# If the series file is missing it is downloaded from the GEO FTP.
#
# It also writes paper/TableS1.csv (gene, final) from the paper's Table S1
# (mmc2.xlsx, kinome screen fold-change scores), taken from the Europe PMC
# supplementary-file bundle of PMC13130658 when paper/TableS1.xlsx is absent.
#
#   Rscript work/GSE293842/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
name <- "GSE293842_counts_matrix.txt.gz"
url <- paste0("https://ftp.ncbi.nlm.nih.gov/geo/series/GSE293nnn/GSE293842/suppl/", name)
path <- file.path(workdir, "suppl", name)
if (!file.exists(path)) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  utils::download.file(url, path, mode = "wb", quiet = TRUE)
}
x <- utils::read.delim(path, stringsAsFactors = FALSE, colClasses = c(pool = "character"))
stopifnot(setequal(unique(x$pool), c("1-4", "5-8")),
          all(x$BON1_Day0 == round(x$BON1_Day0)), all(x$BON1_Day14 == round(x$BON1_Day14)))
half <- ifelse(x$pool == "1-4", "A", "B")
out <- data.frame(sgrna_id = paste0(x$sgrna_id, "_", half), gene = x$sgrna_target,
                  pool = half, stringsAsFactors = FALSE)
for (h in c("A", "B")) {
  out[[paste0("Day0_", h)]] <- ifelse(half == h, x$BON1_Day0, 0L)
  out[[paste0("Day14_", h)]] <- ifelse(half == h, x$BON1_Day14, 0L)
}
stopifnot(!anyDuplicated(out$sgrna_id))
con <- gzfile(file.path(workdir, "counts_by_pool.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

xlsx <- file.path(workdir, "paper", "TableS1.xlsx")
if (!file.exists(xlsx)) {
  dir.create(dirname(xlsx), showWarnings = FALSE)
  bundle <- tempfile(fileext = ".zip")
  options(timeout = 1800)
  utils::download.file("https://www.ebi.ac.uk/europepmc/webservices/rest/PMC13130658/supplementaryFiles",
                       bundle, mode = "wb", quiet = TRUE)
  utils::unzip(bundle, files = "mmc2.xlsx", exdir = tempdir())
  invisible(file.copy(file.path(tempdir(), "mmc2.xlsx"), xlsx))
}
s1 <- as.data.frame(suppressMessages(readxl::read_excel(xlsx, skip = 2)))[, c("gene", "final")]
s1 <- s1[!is.na(s1$gene), ]
utils::write.csv(s1, file.path(workdir, "paper", "TableS1.csv"), row.names = FALSE)
