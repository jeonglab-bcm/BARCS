#!/usr/bin/env Rscript
# GSE235620 (Prezza et al. 2024 PNAS, PMID 38294941): builds counts.tsv from the
# nine per-sample CRISPRi count files (fetch_geo.R --sample-files). Each file is
# a headerless "<guide>\t<count>" table with the same 667 guides (library
# members): sRNA-targeting guides named <sRNA>_mature_<k> or <sRNA>_array_<k>
# (some target several sRNAs, named <sRNA1>|<sRNA2>_..._<k>) and 20 non_targeting
# controls. Gene = guide name with the trailing _mature_<k>/_array_<k> removed,
# so all guides of one sRNA group share a gene; BTnc167 is BatR in the paper.
# Columns: three library (glycerol stock), three tyg (rich medium), three bile
# (rich medium + bile salts) replicates. Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir <- file.path(workdir, "sample_suppl")
spec <- c(library_1 = "GSM7506305_library_r1", library_2 = "GSM7506306_library_r2",
          library_3 = "GSM7506307_library_r3", bile_1 = "GSM7506308_bile_stat_1",
          bile_2 = "GSM7506309_bile_stat_2", bile_3 = "GSM7506310_bile_stat_3",
          tyg_1 = "GSM7506311_tyg_stat_1", tyg_2 = "GSM7506312_tyg_stat_2",
          tyg_3 = "GSM7506313_tyg_stat_3")
tabs <- lapply(spec, function(p) {
  f <- list.files(dir, pattern = paste0("^", p), full.names = TRUE)
  stopifnot(length(f) == 1)
  utils::read.delim(f, header = FALSE, stringsAsFactors = FALSE,
                    col.names = c("guide", "count"), colClasses = c("character", "integer"))
})
guides <- tabs[[1]]$guide
for (tb in tabs) stopifnot(identical(tb$guide, guides), !anyDuplicated(tb$guide))
mat <- sapply(tabs, function(tb) tb$count)
# A sRNA group is targeted by up to three "mature" guides (<sRNA>_mature_<k>)
# and one full CRISPR "array" guide (<sRNA>_array); the paper averages over all
# of them, so both map to the sRNA. The 20 non-targeting guides form one control
# group.
gene <- sub("_array$", "", sub("_mature_[0-9]+$", "", guides))
gene[grepl("^non_targeting", guides)] <- "non_targeting"
out <- data.frame(guide = guides, gene = gene, mat, check.names = FALSE)
names(out)[-(1:2)] <- names(spec)
out <- out[order(out$guide, method = "radix"), ]
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

# Paper's per-sRNA edgeR table (Dataset S4), the bile-vs-tyg fitness scores.
# Downloaded in the Europe PMC supplementary-file bundle (the PNAS host blocks
# direct supplement requests from this environment).
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://www.ebi.ac.uk/europepmc/webservices/rest/PMC10861873/supplementaryFiles"
xl <- file.path(workdir, "paper", "sd04.xlsx")
if (!file.exists(xl)) {
  zipf <- file.path(workdir, "paper", "epmc_suppl.zip")
  old <- options(timeout = 600); on.exit(options(old))
  for (attempt in 1:5) {
    ok <- tryCatch({utils::download.file(url, zipf, mode = "wb", quiet = TRUE); TRUE},
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(zipf) && file.size(zipf) > 0) break
    unlink(zipf); Sys.sleep(10 * attempt)
  }
  utils::unzip(zipf, files = "pnas.2311323121.sd04.xlsx", exdir = file.path(workdir, "paper"))
  file.rename(file.path(workdir, "paper", "pnas.2311323121.sd04.xlsx"), xl)
  unlink(zipf)
}
d <- as.data.frame(readxl::read_excel(xl, sheet = "Per sRNA"))
for (j in 2:5) d[[j]] <- signif(as.numeric(d[[j]]), 6)
d <- d[order(d$sRNA, method = "radix"), ]
utils::write.table(d, file.path(workdir, "paper", "per_sRNA.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
# compare.json matches genes by name: the paper calls BTnc167 by its name BatR,
# while the guide IDs in the count file use BTnc167.
m <- d
m$sRNA[m$sRNA == "BatR"] <- "BTnc167"
utils::write.table(m, file.path(workdir, "paper", "per_sRNA_matched.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
