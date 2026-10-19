#!/usr/bin/env Rscript
# GSE245845: the GEO count file (GSE245845_Reads_number_total.txt.gz) was
# written without field separators, so the two count columns are run together
# ("1734" for 17 and 34) and cannot be split from it alone. The same raw read
# counts are in Supplementary Data 1 of Lai et al. 2026 Nat Commun
# (doi 10.1038/s41467-026-71726-z), sheet "Raw_reads_number_analysis".
# (1) counts.tsv.gz: sgRNA, Gene, Proins_Hi, Proins_Lo from that sheet, after
#     checking that every row matches the GEO file (same guide ID, and the two
#     counts written side by side give the GEO characters). In both files a
#     zero count is written "NA" (the paper's own log2 fold changes, computed
#     as log2((Hi + 5) / (Lo + 5)) plus a constant, confirm the value 0), so NA
#     counts become 0. Guides with no reads in the Hi library also lost their
#     gene name, and 146 names were turned into Excel dates (March1, Sept1);
#     genes are therefore taken from the mouse GeCKOv2 (A + B) library file
#     MAGeCK distributes, matched on the guide ID.
# (2) paper/significant_genes.tsv: the 84 proinsulin regulators the paper
#     called (sheet "Significant_Gene_list"): gene, number of significant
#     guides (binomial-test FDR < 0.01), average log2 fold change Hi vs Lo,
#     direction, and the absolute fold change used to rank them.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
dir.create(file.path(workdir, "lib"), showWarnings = FALSE)
options(timeout = 600)
fetch <- function(url, dest, min_size) {
  for (i in 1:5) {
    ok <- tryCatch(utils::download.file(url, dest, mode = "wb", quiet = TRUE) == 0,
                   error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > min_size) return(invisible(dest))
    Sys.sleep(10 * i)
  }
  stop("download failed: ", url)
}
xl <- file.path(workdir, "paper", "41467_2026_71726_MOESM3_ESM.xlsx")
if (!file.exists(xl)) {
  fetch(paste0("https://media.springernature.com/original/springer-static/esm/",
               "art%3A10.1038%2Fs41467-026-71726-z/MediaObjects/41467_2026_71726_MOESM3_ESM.xlsx"),
        xl, 1e6)
}
lib_zip <- file.path(workdir, "lib", "mouse_geckov2_library_combine.csv.zip")
if (!file.exists(lib_zip)) {
  fetch("https://sourceforge.net/projects/mageck/files/libraries/mouse_geckov2_library_combine.csv.zip/download",
        lib_zip, 1e6)
}
lib <- utils::read.csv(unz(lib_zip, "mouse_geckov2_library_combine.csv"), header = FALSE,
                       col.names = c("sgRNA", "sequence", "gene"), stringsAsFactors = FALSE)

raw <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "Raw_reads_number_analysis",
                                                         skip = 2, col_types = "text")))
raw <- raw[!is.na(raw[["sgRNA_ID"]]), ]
hi <- raw[["Proins_Hi"]]
lo <- raw[["Proins_Lo"]]
stopifnot(all(grepl("^([0-9]+|NA)$", hi)), all(grepl("^([0-9]+|NA)$", lo)))

# Check against the GEO file: "<row>""<sgRNA>""<gene>"<hi><lo>, gene NA unquoted
geo <- readLines(gzfile(file.path(workdir, "suppl", "GSE245845_Reads_number_total.txt.gz")))[-1]
parts <- regmatches(geo, regexec('^"[0-9]+""([^"]+)"(?:"[^"]*"|NA)([0-9NA]+)$', geo))
stopifnot(all(lengths(parts) == 3L))
geo_guide <- vapply(parts, `[`, "", 2)
geo_counts <- vapply(parts, `[`, "", 3)
stopifnot(length(geo) == nrow(raw), identical(geo_guide, raw[["sgRNA_ID"]]))
same <- geo_counts == paste0(hi, lo)
message(sprintf("GEO check: %d of %d rows give the same concatenated counts", sum(same), length(same)))
stopifnot(all(same))

gene <- lib$gene[match(raw[["sgRNA_ID"]], lib$sgRNA)]
stopifnot(!anyNA(gene))
named <- !is.na(raw[["Gene_ID"]]) & raw[["Gene_ID"]] != "NA" & !grepl("^[0-9]+$", raw[["Gene_ID"]])
stopifnot(all(raw[["Gene_ID"]][named] == gene[named]))
to_count <- function(x) as.integer(replace(x, x == "NA", "0"))
counts <- data.frame(sgRNA = raw[["sgRNA_ID"]], Gene = gene,
                     Proins_Hi = to_count(hi), Proins_Lo = to_count(lo), stringsAsFactors = FALSE)
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(counts, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

sig <- as.data.frame(suppressMessages(readxl::read_excel(xl, sheet = "Significant_Gene_list", skip = 2)))
sig <- data.frame(gene = sig[["Gene"]], sig_guides = sig[["Total.Sig.sgRNA (FDR<0.01)"]],
                  log2fc_hi_vs_lo = signif(as.numeric(sig[["AveLog2FC.HitoLo"]]), 6),
                  direction = sig[["Directions"]], stringsAsFactors = FALSE)
sig <- sig[!is.na(sig$gene), ]
sig$abs_log2fc <- abs(sig$log2fc_hi_vs_lo)
utils::write.table(sig, file.path(workdir, "paper", "significant_genes.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
