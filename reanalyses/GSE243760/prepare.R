#!/usr/bin/env Rscript
# GSE243760: builds GSE243760_merged_counts.tsv from the per-sample count files
# of the transwell migration screen (D2 = replicate 1; migrated and
# non-migrated fractions), dropping the "*" (unmapped) row of each file and
# adding an "element" column from the guide label: the label without its
# trailing "_N", with "gRNA_N" renamed "DHS_N" ("gRNA_45__3" -> "DHS_45").
# Usage: Rscript prepare.R <workdir>   (needs fetch_geo.R --sample-files)

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
files <- c(nonmigrated_rep1 = "GSM7795447_D2_non-migrated.counts.gz",
           nonmigrated_rep2 = "GSM7795448_rep2_non-migrated.counts.gz",
           migrated_rep1 = "GSM7795445_D2_migrated.counts.gz",
           migrated_rep2 = "GSM7795446_rep2_migrated.counts.gz")
tables <- lapply(files, function(f) {
  x <- utils::read.delim(file.path(workdir, "sample_suppl", f), header = FALSE,
                         colClasses = "character", quote = "")
  x[x[[1]] != "*", ]
})
guide <- tables[[1]][[1]]
stopifnot(all(vapply(tables, function(x) identical(x[[1]], guide), logical(1))))
element <- sub("_+[0-9]+$", "", guide)
element <- sub("^gRNA_([0-9]+)$", "DHS_\\1", element)
out <- data.frame(guide = guide, element = element,
                  lapply(tables, `[[`, 2), check.names = FALSE)
utils::write.table(out, file.path(workdir, "GSE243760_merged_counts.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
