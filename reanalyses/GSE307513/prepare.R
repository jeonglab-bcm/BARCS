# Builds counts.tsv.gz from the PoolQ count table.
#
# suppl/GSE307513_poolq_with_sort_counts.txt.gz (GEO series supplement) has
# the guide sequence in "Row Barcode" and "<GENE>.<index>" in "Row Barcode IDs"
# (non-targeting guides are "Non-Targeting Control.<index>"). This adds a
# sgRNA column (the barcode) and a Gene column (the ID with the trailing
# ".<index>" removed); counts are unchanged.
#
#   Rscript work/GSE307513/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.delim(gzfile(file.path(workdir, "suppl", "GSE307513_poolq_with_sort_counts.txt.gz")),
                       check.names = FALSE, stringsAsFactors = FALSE)
out <- data.frame(sgRNA = x[["Row Barcode"]],
                  Gene = sub("\\.[0-9]+$", "", x[["Row Barcode IDs"]]),
                  x[, -(1:2)], check.names = FALSE, stringsAsFactors = FALSE)
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)
