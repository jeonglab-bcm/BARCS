#!/usr/bin/env Rscript
# GSE245526: builds recovered_counts.tsv (and recovered_counts_scales.json), the raw
# read counts behind the deposited normalized table GSE245526_Counts_NL4.3_in_CEMM7_N_1-3.xlsx.
# The xlsx (sheet 1, all 26 libraries) holds MAGeCK median-normalized counts
# written unrounded. The smallest value is often a large multiple of the read
# scale (k up to 221), so k is searched up to 1500 (RECOVER_KMAX=1500). The two
# columns named "Input n=1" become "Input n=1...3" and "Input n=1...8" (readxl).
# Recovery is done by tools/screen-reanalysis/recover_counts.R (one scale per
# column, accepted only when >= 99.5% of values become integers); the run stops
# unless every column's recovered total matches the record's recovery_scales.json.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
record <- dirname(normalizePath(sub("^--file=", "", file_arg)))
tool <- file.path(dirname(dirname(record)), "tools", "screen-reanalysis", "recover_counts.R")
out <- file.path(workdir, "recovered_counts.tsv")

status <- system2(file.path(R.home("bin"), "Rscript"),
                  c(tool, shQuote(file.path(workdir, "suppl", "GSE245526_Counts_NL4.3_in_CEMM7_N_1-3.xlsx")), shQuote(out),
                    shQuote("sgRNA,Gene"), "ALL"),
                  env = c("RECOVER_KMAX=1500", "RECOVER_OFFSET=0"))
stopifnot(status == 0, file.exists(out))

new <- jsonlite::fromJSON(file.path(workdir, "recovered_counts_scales.json"))
old <- jsonlite::fromJSON(file.path(record, "recovery_scales.json"))
stopifnot(identical(new$column, old$column), identical(new$k, old$k),
          identical(new$recovered_total, old$recovered_total))
