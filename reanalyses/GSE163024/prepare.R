#!/usr/bin/env Rscript
# GSE163024: builds counts.tsv.gz for the CRISPRa (Calabrese set A) screen
# for COL7A1-tdTomato reporter activation in N/TERT keratinocytes, from the
# deposited workbook GSE163024_COL7A1_CRISPRaScreen_Data.xlsx (one row per
# guide with a read in the sorted sample: Gene, sgRNA, Count, CPM, refCPM, FC,
# logFC, Z-score).
#   tdTomato_high: the "Count" column, raw reads of the top-10% tdTomato sort
#     (integers; they match the deposited read file
#     GSE163024_COL7A1_CRISPRaScreen_sgRNA.tabular.txt.gz).
#   plasmid: raw reads of the plasmid library, recovered from "refCPM".
#     The workbook's CPM is (reads + 1) * u for one constant u per sample:
#     for the sorted sample CPM / 0.0620748 equals Count + 1 exactly. refCPM
#     is a whole multiple of one constant s (= min(refCPM) / 2, refined by
#     least squares) for every guide (largest deviation ~1e-11), so plasmid
#     reads = refCPM / s - 1. Only this scale gives integers of both parities;
#     s / 2 would make every count odd. The recovery is recorded in
#     recovery_scales.json.
# Guides with no read in the sorted sample (about 2,800 of the 56,762) are not
# in the workbook and cannot be included, nor can the 74 guides whose Gene
# cell is empty. Rows are sorted by guide sequence.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
d <- as.data.frame(readxl::read_excel(
  file.path(workdir, "suppl", "GSE163024_COL7A1_CRISPRaScreen_Data.xlsx"), sheet = 1))
stopifnot(all(d$Count == round(d$Count)))
# Pseudocount check on the sample whose raw reads are known.
u_screen <- min(d$CPM) / (min(d$Count) + 1)
stopifnot(max(abs(d$CPM / u_screen - (d$Count + 1))) < 0.01)
x <- d$refCPM
s <- min(x) / 2
for (lim in c(20, 100, 1000, 1e4, Inf)) {
  sel <- x / s <= lim
  r <- round(x[sel] / s)
  s <- sum(x[sel] * r) / sum(r^2)
}
n <- x / s
stopifnot(max(abs(n - round(n))) < 0.02)
plasmid <- round(n) - 1
stopifnot(all(plasmid >= 0))
out <- data.frame(sgRNA = d$sgRNA, Gene = d$Gene, plasmid = plasmid,
                  tdTomato_high = d$Count, stringsAsFactors = FALSE)
stopifnot(!anyDuplicated(out$sgRNA))
# 74 guides have an empty Gene cell in the workbook; they cannot be assigned
# to a gene and are dropped (library totals then exclude their reads).
out <- out[!is.na(out$Gene) & nzchar(out$Gene), ]
out <- out[order(out$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
jsonlite::write_json(list(
  list(column = "refCPM", recovered_as = "plasmid", pseudocount = 1,
       scale = signif(s, 12), max_dev = signif(max(abs(n - round(n))), 3),
       recovered_total = sum(plasmid), n = length(plasmid)),
  list(column = "CPM", check_against = "Count", pseudocount = 1,
       scale = signif(u_screen, 12))),
  file.path(workdir, "recovery_scales.json"), auto_unbox = TRUE, pretty = TRUE, digits = NA)
