# Builds CRISPRi_counts.tsv and CRISPRa_counts.tsv from the eight per-sample
# files (sample_suppl/, from fetch_geo.R --sample-files; two columns, guide and
# value, listing the whole v2 library).
#
# Guide names lose stray double quotes; gene = guide name before the first "_"
# (APOBEC3A_B kept whole, non-targeting_* -> "non-targeting"). The CRISPRa
# values are integers. The CRISPRi values were deposited scaled: in each sample
# every nonzero value is an integer multiple of the sample's smallest nonzero
# value (1.07-1.26), so raw counts are recovered as
# round(value / smallest nonzero value). A sample whose smallest nonzero value
# is already an integer is left unscaled.
#
#   Rscript reanalyses/GSE276161/prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
screens <- list(
  CRISPRi = c(GSM8492236 = "Vehicle_Rep1", GSM8492238 = "Vehicle_Rep2",
              GSM8492235 = "Doxo_Rep1", GSM8492237 = "Doxo_Rep2"),
  CRISPRa = c(GSM8492239 = "Vehicle_Rep1", GSM8492240 = "Vehicle_Rep2",
              GSM8492241 = "Doxo_Rep1", GSM8492242 = "Doxo_Rep2"))

read_sample <- function(gsm) {
  file <- list.files(file.path(workdir, "sample_suppl"), pattern = paste0("^", gsm, "_"), full.names = TRUE)
  con <- gzfile(file)
  fields <- strsplit(readLines(con, warn = FALSE), "\t", fixed = TRUE)
  close(con)
  value <- as.numeric(vapply(fields, `[`, "", 2))
  names(value) <- gsub('"', "", vapply(fields, `[`, "", 1), fixed = TRUE)
  smallest <- min(value[value > 0])
  scale <- if (abs(smallest - round(smallest)) > 1e-6) smallest else 1
  counts <- round(value / scale)
  stopifnot(!anyDuplicated(names(value)), all(abs(value / scale - counts) < 0.01))
  message(gsm, ": scale ", scale, ", total ", sum(counts))
  counts
}

for (screen in names(screens)) {
  values <- lapply(names(screens[[screen]]), read_sample)
  guides <- names(values[[1]])
  gene <- sub("_.*$", "", guides)
  gene[startsWith(guides, "non-targeting")] <- "non-targeting"
  gene[startsWith(guides, "APOBEC3A_B")] <- "APOBEC3A_B"
  counts <- data.frame(sgRNA = guides, Gene = gene)
  for (i in seq_along(values)) {
    stopifnot(setequal(names(values[[i]]), guides))
    counts[[paste0(screen, "_", screens[[screen]][[i]])]] <- as.integer(values[[i]][guides])
  }
  utils::write.table(counts, file.path(workdir, paste0(screen, "_counts.tsv")),
                     sep = "\t", quote = FALSE, row.names = FALSE)
}
