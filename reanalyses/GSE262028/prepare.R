#!/usr/bin/env Rscript
# GSE262028: builds counts.tsv.gz, the eight sorted populations the authors
# used, from the four GEO count files GSE262028_<screen>_lib_data.csv.gz.
# Each lib_data file holds the same 4,732-guide library (sgRNA.Target.Sequence,
# gene_id, gene_symbol, UID) with columns pool.1..pool.N; pool.k is row k of the
# matching GSE262028_<screen>_screen_list.csv.gz. The screen lists mark the two
# pools of each screen that the authors compared (columns Screen and Bin, P or N);
# exactly those pools are taken:
#   S17: S17_tomp (P) and S17_linn (N)      IL-13 tdTomato screen
#   S25: S25_Tp (P) and S25_Neg (N)         IL-13 tdTomato screen
#   S31: S31_ILC2 (P) and S31_NK (N)        GATA3/T-bet reporter screen
#   S35: S35_GATA3 (P) and S35_TBET (N)     GATA3/T-bet reporter screen
# Columns are named <screen>_<P|N>. The four files are merged on UID after
# checking that sequence and gene agree. Non-targeting guides (UID NT100A_/NT100B_,
# gene_symbol "0") get gene "NonTargeting". Rows sorted by UID.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
screens <- c("S17", "S25", "S31", "S35")
out <- NULL
for (s in screens) {
  lib <- utils::read.csv(file.path(workdir, "suppl", sprintf("GSE262028_%s_lib_data.csv.gz", s)),
                         check.names = FALSE, stringsAsFactors = FALSE)
  lst <- utils::read.csv(file.path(workdir, "suppl", sprintf("GSE262028_%s_screen_list.csv.gz", s)),
                         check.names = FALSE, stringsAsFactors = FALSE)
  used <- lst[!is.na(lst$Screen) & lst$Screen == s, ]
  stopifnot(nrow(used) == 2L, setequal(used$Bin, c("P", "N")))
  counts <- lib[, paste0("pool.", used$Pool)]
  names(counts) <- paste0(s, "_", used$Bin)
  message(s, ": ", paste(names(counts), used$lib.file.name, sep = " = ", collapse = "; "))
  part <- data.frame(UID = lib$UID, sequence = lib$sgRNA.Target.Sequence,
                     gene = as.character(lib$gene_symbol), counts, check.names = FALSE,
                     stringsAsFactors = FALSE)
  stopifnot(!anyDuplicated(part$UID))
  part <- part[order(part$UID, method = "radix"), ]
  if (is.null(out)) {
    out <- part
  } else {
    stopifnot(identical(out$UID, part$UID), identical(out$sequence, part$sequence),
              identical(out$gene, part$gene))
    out <- cbind(out, part[-(1:3)])
  }
}
out$gene[grepl("^NT100[AB]_", out$UID)] <- "NonTargeting"
out <- out[, c("UID", "sequence", "gene", paste0(rep(screens, each = 2), c("_N", "_P")))]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
