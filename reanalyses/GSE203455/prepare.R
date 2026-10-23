#!/usr/bin/env Rscript
# GSE203455: builds counts.tsv.gz for the secondary pooled knockout screen
# (library CP1547, about 250 murine genes x 8 guides plus human CALR/MPL and
# non-targeting and intergenic controls) in BA/F3-MPL cells. The deposited
# PoolQ count table (GSE203455_counts-JD_GPP1940_Jutzi.txt.gz) has the guide
# sequence but no gene, and a trailing unnamed column of unassigned reads,
# which is dropped. The gene comes from the deposited chip file
# (GSE203455_CP1547_origtarget_20200424.chip.txt.gz, "Annotated Gene Symbol",
# joined on the sequence); controls keep their library labels (NO_SITE_n
# non-targeting, ONE_INTERGENIC_SITE_n intergenic cutting). Counts are
# unchanged; rows are sorted by guide sequence.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
options(timeout = 1800)  # the Europe PMC and GEO bundles are large
sup <- file.path(workdir, "suppl")
con <- gzfile(file.path(sup, "GSE203455_CP1547_origtarget_20200424.chip.txt.gz"), "rb")
txt <- rawToChar(readBin(con, "raw", n = 10e6))
close(con)
chip <- utils::read.delim(text = gsub("\r\n?", "\n", txt), check.names = FALSE,
                          stringsAsFactors = FALSE)
counts <- utils::read.delim(file.path(sup, "GSE203455_counts-JD_GPP1940_Jutzi.txt.gz"),
                            check.names = FALSE, stringsAsFactors = FALSE)
samples <- setdiff(names(counts), c("Construct Barcode", "Construct IDs", ""))
samples <- samples[!grepl("^V[0-9]+$|^\\.\\.\\.", samples)]
stopifnot(length(samples) == 13)
stopifnot(all(vapply(counts[samples], function(v) all(v == round(v)), logical(1))))
gene <- chip[["Annotated Gene Symbol"]][match(counts[["Construct Barcode"]], chip[["Barcode Sequence"]])]
stopifnot(!anyNA(gene))
out <- data.frame(sgRNA = counts[["Construct Barcode"]], Gene = gene, counts[samples],
                  check.names = FALSE, stringsAsFactors = FALSE)
out <- out[order(out$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

# The paper's gene-level results for this screen: supplemental Table 3 of
# Jutzi et al. 2022 Blood (doi 10.1182/blood.2022015629), MAGeCK gene
# summaries (header on row 6). Downloaded from the Europe PMC
# supplementary-file bundle of PMC9479036; the DEL-_vs_EV+ sheet is written
# to paper/pooled_DELminus_vs_EVplus.tsv unchanged apart from the layout.
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "bloodBLD2022015629-suppl5.xlsx")
if (!file.exists(xl)) {
  zip <- tempfile(fileext = ".zip")
  utils::download.file("https://www.ebi.ac.uk/europepmc/webservices/rest/PMC9479036/supplementaryFiles",
                       zip, mode = "wb", quiet = TRUE)
  utils::unzip(zip, files = "bloodBLD2022015629-suppl5.xlsx", exdir = file.path(workdir, "paper"))
  unlink(zip)
}
tab <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "DEL-_vs_EV+.gene_summary", skip = 5)))
tab <- tab[!is.na(tab$id), ]
utils::write.table(tab, file.path(workdir, "paper", "pooled_DELminus_vs_EVplus.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
