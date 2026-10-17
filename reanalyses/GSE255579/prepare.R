# Downloads the paper's Supplementary Data 4 (MAGeCK test results of the
# EXO1-FANCG and EXO1-ZRSR2 rescue screens; publisher file MOESM7_ESM.xlsx of
# Nat Commun 2025, doi:10.1038/s41467-025-63349-7, PMC12475092) to
# paper/SD_M7.xlsx, where compare.json reads it. The file is used unchanged;
# the count file is the GEO file as deposited.
#
#   Rscript reanalyses/GSE255579/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
url <- paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-025-63349-7/",
              "MediaObjects/41467_2025_63349_MOESM7_ESM.xlsx")
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
options(timeout = max(600, getOption("timeout")))
tryCatch(utils::download.file(url, file.path(workdir, "paper", "SD_M7.xlsx"), mode = "wb", quiet = TRUE),
         error = function(e) stop("could not download Supplementary Data 4 (", url, "): ",
                                  conditionMessage(e), call. = FALSE))

# Supplementary Data 5 (MOESM8): the EXO1-ZRSR2 screen table for compare_zrsr2.json.
url8 <- paste0("https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-025-63349-7/",
               "MediaObjects/41467_2025_63349_MOESM8_ESM.xlsx")
tryCatch(utils::download.file(url8, file.path(workdir, "paper", "SD_M8.xlsx"), mode = "wb", quiet = TRUE),
         error = function(e) stop("could not download MOESM8 (", url8, "): ",
                                  conditionMessage(e), call. = FALSE))
