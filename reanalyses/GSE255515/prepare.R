#!/usr/bin/env Rscript
# GSE255515 (in vivo APCM CRISPRa screen, Cancer Discov 2026, PMID 41747251):
# builds counts_with_gene.tsv, the deposited raw read counts
# (suppl/GSE255515_APCM_readCounts.tsv.gz, sgRNA x 16 libraries, no gene
# column) with a Gene column added from the deposited library file
# (suppl/GSE255515_APCM_library.txt.gz, GUIDE_ID -> GENE). Counts are not
# changed. Both files come from GEO via fetch_geo.R.
#
#   Rscript work/GSE255515/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
counts <- utils::read.delim(gzfile(file.path(workdir, "suppl", "GSE255515_APCM_readCounts.tsv.gz")),
                            check.names = FALSE, stringsAsFactors = FALSE)
lib <- utils::read.delim(gzfile(file.path(workdir, "suppl", "GSE255515_APCM_library.txt.gz")),
                         check.names = FALSE, stringsAsFactors = FALSE)
lib <- lib[nzchar(lib$GUIDE_ID) & !is.na(lib$GUIDE_ID), ]
gene <- lib$GENE[match(counts$sgRNA, lib$GUIDE_ID)]
stopifnot(!anyNA(gene), all(nzchar(gene)))
out <- data.frame(sgRNA = counts$sgRNA, Gene = gene, counts[, -1, drop = FALSE],
                  check.names = FALSE, stringsAsFactors = FALSE)
utils::write.table(out, file.path(workdir, "counts_with_gene.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
