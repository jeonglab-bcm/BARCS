#!/usr/bin/env Rscript
# GSE316985: builds ko_counts.tsv and crispri_counts.tsv (plus *_scales.json),
# the raw read counts behind the deposited MAGeCK-normalized guide tables
# GSE316985_CRISPRknockout_normcounts.txt.gz and GSE316985_CRISPRinhibition_normcounts.txt.gz.
# Each column is raw reads times one unrounded constant, with scales up to
# ~1/100 of a read, so the search runs to k = 400 (RECOVER_KMAX=400).
# Recovery is done by tools/screen-reanalysis/recover_counts.R (one scale per
# column, accepted only when >= 99.5% of values become integers; here every
# column is 100% integral). When the record's recovery_scales_<screen>.json is
# present, the run stops unless every column's k and recovered total match it.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
record <- dirname(normalizePath(sub("^--file=", "", file_arg)))
tool <- file.path(dirname(dirname(record)), "tools", "screen-reanalysis", "recover_counts.R")
if (!file.exists(tool)) tool <- file.path("tools", "screen-reanalysis", "recover_counts.R")

screens <- c(ko = "GSE316985_CRISPRknockout_normcounts.txt.gz",
             crispri = "GSE316985_CRISPRinhibition_normcounts.txt.gz")
for (s in names(screens)) {
  out <- file.path(workdir, paste0(s, "_counts.tsv"))
  status <- system2(file.path(R.home("bin"), "Rscript"),
                    c(tool, shQuote(file.path(workdir, "suppl", screens[[s]])), shQuote(out),
                      shQuote("sgRNA,Gene"), "ALL"),
                    env = c("RECOVER_KMAX=400", "RECOVER_OFFSET=0"), stdout = FALSE)
  stopifnot(status == 0, file.exists(out))
  ref <- file.path(record, paste0("recovery_scales_", s, ".json"))
  if (file.exists(ref)) {
    new <- jsonlite::fromJSON(file.path(workdir, paste0(s, "_counts_scales.json")))
    old <- jsonlite::fromJSON(ref)
    stopifnot(identical(new$column, old$column), identical(new$k, old$k),
              identical(new$recovered_total, old$recovered_total))
  }
}
