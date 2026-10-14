#!/usr/bin/env Rscript
# GSE302546 (TRAPPC4 ferroptosis screen, Cancer Res 2026, PMID 41974002,
# PMC13370119): the count file is the GEO file as deposited
# (suppl/GSE302546_sgRNA_count_allinfo.txt.gz). This script builds only the
# paper's table: it downloads the supplementary workbook (Tables S1-S12) from
# the PMC Open Access bucket and writes Supplementary Table S8 (MAGeCK RRA
# negative-selection gene summary, RSL3 vs DMSO) to paper/TableS8.tsv without
# its title row.
#
#   Rscript work/GSE302546/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
paper <- file.path(workdir, "paper")
dir.create(paper, recursive = TRUE, showWarnings = FALSE)
options(timeout = max(600, getOption("timeout")))
url <- "https://pmc-oa-opendata.s3.amazonaws.com/PMC13370119.1/can-25-3654_table_s1-s12_suppst1-12.xlsx"
xlsx <- file.path(paper, "tables_s1-s12.xlsx")
tryCatch(utils::download.file(url, xlsx, mode = "wb", quiet = TRUE),
         error = function(e) stop("could not download the supplementary tables (", url, "): ",
                                  conditionMessage(e), call. = FALSE))
s8 <- as.data.frame(readxl::read_excel(xlsx, sheet = "Supplementary Table S8", skip = 1))
stopifnot(identical(names(s8)[1:3], c("id", "neg|score", "neg|p-value")))
utils::write.table(s8, file.path(paper, "TableS8.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
unlink(xlsx)
