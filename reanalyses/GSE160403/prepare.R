#!/usr/bin/env Rscript
# GSE160403 (Stavast et al. 2022 Leukemia, PMID 34741119): builds counts.tsv
# from the three per-sample count files on GEO and paper/per_gene.tsv from the
# authors' gene-level table (Supplementary Table 6, MOESM12, sheet "Per Gene").
# Each GEO file has lines "<gene>:<probe>,<reads>" plus a first line "*,<n>"
# holding reads that matched no guide; that line is dropped. Guides absent from
# a file had zero reads in that library. Gene names are as deposited (some were
# turned into dates by a spreadsheet, e.g. 10-Mar; they are left unchanged).
# Usage: Rscript prepare.R <workdir>   (after fetch_geo.R GSE160403 --sample-files)
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
base <- "https://ftp.ncbi.nlm.nih.gov/geo/samples/GSM4873nnn"
files <- c(WT14d = "GSM4873002/suppl/GSM4873002_I18-1261-01.csv.gz",
           KO14d = "GSM4873003/suppl/GSM4873003_I18-1261-02.csv.gz",
           WT24h = "GSM4873004/suppl/GSM4873004_I18-1263-01.csv.gz")
dir.create(file.path(workdir, "sample_suppl"), showWarnings = FALSE)
tabs <- lapply(names(files), function(s) {
  local <- file.path(workdir, "sample_suppl", basename(files[[s]]))
  if (!file.exists(local)) utils::download.file(file.path(base, files[[s]]), local, mode = "wb", quiet = TRUE)
  x <- utils::read.csv(local, header = FALSE, col.names = c("id", "n"), stringsAsFactors = FALSE)
  x[x$id != "*", ]
})
ids <- sort(unique(unlist(lapply(tabs, `[[`, "id"))), method = "radix")
out <- data.frame(sgRNA = sub("^.*:", "", ids), gene = sub(":[^:]*$", "", ids))
for (i in seq_along(files)) {
  v <- tabs[[i]]$n[match(ids, tabs[[i]]$id)]
  v[is.na(v)] <- 0L
  out[[names(files)[i]]] <- as.integer(v)
}
stopifnot(!anyDuplicated(out$sgRNA))
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41375-021-01461-5/MediaObjects/41375_2021_1461_MOESM12_ESM.xlsx"
xl <- file.path(workdir, "paper", "41375_2021_1461_MOESM12_ESM.xlsx")
if (!file.exists(xl)) utils::download.file(url, xl, mode = "wb", quiet = TRUE)
g <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "Per Gene")))
g <- g[!grepl("^NonTargeting", g$gene_id), ]
pg <- data.frame(gene = g$gene_id, WT14d = g$WT14d, KO14d = g$KO14d,
                 guides_over_10x = g[["probes over 10X"]],
                 log2fc_WT_vs_KO = g[["log2 fc"]], neg_fdr = g$neg.fdr,
                 pos_fdr = g$pos.fdr, pvalue = g$pvalue)
pg <- pg[order(pg$pvalue, pg$log2fc_WT_vs_KO), ]
utils::write.table(pg, file.path(workdir, "paper", "per_gene.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
