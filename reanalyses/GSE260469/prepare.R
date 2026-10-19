#!/usr/bin/env Rscript
# GSE260469 (B16F10 druggable-library in vivo lung-metastasis screen, OPG paper,
# PMID 39674088). Builds counts.tsv from the single series count file
# (suppl/GSE260469_drug.library.sgRNA.counts..csv.gz, from fetch_geo.R). The
# file has paired technical re-reads of each library in columns 1.X / 2.X
# (constant ~3-fold ratio, r = 0.995); these are summed into one count per
# library: cell (in vitro input), IgG (metastases, control antibody) and csf1r
# (metastases, anti-Csf1R, Mo-macs depleted). guide = Oligo_Name, gene =
# Gene_Symbol. Rows sorted by Oligo_Name. Also downloads the paper's MAGeCK
# gene_summary (anti-Csf1R vs IgG) as paper/mmc5.xlsx for the comparison.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
src <- file.path(workdir, "suppl", "GSE260469_drug.library.sgRNA.counts..csv.gz")
d <- utils::read.csv(src, check.names = FALSE, stringsAsFactors = FALSE)
pair <- function(a, b) {
  stopifnot(all(d[[a]] == round(d[[a]])), all(d[[b]] == round(d[[b]])))
  d[[a]] + d[[b]]
}
out <- data.frame(
  guide = d[["Oligo_Name"]],
  gene  = d[["Gene_Symbol"]],
  cell  = pair("1.cell.counts", "2.cell.counts"),
  IgG   = pair("1.IgG.counts", "2.IgG.counts"),
  csf1r = pair("1.csf1r.counts", "2.csf1r.counts"),
  stringsAsFactors = FALSE
)
stopifnot(!anyNA(out), !anyDuplicated(out$guide), nrow(out) == 5053)
out <- out[order(out$guide, method = "radix"), ]
utils::write.table(out, file.path(workdir, "counts.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)

# Paper's MAGeCK gene_summary tables, from the open-access eBioMedicine
# supplement (PMC11700254). mmc5 is the anti-Csf1R vs IgG comparison in which
# OPG (Tnfrsf11b) is a top positively selected gene.
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://www.ebi.ac.uk/europepmc/webservices/rest/PMC11700254/supplementaryFiles"
zip <- file.path(workdir, "paper", "supp.zip")
options(timeout = 600)
ok <- FALSE
for (attempt in 1:5) {
  ok <- tryCatch(utils::download.file(url, zip, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.size(zip) > 100000) break
  Sys.sleep(10 * attempt)
}
if (!ok) stop("download failed: ", url)
utils::unzip(zip, files = "mmc5.xlsx", exdir = file.path(workdir, "paper"))
stopifnot(file.exists(file.path(workdir, "paper", "mmc5.xlsx")))
