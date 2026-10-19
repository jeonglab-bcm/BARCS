#!/usr/bin/env Rscript
# GSE312143: genome-wide in vivo HSPC knockout screen with the 10 Bassik mouse
# sub-libraries (ACOC, DTKP, GE, MP, MU1, MU2, SP, TMM, U1, U2; ~20,000
# elements each), one transplant pool per sub-library, plus a second,
# independent transplant screen of the gene-expression (GE) sub-library.
# GEO holds one count file per sorted population for the genome-wide screen
# (all sub-libraries in one file; the guide ID names the sub-library, e.g.
# ENSMUSG00000042817_Flt3_DTKPA_219060.5) and per-sample files for the GE
# screen. No plasmid or pre-transplant library was deposited.
# (1) counts.tsv.gz: one row per guide (union over the files), with
#     columns HSPC_<sub-library> and AllLineage_<sub-library> for the
#     genome-wide screen (a guide has reads only in the columns of its own
#     sub-library, so each column sums to that sub-library's library size),
#     and HSPC_GEscreen and AllLineage_GEscreen for the GE screen. Guides
#     absent from a file had no reads (0). Line endings (CRLF) are dropped.
#     One guide ID (ENSMUSG00000078765_U2af1l4_MU2A_163623.3) appears twice
#     with different counts in the genome-wide All_Lineage file and is left
#     out. Gene = the symbol in the ID; 0None (non-targeting) and 0Safe
#     (safe-targeting) controls get genes "NonTargeting" and "SafeTargeting".
# (2) paper/castle_*.tsv from Supplementary Data 1 (genome-wide) and 2 (GE
#     screen) of the paper (doi 10.1038/s41467-026-68465-6), sheet
#     HSPC_vs_All_Lineages (casTLE): gene (symbol spelled as in the count
#     file), casTLE effect (negative = knockout enriched in HSPCs), casTLE
#     score and p-value, and hspc_score = casTLE score signed so that higher
#     means enriched in HSPCs relative to mature lineages. castle_gw_GE.tsv
#     keeps the genome-wide genes targeted by the GE sub-library.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = 600)
fetch <- function(url, dest) {
  for (i in 1:5) {
    ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > 1e5) return(invisible(dest))
    Sys.sleep(10 * i)
  }
  stop("download failed: ", url)
}
read_counts <- function(path) {
  x <- utils::read.csv(gzfile(path), header = FALSE, col.names = c("id", "count"),
                       colClasses = c("character", "character"))
  x$count <- as.numeric(sub("\r$", "", x$count))
  stopifnot(!anyNA(x$count), all(x$count == round(x$count)))
  x
}
files <- c(
  GW_HSPC = file.path("suppl", "GSE312143_GW_HSPC_counts.csv.gz"),
  GW_AllLineage = file.path("suppl", "GSE312143_GW_All_Lineage_counts.csv.gz"),
  GE_HSPC = file.path("sample_suppl", "GSM9339040_GE_Screen_HSPC_counts.csv.gz"),
  GE_AllLineage = file.path("sample_suppl", "GSM9339037_GE_Screen_All_Lineage_counts.csv.gz"))
tables <- lapply(files, function(f) read_counts(file.path(workdir, f)))
dup <- unique(unlist(lapply(tables, function(x) x$id[duplicated(x$id)])))
message("duplicated IDs left out: ", paste(dup, collapse = ", "))
ids <- sort(setdiff(unique(unlist(lapply(tables, `[[`, "id"))), dup), method = "radix")
parts <- regmatches(ids, regexec("^([^_]+)_(.+)_([A-Z0-9]+?)([AB])_([0-9.]+)$", ids))
stopifnot(all(lengths(parts) == 6L))
symbol <- vapply(parts, `[`, "", 3)
sublib <- vapply(parts, `[`, "", 4)
gene <- ifelse(grepl("^0None", ids), "NonTargeting",
               ifelse(grepl("^0Safe", ids), "SafeTargeting", symbol))
value <- function(name) {
  x <- tables[[name]]
  v <- x$count[match(ids, x$id)]
  v[is.na(v)] <- 0
  v
}
out <- data.frame(sgRNA = ids, Gene = gene, sublibrary = sublib, stringsAsFactors = FALSE)
libraries <- sort(unique(sublib))
stopifnot(identical(libraries, c("ACOC", "DTKP", "GE", "MP", "MU1", "MU2", "SP", "TMM", "U1", "U2")))
for (population in c("HSPC", "AllLineage")) {
  v <- value(paste0("GW_", population))
  for (s in libraries) out[[paste0(population, "_", s)]] <- ifelse(sublib == s, v, 0)
}
# The GE screen files hold only GE guides.
stopifnot(all(sublib[ids %in% c(tables$GE_HSPC$id, tables$GE_AllLineage$id)] == "GE"))
out$HSPC_GEscreen <- value("GE_HSPC")
out$AllLineage_GEscreen <- value("GE_AllLineage")
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

base <- "https://media.springernature.com/original/springer-static/esm/art%3A10.1038%2Fs41467-026-68465-6/MediaObjects/"
spelling <- unique(gene[!gene %in% c("NonTargeting", "SafeTargeting")])
spelling <- spelling[!duplicated(toupper(spelling))]
castle <- function(xlsx) {
  path <- file.path(workdir, "paper", xlsx)
  if (!file.exists(path)) fetch(paste0(base, xlsx), path)
  # The genome-wide sheet has no header row; the GE sheet has one.
  d <- as.data.frame(suppressMessages(readxl::read_excel(path, sheet = "HSPC_vs_All_Lineages",
                                                         col_names = FALSE)))
  if (identical(d[1, 1], "#GeneID")) d <- d[-1, ]
  d <- data.frame(symbol = d[[2]], effect = as.numeric(d[[3]]), score = as.numeric(d[[4]]),
                  p_value = as.numeric(d[[5]]), stringsAsFactors = FALSE)
  d$gene <- spelling[match(toupper(d$symbol), toupper(spelling))]
  d$gene[is.na(d$gene)] <- d$symbol[is.na(d$gene)]
  d$hspc_score <- ifelse(d$effect < 0, d$score, -d$score)
  d[, c("gene", "effect", "score", "p_value", "hspc_score")]
}
gw <- castle("41467_2026_68465_MOESM3_ESM.xlsx")
ge <- castle("41467_2026_68465_MOESM4_ESM.xlsx")
utils::write.table(gw, file.path(workdir, "paper", "castle_gw.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
utils::write.table(gw[gw$gene %in% gene[sublib == "GE"], ], file.path(workdir, "paper", "castle_gw_GE.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE)
utils::write.table(ge, file.path(workdir, "paper", "castle_gescreen.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
