# Puts the authors' published result, the GEO MAGeCK-MLE table for Xist-high
# vs Xist-negative (suppl/GSE273070_TFi_mle_HighvsNeg.txt.gz), at
# paper/GSE273070_TFi_mle_HighvsNeg.txt.gz, where compare.json expects it. The
# file is copied unchanged; the count file is the GEO file as deposited.
#
#   Rscript reanalyses/GSE273070/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
stopifnot(file.copy(file.path(workdir, "suppl", "GSE273070_TFi_mle_HighvsNeg.txt.gz"),
                    file.path(workdir, "paper"), overwrite = TRUE))
