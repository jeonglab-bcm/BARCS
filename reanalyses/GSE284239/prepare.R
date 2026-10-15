#!/usr/bin/env Rscript
# GSE284239: builds counts_ddr.tsv (DDR-focused library: UWB1.289 and MDA-MB-436)
# and counts_gw.tsv (genome-wide library: COV362 and HCC1395) from the per-sample
# GEO files (fetch_geo.R --sample-files). Each file lists reads per guide and
# lineage barcode (umi_barcode); reads are summed over barcodes per guide
# (gene_sgrna_id), and the samples of one library are merged on the guide, with
# guides missing from a sample set to 0. Rows sorted by guide (radix order).
# Published tables: Supplementary Tables S5-S10 of the paper (gene_symbol,
# wtheta, pVol per screen; Mol Cancer Ther 2025, doi:10.1158/1535-7163.MCT-24-0515,
# PMC12046316), taken from the Europe PMC supplementary bundle. Their numbers
# are stored as text; each is written to paper/tableS<n>.csv with numeric
# columns plus effect = wtheta - 0.5 and signed_score = sign(effect) * -log10(pVol).
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir <- file.path(workdir, "sample_suppl")

read_sample <- function(gsm) {
  file <- list.files(dir, pattern = paste0("^", gsm, "_.*\\.txt\\.gz$"), full.names = TRUE)
  stopifnot(length(file) == 1L)
  x <- utils::read.delim(gzfile(file), check.names = FALSE, stringsAsFactors = FALSE,
                         colClasses = c("character", "character", "character", "numeric"))
  sample <- names(x)[4]
  stopifnot(all(x[[4]] == round(x[[4]])), !anyNA(x[[4]]))
  genes <- unique(x[, c("gene_sgrna_id", "gene_symbol")])
  stopifnot(!anyDuplicated(genes$gene_sgrna_id))
  s <- tapply(x[[4]], x$gene_sgrna_id, sum)
  out <- data.frame(sgRNA = names(s), stringsAsFactors = FALSE)
  out$Gene <- genes$gene_symbol[match(out$sgRNA, genes$gene_sgrna_id)]
  out[[sample]] <- as.numeric(s)
  out
}

build <- function(gsms, outfile) {
  parts <- lapply(gsms, read_sample)
  ids <- unique(do.call(rbind, lapply(parts, function(p) p[, c("sgRNA", "Gene")])))
  stopifnot(!anyDuplicated(ids$sgRNA))
  ids <- ids[order(ids$sgRNA, method = "radix"), ]
  for (p in parts) {
    v <- p[[3]][match(ids$sgRNA, p$sgRNA)]
    v[is.na(v)] <- 0
    ids[[names(p)[3]]] <- format(v, scientific = FALSE, trim = TRUE)
  }
  utils::write.table(ids, file.path(workdir, outfile), sep = "\t", quote = FALSE, row.names = FALSE)
  message("Wrote ", outfile, ": ", nrow(ids), " guides, ", length(gsms), " samples")
}

build(sprintf("GSM%d", 8680598:8680604), "counts_ddr.tsv")
build(sprintf("GSM%d", 8680605:8680608), "counts_gw.tsv")

paper <- file.path(workdir, "paper")
dir.create(paper, showWarnings = FALSE)
bundle <- file.path(paper, "PMC12046316_supplementary.zip")
options(timeout = max(3600, getOption("timeout")))
url <- "https://www.ebi.ac.uk/europepmc/webservices/rest/PMC12046316/supplementaryFiles"
for (attempt in 1:3) {  # the Europe PMC service sometimes drops the connection
  ok <- tryCatch(utils::download.file(url, bundle, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE)
  if (ok) break
  Sys.sleep(30 * attempt)
}
stopifnot(ok)
for (i in 5:10) {
  xlsx <- sprintf("mct-24-0515_supplementary_table_s%d_suppst%d.xlsx", i, i)
  utils::unzip(bundle, files = xlsx, exdir = paper)
  x <- as.data.frame(readxl::read_excel(file.path(paper, xlsx), sheet = 1, skip = 1, col_types = "text"))
  stopifnot(identical(names(x), c("gene_symbol", "wtheta", "pVol")))
  tab <- data.frame(gene = x$gene_symbol, wtheta = as.numeric(x$wtheta), pVol = as.numeric(x$pVol))
  stopifnot(!anyNA(tab$gene), sum(is.finite(tab$pVol)) > 0.95 * nrow(tab))
  tab$effect <- tab$wtheta - 0.5
  tab$signed_score <- sign(tab$effect) * -log10(pmax(tab$pVol, 1e-300))
  utils::write.csv(tab, file.path(paper, sprintf("tableS%d.csv", i)), row.names = FALSE)
  unlink(file.path(paper, xlsx))
}
unlink(bundle)
