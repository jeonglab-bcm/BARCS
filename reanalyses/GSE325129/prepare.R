# Builds counts.tsv.gz for GSE325129: the hCRISPRi-v2 MHC-I sort count table
# with one header row and a gene column.
#
# GEO's GSE325129_ACV_Patu_MHCI_CRISPRi_rawcountstable.txt.gz (ScreenProcessing
# output) starts with four header lines: condition (MHChi/MHClo), replicate
# (Rep1), the source count-file path, and an 'sgId' line. They are skipped and
# the columns named MHChi and MHClo. The gene is the sgId prefix before the
# first '_' (e.g. A1BG_+_58858549.23-P1 -> A1BG; non-targeting_01893 ->
# non-targeting); guides for alternative promoters (-P1/-P2) count as one gene.
# If the series file is missing it is downloaded from the GEO FTP.
#
#   Rscript work/GSE325129/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
name <- "GSE325129_ACV_Patu_MHCI_CRISPRi_rawcountstable.txt.gz"
url <- paste0("https://ftp.ncbi.nlm.nih.gov/geo/series/GSE325nnn/GSE325129/suppl/", name)
path <- file.path(workdir, "suppl", name)
if (!file.exists(path)) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  utils::download.file(url, path, mode = "wb", quiet = TRUE)
}
head4 <- readLines(path, n = 4)
stopifnot(identical(strsplit(head4[1], "\t")[[1]][2:3], c("MHChi", "MHClo")),
          startsWith(head4[4], "sgId"))
x <- utils::read.delim(path, header = FALSE, skip = 4, stringsAsFactors = FALSE,
                       col.names = c("sgId", "MHChi", "MHClo"))
stopifnot(!anyDuplicated(x$sgId), !anyNA(x$MHChi), !anyNA(x$MHClo),
          all(x$MHChi == round(x$MHChi)), all(x$MHClo == round(x$MHClo)))
x$gene <- sub("_.*$", "", x$sgId)
x <- x[, c("sgId", "gene", "MHChi", "MHClo")]
out <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(x, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)
