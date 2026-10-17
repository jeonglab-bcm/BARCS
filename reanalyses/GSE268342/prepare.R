#!/usr/bin/env Rscript
# GSE268342 (Tsung et al. 2024 PLoS Genet, PMID 38857306): adds gene labels to
# the GEO count table. GEO's GSE268342_processed_countstable.txt.gz has only
# sgId (e.g. u87_unique:TSS13993_+_94421131.23-CUFF.6305.1) and four count
# columns. The gene (lncRNA "LH" annotation, as used in the paper:
# LINC03045 = LH02236, ZNF215-AS1 = LH02727) comes from the CRiNCL library table
# of Liu et al. 2017 in mhorlbeck/ScreenProcessing (pinned commit), sublibrary
# u87_unique; non-targeting guides are "negative_control".
# Usage: Rscript prepare.R <workdir>   (after fetch_geo.R GSE268342)
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
lib_url <- paste0("https://raw.githubusercontent.com/mhorlbeck/ScreenProcessing/",
                  "0ee5192ecc17348665bd1387ddfa9037efb7964f/library_tables/CRiNCL_human_librarytable.txt")
lib_file <- file.path(workdir, "raw", "CRiNCL_human_librarytable.txt")
fetch(lib_url, lib_file)
lib <- utils::read.delim(lib_file, check.names = FALSE, stringsAsFactors = FALSE, quote = "")
names(lib)[1] <- "sgId"
counts <- utils::read.delim(file.path(workdir, "suppl", "GSE268342_processed_countstable.txt.gz"),
                            check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(!anyDuplicated(counts$sgId), all(counts$sgId %in% lib$sgId))
gene <- lib$gene[match(counts$sgId, lib$sgId)]
out <- data.frame(sgId = counts$sgId, gene = gene,
                  Before_Rep_5 = counts$Before_Rep_5, Before_Rep_6 = counts$Before_Rep_6,
                  After_Rep_5 = counts$After_Rep_5, After_Rep_6 = counts$After_Rep_6,
                  check.names = FALSE)
out <- out[order(out$sgId, method = "radix"), ]
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
