#!/usr/bin/env Rscript
# GSE251758 (Lin et al. 2024 Cancer Cell, PMID 38490212): builds counts.tsv from
# the two per-sample Brie count tables that GEO lists as the second and third
# supplementary files of the GSMs (fetch_geo.R takes only the first, a MAGeCK
# gene summary):
#   GSM7987449_counts_Intense_Acute_sum_rep.txt.gz  sgRNA Gene Intense Acute preA-Bulk T0
#   GSM7987450_counts_Chronic.txt.gz                sgRNA Gene Chronic Resting
# Replicate libraries were summed by the authors ("sum_rep"), so each condition
# is one library. The tables are merged by sgRNA (identical guide sets).
# Also downloads the authors' MAGeCK gene summary of the acute screen
# (GSM7987449 file 2) into paper/; the intense and chronic summaries are the
# GSMs' first files (sample_suppl/, fetched with --sample-files).
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
fetch <- function(url, dest) {
  if (file.exists(dest)) return(invisible(dest))
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  old <- options(timeout = 600); on.exit(options(old))
  for (attempt in 1:5) {
    ok <- tryCatch({utils::download.file(url, dest, mode = "wb", quiet = TRUE); TRUE},
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > 0) return(invisible(dest))
    unlink(dest); Sys.sleep(10 * attempt)
  }
  stop("download failed: ", url)
}
geo <- "https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM7987nnn/"
files <- c(ia = "GSM7987449/suppl/GSM7987449_counts_Intense_Acute_sum_rep.txt.gz",
           ch = "GSM7987450/suppl/GSM7987450_counts_Chronic.txt.gz",
           acute = "GSM7987449/suppl/GSM7987449_Alphamean_pre_vs_Acute.gene_summary.rev.txt.gz")
local <- file.path(workdir, "raw", basename(files))
names(local) <- names(files)
for (k in names(files)) fetch(paste0(geo, files[[k]]), local[[k]])
read <- function(p) utils::read.delim(p, check.names = FALSE, stringsAsFactors = FALSE,
                                      colClasses = c(sgRNA = "character", Gene = "character"))
ia <- read(local[["ia"]])
ch <- read(local[["ch"]])
stopifnot(!anyDuplicated(ia$sgRNA), setequal(ia$sgRNA, ch$sgRNA))
ch <- ch[match(ia$sgRNA, ch$sgRNA), ]
stopifnot(identical(ia$Gene, ch$Gene))
out <- data.frame(sgRNA = ia$sgRNA, gene = ia$Gene,
                  T0 = ia$T0, preA = ia[["preA-Bulk"]], Intense = ia$Intense, Acute = ia$Acute,
                  Resting = ch$Resting, Chronic = ch$Chronic, check.names = FALSE)
for (j in 3:8) stopifnot(all(out[[j]] == round(out[[j]])))
out <- out[order(out$sgRNA, method = "radix"), ]
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
acute <- utils::read.delim(local[["acute"]], check.names = FALSE, stringsAsFactors = FALSE)
utils::write.table(acute, file.path(workdir, "paper", "acute_gene_summary.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
