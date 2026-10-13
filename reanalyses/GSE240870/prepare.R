# Builds GSE240870_CRISPRa_counts_clean.tsv.gz from the GEO file
# suppl/GSE240870_CRISPRa_raw_count_screen.csv.gz. That file has a second
# header row (DMSO-1, DMSO-2, ISX9-1, ISX9-2, M+I -1, M+I -2) under the
# sequencing IDs TZa15-7..12; this drops the row, uses it as the column names
# ("M+I -1" becomes "MI-1") and writes the counts unchanged, tab-separated.
#
#   Rscript reanalyses/GSE240870/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
raw <- utils::read.csv(file.path(workdir, "suppl", "GSE240870_CRISPRa_raw_count_screen.csv.gz"),
                       check.names = FALSE, colClasses = "character")
labels <- unlist(raw[1, 3:8])
counts <- raw[-1, ]
names(counts) <- c("sgRNA", "Gene", gsub("[ +]", "", sub("M+I", "MI", labels, fixed = TRUE)))
for (j in 3:8) counts[[j]] <- as.integer(counts[[j]])

out <- gzfile(file.path(workdir, "GSE240870_CRISPRa_counts_clean.tsv.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)
