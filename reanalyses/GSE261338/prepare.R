#!/usr/bin/env Rscript
# GSE261338: builds counts.tsv.gz from the GEO file
# GSE261338_MDSL-Cas9-Dropout-sgRNA-counts.xls.gz (a gzipped binary .xls).
# The counts are on sheet 'AZA_DROPOUT.count' (Sheet1 is empty). The deposited
# workbook stops at the old Excel row limit (65,535 guides of the 77,441-guide
# Brunello library); the rows present are written out unchanged, sorted by guide.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
gz <- file.path(workdir, "suppl", "GSE261338_MDSL-Cas9-Dropout-sgRNA-counts.xls.gz")
xls <- tempfile(fileext = ".xls")
inp <- gzfile(gz, "rb")
raw <- readBin(inp, "raw", n = 200e6)
close(inp)
writeBin(raw, xls)
x <- as.data.frame(readxl::read_excel(xls, sheet = "AZA_DROPOUT.count"))
unlink(xls)
x <- x[order(x$sgRNA, method = "radix"), ]
con <- gzfile(file.path(workdir, "counts.tsv.gz"), "w")
utils::write.table(x, con, sep = "\t", quote = FALSE, row.names = FALSE)
close(con)

# The paper's gene-level results: Supplementary Data 2 of Truong et al. 2024
# Nat Commun (doi 10.1038/s41467-024-51646-6), MAGeCK MLE beta scores
# (cell-cycle normalized with MAGeCKFlute) for DMSO and AZA. Written to
# paper/beta_scores.tsv with columns gene, beta_dmso, beta_aza, diff
# (AZA minus DMSO; negative = depleted under AZA) and group (MAGeCKFlute
# nine-square group: bottomcenter = AZA-specific depletion, topcenter =
# AZA-specific enrichment).
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
url <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-024-51646-6/MediaObjects/41467_2024_51646_MOESM5_ESM.xlsx"
xl <- file.path(workdir, "paper", "41467_2024_51646_MOESM5_ESM.xlsx")
if (!file.exists(xl)) utils::download.file(url, xl, mode = "wb", quiet = TRUE)
b <- as.data.frame(suppressMessages(readxl::read_excel(xl, skip = 2)))
out <- data.frame(gene = b$Gene, beta_dmso = signif(b[["DMSO Beta Score"]], 6),
                  beta_aza = signif(b[["AZA Beta Score"]], 6),
                  diff = signif(b[["AZA Beta Score"]] - b[["DMSO Beta Score"]], 6),
                  group = b$group, stringsAsFactors = FALSE)
out <- out[order(out$diff, out$gene, method = "radix"), ]
utils::write.table(out, file.path(workdir, "paper", "beta_scores.tsv"), sep = "\t",
                   quote = FALSE, row.names = FALSE)
