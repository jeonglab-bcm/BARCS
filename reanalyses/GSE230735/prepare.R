#!/usr/bin/env Rscript
# GSE230735 (Zhang et al. 2024, Dev Cell, PMID 39116875): builds counts.tsv from
# the deposited count workbook (suppl/GSE230735_total_final.xlsx, Sheet1). The
# CRISPRi membrane-transporter screen sorted cBioITA-expressing 293T cells into a
# bottom (lowest 25% fluorescence) and a top (highest 25%) population; each bin
# was sequenced twice (Bottom-1/Bottom-2, Top-1/Top-2). The two reads of a bin
# are technical re-sequencing of one sort (log-count correlation 0.995-0.998,
# near-constant ratio), so they are summed into one library per bin. Counts are
# the deposited integers; only the per-bin sum is formed.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
f <- file.path(workdir, "suppl", "GSE230735_total_final.xlsx")
d <- as.data.frame(suppressMessages(readxl::read_excel(f, sheet = 1)))
out <- data.frame(sgRNA = d$sgRNA, gene = d$gene,
                  Bottom = as.integer(d[["Bottom-1"]] + d[["Bottom-2"]]),
                  Top = as.integer(d[["Top-1"]] + d[["Top-2"]]),
                  stringsAsFactors = FALSE)
out <- out[order(out$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
