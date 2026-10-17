#!/usr/bin/env Rscript
# GSE217131 (Kim et al. 2024 Cell, PMID 38866017): builds counts.tsv from the
# "large pool" gRNA raw-count workbook (a focused 538-guide library: ~160 cell-
# death / survival genes with 3 guides each, plus 50 non-targeting guides).
# Each condition sheet holds NAME, ALIAS, SEQ, LIB and two replicate count
# columns: Day16 Dox- (pre-editing baseline), Day25 Dox- (no Cas9), Day25 Dox+
# (edited, in vitro), and Day25 Graft Dox+ (edited, grafted in vivo; two grafts).
# Guides are matched by NAME across sheets; gene = NAME without the trailing
# _<k>; the 50 NonTargeting... guides form the control group.
# Usage: Rscript prepare.R <workdir>   (reads suppl/..large_pool..xlsx)
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
xl <- file.path(workdir, "suppl", "GSE217131_220929_large_pool_gRNA_raw_and_processed.xlsx")
sheets <- c(D16_Dox_neg = "Day16", D25_Dox_neg = "Day25 Dox-",
            D25_Dox_pos = "Day25 Dox+", D25_Graft = "Day25 Graft Dox+")
read_sheet <- function(sh) {
  d <- as.data.frame(readxl::read_excel(xl, sheet = sh))
  d <- d[!is.na(d$NAME), ]
  cnt <- d[, 5:6]
  data.frame(NAME = d$NAME, a = as.integer(round(cnt[[1]])), b = as.integer(round(cnt[[2]])),
             stringsAsFactors = FALSE)
}
tabs <- lapply(sheets, read_sheet)
name <- tabs[[1]]$NAME
for (tb in tabs) stopifnot(setequal(tb$NAME, name), !anyDuplicated(tb$NAME))
# The two count columns of each sheet are technical re-reads of one library
# (correlation > 0.998, near-constant ratio), so they are summed into one
# library per condition (SKILL.md: sum technical re-reads before analysis).
cols <- list()
for (k in names(sheets)) {
  tb <- tabs[[k]][match(name, tabs[[k]]$NAME), ]
  cols[[k]] <- tb$a + tb$b
}
gene <- sub("_[0-9]+$", "", name)
gene[grepl("^NonTargeting", name)] <- "NonTargeting"
out <- data.frame(guide = name, gene = gene, as.data.frame(cols, check.names = FALSE),
                  check.names = FALSE)
out <- out[order(out$guide, method = "radix"), ]
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
