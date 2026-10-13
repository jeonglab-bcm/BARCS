# Builds GSE288230_Genome_Scale_Library_Raw_Counts_noBOM.tsv.gz and
# GSE288230_Secondary_Library_Raw_Counts_noBOM.tsv.gz from the GEO CSVs in
# suppl/. The deposited files start with a UTF-8 byte-order mark, so the first
# header cell would read as BOM + "sgRNA" and not match the guide column. This
# reads them without the mark, sets the missing values in the plasmid column
# (41 in the genome-scale file) to 0 and writes them tab-separated. Sample
# counts are unchanged.
#
#   Rscript reanalyses/GSE288230/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
for (library in c("Genome_Scale", "Secondary")) {
  counts <- utils::read.csv(file.path(workdir, "suppl", sprintf("GSE288230_%s_Library_Raw_Counts.csv.gz", library)),
                            fileEncoding = "UTF-8-BOM", check.names = FALSE, stringsAsFactors = FALSE)
  plasmid <- grep("Plasmid_Library$", names(counts))
  counts[[plasmid]][is.na(counts[[plasmid]])] <- 0
  stopifnot(!anyNA(counts))
  out <- gzfile(file.path(workdir, sprintf("GSE288230_%s_Library_Raw_Counts_noBOM.tsv.gz", library)), "w")
  utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
  close(out)
}
