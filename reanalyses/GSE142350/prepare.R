#!/usr/bin/env Rscript
# GSE142350: builds recovered_<screen>.tsv for the four screens (SRE-Elk,
# Nanog, Esrrb, pMek): the raw read counts behind the deposited normalized
# tables GSE142350_<screen>_Screen_counts.txt.gz (MAGeCK-style, one scale per
# library, unrounded). Recovery is done by tools/screen-reanalysis/recover_counts.R
# (one scale per column, accepted only when >= 99.5% of values become
# integers; RECOVER_KMAX=60 because some libraries' smallest value is 26 reads);
# the run stops unless every column's k and recovered total match the record's
# recovery_scales.json.
# Also writes paper/screen_results.tsv, the authors' MAGeCK results for all four
# screens (Additional file 3 of Genome Biol 22:110 (2021),
# doi:10.1186/s13059-021-02321-2), with its two-row header collapsed to one
# and Erk2/Mek1 renamed Mapk1/Map2k1 as in the sgRNA libraries.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
record <- dirname(normalizePath(sub("^--file=", "", file_arg)))
tool <- file.path(dirname(dirname(record)), "tools", "screen-reanalysis", "recover_counts.R")

scales <- list()
for (screen in c("SRE-Elk", "Nanog", "Esrrb", "pMek")) {
  out <- file.path(workdir, sprintf("recovered_%s.tsv", screen))
  status <- system2(file.path(R.home("bin"), "Rscript"),
                    c(tool, shQuote(file.path(workdir, "suppl", sprintf("GSE142350_%s_Screen_counts.txt.gz", screen))),
                      shQuote(out), shQuote("sgRNA,Gene"), "ALL"),
                    env = c("RECOVER_KMAX=60", "RECOVER_OFFSET=0"))
  stopifnot(status == 0, file.exists(out))
  scales <- c(scales, jsonlite::fromJSON(sub("\\.tsv$", "_scales.json", out), simplifyVector = FALSE))
}
recorded <- file.path(record, "recovery_scales.json")
if (file.exists(recorded)) {
  old <- jsonlite::fromJSON(recorded, simplifyVector = FALSE)
  pick <- function(x, f) vapply(x, function(e) as.character(e[[f]]), character(1))
  stopifnot(identical(pick(scales, "column"), pick(old, "column")),
            identical(pick(scales, "k"), pick(old, "k")),
            identical(pick(scales, "recovered_total"), pick(old, "recovered_total")))
}
jsonlite::write_json(scales, file.path(workdir, "recovered_counts_scales.json"),
                     auto_unbox = TRUE, pretty = TRUE, digits = NA)

url <- paste0("https://static-content.springer.com/esm/art%3A10.1186%2Fs13059-021-02321-2/",
              "MediaObjects/13059_2021_2321_MOESM3_ESM.xlsx")
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
xl <- file.path(workdir, "paper", "13059_2021_2321_MOESM3_ESM.xlsx")
options(timeout = 600)
ok <- FALSE
for (attempt in 1:5) {
  ok <- tryCatch(utils::download.file(url, xl, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE, warning = function(w) FALSE)
  if (ok && file.size(xl) > 10000) break
  Sys.sleep(10 * attempt)
}
if (!ok) stop("download failed: ", url)
tab <- as.data.frame(readxl::read_excel(xl, sheet = "CRISPR Screen results", skip = 1, na = "NA"))
names(tab) <- gsub("[^A-Za-z0-9_]+", "_", names(tab))
# The paper names two positive controls by protein (Erk2, Mek1); the libraries
# use the gene symbols Mapk1 and Map2k1.
tab$Gene[tab$Gene == "Erk2"] <- "Mapk1"
tab$Gene[tab$Gene == "Mek1"] <- "Map2k1"
tab <- tab[order(tab$Gene, method = "radix"), ]
utils::write.table(tab, file.path(workdir, "paper", "screen_results.tsv"),
                   sep = "\t", quote = FALSE, row.names = FALSE, na = "")
