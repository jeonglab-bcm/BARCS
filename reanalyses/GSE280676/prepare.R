# Builds counts_utf8.tsv.gz and the paper's day-16 MAGeCK table.
#
# Counts: suppl/GSE280676_ShortTermScreen_raw_counts.txt.gz is UTF-16 (with a
# byte-order mark and CRLF line ends), which read.delim cannot read. It is
# re-encoded as UTF-8 with LF line ends; nothing else changes.
#
# Published table: paper/mageck_day16.csv is the day-16 rows of sheet
# "MaGeCK Results" in Supplementary Data 1 (42003_2025_8760_MOESM2_ESM.xlsx,
# Communications Biology), with "-LOG10(P-value)" and "-LOG10(FDR)" renamed
# neglog10p and neglog10fdr.
#
#   Rscript reanalyses/GSE280676/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]

con <- gzfile(file.path(workdir, "suppl", "GSE280676_ShortTermScreen_raw_counts.txt.gz"),
              encoding = "UTF-16")
lines <- sub("\r$", "", sub("^﻿", "", readLines(con, warn = FALSE)))
close(con)
out <- gzfile(file.path(workdir, "counts_utf8.tsv.gz"), "w")
writeLines(enc2utf8(lines), out, useBytes = TRUE)
close(out)

xlsx <- file.path(tempdir(), "42003_2025_8760_MOESM2_ESM.xlsx")
utils::download.file(paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs42003-025-08760-y/",
                            "MediaObjects/42003_2025_8760_MOESM2_ESM.xlsx"),
                     xlsx, mode = "wb", quiet = TRUE)
mageck <- as.data.frame(readxl::read_excel(xlsx, sheet = "MaGeCK Results"))
names(mageck)[names(mageck) == "-LOG10(P-value)"] <- "neglog10p"
names(mageck)[names(mageck) == "-LOG10(FDR)"] <- "neglog10fdr"
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
utils::write.table(mageck[mageck$day == 16, ], file.path(workdir, "paper", "mageck_day16.csv"),
                   sep = ",", quote = FALSE, row.names = FALSE)
