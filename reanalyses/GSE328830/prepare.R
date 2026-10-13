#!/usr/bin/env Rscript
# GSE328830: builds counts_aggregated.txt.gz, a guide-level count table from the
# 657 MB clone-resolved long table
# GSE328830_cstar_screen_118_mice_and_validation_49_mice_A549_data.csv.gz
# (one row per guide x UMI x tumor with active_count and inactive_count; needs
# fetch_geo.R --max-mb 800). For the two in vivo cohorts (group_name
# invivo_screen = 118 mice -> "screen", invivo_validation = 49 mice -> "val")
# it sums active and inactive counts over all UMIs and tumors of each guide,
# giving columns screen_active, screen_inactive, val_active, val_inactive.
# The in vitro groups (inVitro_PD7, inVitro_PD21) are not summed. Rows are all
# 29,059 guides in the file, sorted by guide (3 seen only in vitro get zeros);
# Gene = gene_symbol.
# The file is read in chunks of 2 million lines to keep memory small.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
con <- gzfile(file.path(workdir, "suppl",
  "GSE328830_cstar_screen_118_mice_and_validation_49_mice_A549_data.csv.gz"), "r")
header <- strsplit(readLines(con, n = 1L), ",", fixed = TRUE)[[1]]
cohorts <- c(invivo_screen = "screen", invivo_validation = "val")
sums <- NULL
all_ids <- character()
repeat {
  lines <- readLines(con, n = 2e6L)
  if (!length(lines)) break
  x <- utils::read.csv(text = lines, header = FALSE, col.names = header,
                       colClasses = c("character", "NULL", "character", "NULL",
                                      "numeric", "numeric", "NULL", "character"))
  all_ids <- unique(c(all_ids, paste(x$guide, x$gene_symbol, sep = "\t")))
  x <- x[x$group_name %in% names(cohorts), ]
  key <- paste(x$guide, x$gene_symbol, cohorts[x$group_name], sep = "\t")
  chunk <- rowsum(cbind(active = x$active_count, inactive = x$inactive_count), key)
  sums <- if (is.null(sums)) chunk else rowsum(rbind(sums, chunk), rownames(rbind(sums, chunk)))
}
close(con)

parts <- do.call(rbind, strsplit(rownames(sums), "\t", fixed = TRUE))
id <- paste(parts[, 1], parts[, 2], sep = "\t")
ids <- sort(all_ids, method = "radix")
counts <- data.frame(guide = sub("\t.*$", "", ids), Gene = sub("^.*\t", "", ids))
for (cohort in cohorts) for (state in c("active", "inactive")) {
  value <- numeric(length(ids))
  hit <- parts[, 3] == cohort
  value[match(id[hit], ids)] <- sums[hit, state]
  counts[[paste(cohort, state, sep = "_")]] <- value
}
stopifnot(!anyDuplicated(counts$guide), all(as.matrix(counts[-(1:2)]) == round(as.matrix(counts[-(1:2)]))))
out <- gzfile(file.path(workdir, "counts_aggregated.txt.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)
