#!/usr/bin/env Rscript
# GSE238225: builds recovered_counts.tsv (and recovered_counts_scales.json), the raw
# read counts behind the deposited normalized table GSE238225_Normalized_Counts_CRISPRgate.tabular.txt.gz.
# The CRISPRgate table holds raw reads times one constant per sample,
# unrounded (k = 1 or 2 for the clones, 2 or 4 for the plasmid-pool columns).
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
                  c(tool, shQuote(file.path(workdir, "suppl", "GSE238225_Normalized_Counts_CRISPRgate.tabular.txt.gz")), shQuote(out),
                    shQuote("sgRNA,Gene"), "ALL"),
                  env = c("RECOVER_KMAX=10", "RECOVER_OFFSET=0"))
stopifnot(status == 0, file.exists(out))

new <- jsonlite::fromJSON(file.path(workdir, "recovered_counts_scales.json"))
old <- jsonlite::fromJSON(file.path(record, "recovery_scales.json"))
stopifnot(identical(new$column, old$column), identical(new$k, old$k),
          identical(new$recovered_total, old$recovered_total))
