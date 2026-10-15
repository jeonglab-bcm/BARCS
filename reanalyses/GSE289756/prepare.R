#!/usr/bin/env Rscript
# GSE289756: builds raw_counts.tsv and paper/fig1b_<line>.csv.
# Counts: GSE289756_RawsgRNACounts.xlsx, sheet NoMismatches_Counts (660 sgRNAs
# x 80 libraries, integer reads). The gene is the sgRNA name without its
# "-N" suffix (AP2M1-3 -> AP2M1); the 50 control sgRNAs (ControlA1..ControlJ5)
# keep their group letter (ControlA..ControlJ), and the 50 ribosomal-protein
# positive-control sgRNAs (sgRPL11_1 ..) are assigned to their gene (RPL11).
# Rows keep the deposited order.
# Published table: Source Data of the paper (Nat Commun 2025,
# doi:10.1038/s41467-025-57521-2, PMC11885535), sheet Figure1B: per cell
# line, the mean in vitro and in vivo gene z-scores, t-test p-value and FDR.
# Each line's block is written as paper/fig1b_<line>.csv, adding
# vivo_minus_vitro (VivoMean - VitroMean) and signed_log10p
# (sign(vivo_minus_vitro) * -log10(pvalue)) so the in vivo-enriched genes rank first.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
x <- as.data.frame(readxl::read_excel(file.path(workdir, "suppl", "GSE289756_RawsgRNACounts.xlsx"),
                                      sheet = "NoMismatches_Counts"))
stopifnot(nrow(x) == 660, ncol(x) == 81, !anyDuplicated(x$sgRNA))
gene <- ifelse(grepl("^Control", x$sgRNA), sub("[0-9]+$", "", x$sgRNA),
               ifelse(grepl("^sgRP", x$sgRNA), sub("^sg(.*)_[0-9]+$", "\\1", x$sgRNA),
                      sub("-[0-9]+$", "", x$sgRNA)))
stopifnot(!anyDuplicated(paste(gene, x$sgRNA)), all(table(gene[!grepl("^Control", gene)]) == 5))
counts <- data.frame(sgRNA = x$sgRNA, gene = gene, stringsAsFactors = FALSE)
for (column in names(x)[-1]) {
  v <- x[[column]]
  stopifnot(!anyNA(v), all(v == round(v)))
  counts[[gsub(" ", "_", column)]] <- as.integer(v)
}
utils::write.table(counts, file.path(workdir, "raw_counts.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)

paper <- file.path(workdir, "paper")
dir.create(paper, showWarnings = FALSE)
book <- file.path(paper, "source_data.xlsx")
url <- paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-025-57521-2/",
              "MediaObjects/41467_2025_57521_MOESM11_ESM.xlsx")
options(timeout = max(600, getOption("timeout")))
stopifnot(utils::download.file(url, book, mode = "wb", quiet = TRUE) == 0)
fig <- as.data.frame(suppressMessages(readxl::read_excel(book, sheet = "Figure1B", col_names = FALSE,
                                        col_types = "text")))
lines <- c(BXPC3 = 2, CFPAC1 = 7, HPAFII = 12, MIAPACA2 = 17, PANC1 = 22)
stopifnot(identical(unname(unlist(fig[1, lines])), c("BXPC-3", "CFPAC-1", "HPAF-II", "MIAPACA-2", "PANC-1")))
rows <- 3:nrow(fig)
rows <- rows[!is.na(fig[rows, 1])]
for (line in names(lines)) {
  j <- lines[[line]]
  stopifnot(identical(unname(unlist(fig[2, j:(j + 3)])), c("VitroMean", "VivoMean", "pvalue", "FDR")))
  tab <- data.frame(gene = fig[rows, 1],
                    VitroMean = as.numeric(fig[rows, j]), VivoMean = as.numeric(fig[rows, j + 1]),
                    pvalue = as.numeric(fig[rows, j + 2]), FDR = as.numeric(fig[rows, j + 3]),
                    stringsAsFactors = FALSE)
  tab$vivo_minus_vitro <- tab$VivoMean - tab$VitroMean
  tab$signed_log10p <- sign(tab$vivo_minus_vitro) * -log10(tab$pvalue)
  tab <- tab[order(tab$gene, method = "radix"), ]
  utils::write.csv(tab, file.path(paper, sprintf("fig1b_%s.csv", line)), row.names = FALSE)
}
unlink(book)
