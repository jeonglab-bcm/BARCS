# Builds GSE275043_merged_counts.txt.gz by joining the six per-sample read-count
# files (sample_suppl/, from fetch_geo.R --sample-files). All files list the
# same 77,441 gRNAs in the same order; the count columns are renamed
# <bin>_<rep> from the file names (high20_rep1, low20_rep1, unsorted_rep1, ...).
# Counts are unchanged.
#
#   Rscript reanalyses/GSE275043/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
files <- sort(list.files(file.path(workdir, "sample_suppl"), pattern = "_readcount\\.txt\\.gz$",
                         full.names = TRUE))
stopifnot(length(files) == 6)
counts <- NULL
for (file in files) {
  sample <- utils::read.delim(file, check.names = FALSE)
  name <- sub("^GSM[0-9]+_JURKAT_(rep[12])_d7_gal9([a-z0-9]+)_.*$", "\\2_\\1", basename(file))
  if (is.null(counts)) counts <- sample[, 1:2]
  stopifnot(identical(counts$gRNA, sample$gRNA), all(sample[[3]] == round(sample[[3]])))
  counts[[name]] <- as.integer(sample[[3]])
}
out <- gzfile(file.path(workdir, "GSE275043_merged_counts.txt.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)
