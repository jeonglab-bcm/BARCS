#!/usr/bin/env Rscript
# GSE268182 (genome-wide CRISPR screen for HSV-1 restriction factors, TMEFF1
# paper, PMID 39048823). Builds one count file per GeCKO v2 half-library from the
# two per-sample GEO files (sample_suppl/, from fetch_geo.R --sample-files):
#   countsA.tsv  <- Screen_1 / libraryA  (columns High, USC)
#   countsB.tsv  <- Screen_2 / libraryB  (columns High, USC)
# Each file has sgRNA, Gene, Screen_N_High (GFP-high sorted after HSV-1-GFP) and
# Screen_N_USC (unsorted control). The two half-libraries contain different
# guides, so they are analysed separately. Counts unchanged; rows sorted by sgRNA.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
build <- function(file, out) {
  d <- utils::read.delim(file, check.names = FALSE, stringsAsFactors = FALSE)
  stopifnot(ncol(d) == 4L)
  names(d) <- c("guide", "gene", "High", "USC")
  stopifnot(all(d$High == round(d$High)), all(d$USC == round(d$USC)),
            !anyDuplicated(d$guide))
  d <- d[order(d$guide, method = "radix"), ]
  utils::write.table(d, file.path(workdir, out), sep = "\t",
                     quote = FALSE, row.names = FALSE)
}
sdir <- file.path(workdir, "sample_suppl")
fa <- list.files(sdir, pattern = "libraryA\\.txt\\.gz$", full.names = TRUE)
fb <- list.files(sdir, pattern = "libraryB\\.txt\\.gz$", full.names = TRUE)
stopifnot(length(fa) == 1L, length(fb) == 1L)
build(fa, "countsA.tsv")
build(fb, "countsB.tsv")
