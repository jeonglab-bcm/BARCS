#!/usr/bin/env Rscript
# GSE203456: builds counts.tsv.gz for the whole-genome Brie knockout screen in
# BA/F3-MPL cells. The deposited PoolQ table
# (GSE203456_scores-JD_GPP758_20190625_Mullally.txt.gz; despite the name it
# holds integer read counts per guide and condition) has the guide sequence
# ("Construct Barcode") and the Broad id but no gene. The gene comes from the
# deposited Brie library annotation (broadgpp-brie-library-contents.txt.gz,
# column "Target Gene Symbol", joined on the sgRNA sequence); the 1000 guides
# listed in broadgpp-brie-library-controls.csv.gz are labelled
# "Non-Targeting-Control". Guides in neither file (none expected) are dropped.
# Counts are unchanged; rows are sorted by guide sequence.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
options(timeout = 1800)  # the Europe PMC and GEO bundles are large
sup <- file.path(workdir, "suppl")
read_cr <- function(path) {
  # The Broad files use bare carriage returns as line ends.
  con <- gzfile(path, "rb")
  txt <- rawToChar(readBin(con, "raw", n = 50e6))
  close(con)
  lines <- strsplit(gsub("\r\n?", "\n", txt), "\n", fixed = TRUE)[[1]]
  lines[nzchar(lines)]
}
contents <- read_cr(file.path(sup, "GSE203456_broadgpp-brie-library-contents.txt.gz"))
contents <- utils::read.delim(text = contents, check.names = FALSE, stringsAsFactors = FALSE)
controls <- read_cr(file.path(sup, "GSE203456_broadgpp-brie-library-controls.csv.gz"))
controls <- utils::read.csv(text = controls, check.names = FALSE, stringsAsFactors = FALSE)
annot <- rbind(
  data.frame(seq = contents[["sgRNA Target Sequence"]], Gene = contents[["Target Gene Symbol"]]),
  data.frame(seq = controls[["Target Sequence"]], Gene = "Non-Targeting-Control"))
annot <- annot[!duplicated(annot$seq), ]
counts <- utils::read.delim(file.path(sup, "GSE203456_scores-JD_GPP758_20190625_Mullally.txt.gz"),
                            check.names = FALSE, stringsAsFactors = FALSE)
samples <- setdiff(names(counts), c("Construct Barcode", "Construct IDs"))
stopifnot(all(vapply(counts[samples], function(v) all(v == round(v)), logical(1))))
gene <- annot$Gene[match(counts[["Construct Barcode"]], annot$seq)]
message(sum(is.na(gene)), " guides without annotation dropped")
out <- data.frame(sgRNA = counts[["Construct Barcode"]], Gene = gene, counts[samples],
                  check.names = FALSE, stringsAsFactors = FALSE)
out <- out[!is.na(out$Gene), ]
out <- out[order(out$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

# The paper's gene-level results: supplemental Table 1 of Jutzi et al. 2022
# Blood (doi 10.1182/blood.2022015629), MAGeCK gene summaries for the
# whole-genome screen. Downloaded from the Europe PMC supplementary-file
# bundle of PMC9479036; sheet "DEL-_vs_EV+.gene_summary" (mouse "id").
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "bloodBLD2022015629-suppl3.xlsx")
if (!file.exists(xl)) {
  zip <- tempfile(fileext = ".zip")
  utils::download.file("https://www.ebi.ac.uk/europepmc/webservices/rest/PMC9479036/supplementaryFiles",
                       zip, mode = "wb", quiet = TRUE)
  utils::unzip(zip, files = "bloodBLD2022015629-suppl3.xlsx", exdir = file.path(workdir, "paper"))
  unlink(zip)
}
