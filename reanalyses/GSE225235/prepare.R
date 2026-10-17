#!/usr/bin/env Rscript
# GSE225235: the GEO count table (MAGeCK count, Brunello library, 76,441 guides,
# no non-targeting guides) has four columns per library, suffixes _A.._D,
# which are sequencing re-reads of one library (pairwise Poisson z variance
# about 1.0). This script sums them into one column per library
# (e.g. CD58_lo_1A = CD58_lo_1A_A + _B + _C + _D), and also sums the two
# technical sort replicates of each biological replicate (e.g. CD58_lo_1 =
# CD58_lo_1A + CD58_lo_1B). Writes counts_summed.tsv.gz.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- utils::read.delim(gzfile(file.path(workdir, "suppl", "GSE225235_all_samples.count.txt.gz")),
                       check.names = FALSE, stringsAsFactors = FALSE)
m <- as.matrix(x[, -(1:2)])
lib <- sub("_[A-D]$", "", colnames(m))
libs <- sort(unique(lib), method = "radix")
out <- x[, 1:2]
for (l in libs) out[[l]] <- as.integer(rowSums(m[, lib == l, drop = FALSE]))
bio <- sort(unique(sub("[AB]$", "", grep("^CD58_", libs, value = TRUE))), method = "radix")
for (b in bio) out[[b]] <- out[[paste0(b, "A")]] + out[[paste0(b, "B")]]
out <- out[order(out$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts_summed.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

# Paper table: Supplemental Table 2 (mmc3.xlsx) of Ho et al. 2023 Cancer Cell
# (doi 10.1016/j.ccell.2023.05.014) holds four MAGeCK gene summaries, one per
# technical sort pair (CD58_low_<rep><A|B> vs CD58_mi_<rep><A|B>). Combined
# here per gene: mean_pos_rank = mean MAGeCK pos|rank over the four (lower =
# more enriched in CD58-low), n_pos_fdr10 = number of the four with
# pos|fdr < 0.10, mean_lfc = mean pos|lfc (low vs mid). Writes
# paper/cd58_mageck_combined.tsv.
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 600)
fetch <- function(url, dest, min_size = 1e5) {
  for (i in 1:5) {
    ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > min_size) return(invisible(dest))
    Sys.sleep(10 * i)
  }
  stop("download failed: ", url)
}
xl <- file.path(workdir, "paper", "mmc3.xlsx")
if (!file.exists(xl)) fetch("https://ars.els-cdn.com/content/image/1-s2.0-S1535610823001812-mmc3.xlsx", xl)
sheets <- sort(readxl::excel_sheets(xl), method = "radix")
tabs <- lapply(sheets, function(s) {
  d <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = s, skip = 1)))
  data.frame(gene = as.character(d$id), rank = as.numeric(d[["pos|rank"]]),
             fdr = as.numeric(d[["pos|fdr"]]), lfc = as.numeric(d[["pos|lfc"]]))
})
genes <- sort(unique(unlist(lapply(tabs, `[[`, "gene"))), method = "radix")
pick <- function(col) sapply(tabs, function(t) t[[col]][match(genes, t$gene)])
rk <- pick("rank"); fd <- pick("fdr"); lf <- pick("lfc")
out <- data.frame(gene = genes,
                  mean_pos_rank = round(rowMeans(rk, na.rm = TRUE), 2),
                  n_pos_fdr10 = rowSums(fd < 0.10, na.rm = TRUE),
                  mean_lfc = round(rowMeans(lf, na.rm = TRUE), 4))
out <- out[order(out$mean_pos_rank, out$gene, method = "radix"), ]
utils::write.table(out, file.path(workdir, "paper", "cd58_mageck_combined.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
