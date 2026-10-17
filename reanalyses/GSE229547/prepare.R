#!/usr/bin/env Rscript
# GSE229545 / GSE229547 / GSE229548: three sublibraries of one in vivo
# Toxoplasma CRISPR study (Sangare/Tachibana et al. 2023 Cell Rep,
# doi 10.1016/j.celrep.2023.112592). For the sublibrary named by <workdir>'s
# GSE, this:
# (1) merges the per-sample GEO count files (sample_suppl/*.txt.gz, each a
#     two-column guide<TAB>count table) into counts.tsv.gz with columns
#     guide, gene (= guide ID with the trailing _<n> removed), then one
#     column per GSM (library, P3/P4 passages, WT_* in vivo WT mice,
#     KO_* in vivo Ifngr1-/- mice).
# (2) builds the paper's per-gene tables from the study supplement:
#     paper/wt_vs_ko.tsv (gene, score_diff = Score difference WT-KO,
#     p = p.value_WTvsKO) and paper/p4_vs_wt.tsv (gene, distance = Distance
#     from line, p = p.value_P4vsWT). Counts are used exactly as deposited.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
gse <- jsonlite::fromJSON(file.path(workdir, "series.json"))$gse
cfg <- list(
  GSE229545 = list(prefix = "ROP_GRA", mmc = "mmc2.xlsx",
                   wtko = "S1E summary of Screen3(Fig3)", p4wt = "S1A Contents & summary"),
  GSE229547 = list(prefix = "mem_nuc", mmc = "mmc3.xlsx",
                   wtko = "S2A Contents & summary", p4wt = "S2A Contents & summary"),
  GSE229548 = list(prefix = "metabo", mmc = "mmc4.xlsx",
                   wtko = "S3A Contents & summary", p4wt = "S3A Contents & summary")
)[[gse]]

# ---- counts ----
fs <- sort(list.files(file.path(workdir, "sample_suppl"), full.names = TRUE), method = "radix")
m <- NULL
for (f in fs) {
  nm <- sub("\\.txt\\.gz$", "", basename(f))
  nm <- sub(paste0("^GSM[0-9]+_", cfg$prefix, "_"), "", nm)
  x <- read.delim(gzfile(f), header = FALSE, col.names = c("guide", nm), stringsAsFactors = FALSE)
  m <- if (is.null(m)) x else merge(m, x, by = "guide", all = TRUE)
}
for (j in 2:ncol(m)) m[[j]][is.na(m[[j]])] <- 0L
out <- data.frame(guide = m$guide, gene = sub("_[0-9]+$", "", m$guide), m[, -1, drop = FALSE],
                  check.names = FALSE)
out <- out[order(out$gene, out$guide, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

# ---- paper tables ----
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 600)
fetch <- function(url, dest, min_size = 1e4) {
  for (i in 1:5) {
    ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > min_size) return(invisible(dest))
    Sys.sleep(10 * i)
  }
  stop("download failed: ", url)
}
xl <- file.path(workdir, "paper", cfg$mmc)
if (!file.exists(xl))
  fetch(paste0("https://ars.els-cdn.com/content/image/1-s2.0-S2211124723006034-", cfg$mmc), xl)
num <- function(v) suppressWarnings(as.numeric(v))
wk <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = cfg$wtko)))
wtko <- data.frame(gene = as.character(wk[["ID"]]),
                   score_diff = num(wk[["Score difference (WT-KO)"]]),
                   p = num(wk[["p.value_WTvsKO"]]))
wtko <- wtko[is.finite(wtko$p) & nzchar(wtko$gene), ]
wtko <- wtko[order(wtko$p, wtko$score_diff, wtko$gene, method = "radix"), ]
write.table(wtko, file.path(workdir, "paper", "wt_vs_ko.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
pw <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = cfg$p4wt)))
p4wt <- data.frame(gene = as.character(pw[["ID"]]),
                   distance = num(pw[["Distance from line"]]),
                   p = num(pw[["p.value_P4vsWT"]]))
p4wt <- p4wt[is.finite(p4wt$p) & nzchar(p4wt$gene), ]
p4wt <- p4wt[order(p4wt$p, -abs(p4wt$distance), p4wt$gene, method = "radix"), ]
write.table(p4wt, file.path(workdir, "paper", "p4_vs_wt.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
