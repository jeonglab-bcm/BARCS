#!/usr/bin/env Rscript
# GSE236244: builds merged_counts.txt.gz and paper/tableS1.xlsx.
# Counts: the deposited MAGeCK count workbook GSE236244_mageck_raw_counts.xlsx
# has one sheet per sorted population (NPC, Non-pluripotent, Early pluripotent,
# Late pluripotent), each with sgRNA, Gene and one "count" column over the same
# 90,023 guides. The four count columns are put side by side (guide order of
# the NPC sheet) as NPC, nonplur, earlyplur, lateplur.
# Published table: Table S1 of the paper (MAGeCK RRA gene results, one sheet
# per comparison; Sci Adv 2024, doi:10.1126/sciadv.adj8862, PMC11305397),
# sciadv.adj8862_table_s1.xlsx inside sciadv.adj8862_tables_s1_to_s6.zip,
# taken from the Europe PMC supplementary bundle (51 MB; the publisher site
# refuses scripted downloads) and copied unchanged.
# Usage: Rscript prepare.R <workdir>

workdir <- commandArgs(trailingOnly = TRUE)[[1]]
book <- file.path(workdir, "suppl", "GSE236244_mageck_raw_counts.xlsx")
sheets <- c(NPC = "NPC", nonplur = "Non-pluripotent", earlyplur = "Early pluripotent",
            lateplur = "Late pluripotent")
tables <- lapply(sheets, function(s) as.data.frame(readxl::read_excel(book, sheet = s)))
counts <- tables$NPC[c("sgRNA", "Gene")]
for (name in names(sheets)) {
  x <- tables[[name]]
  stopifnot(nrow(x) == nrow(counts), setequal(x$sgRNA, counts$sgRNA), !anyDuplicated(x$sgRNA))
  counts[[name]] <- as.integer(x$count[match(counts$sgRNA, x$sgRNA)])
}
stopifnot(!anyNA(counts))
out <- gzfile(file.path(workdir, "merged_counts.txt.gz"), "w")
utils::write.table(counts, out, sep = "\t", quote = FALSE, row.names = FALSE)
close(out)

paper <- file.path(workdir, "paper")
dir.create(paper, showWarnings = FALSE)
bundle <- file.path(paper, "PMC11305397_supplementary.zip")
options(timeout = max(3600, getOption("timeout")))
url <- "https://www.ebi.ac.uk/europepmc/webservices/rest/PMC11305397/supplementaryFiles"
for (attempt in 1:3) {  # the Europe PMC service sometimes drops the connection
  ok <- tryCatch(utils::download.file(url, bundle, mode = "wb", quiet = TRUE) == 0,
                 error = function(e) FALSE)
  if (ok) break
  Sys.sleep(30 * attempt)
}
stopifnot(ok)
utils::unzip(bundle, files = "sciadv.adj8862_tables_s1_to_s6.zip", exdir = paper)
utils::unzip(file.path(paper, "sciadv.adj8862_tables_s1_to_s6.zip"),
             files = "sciadv.adj8862_table_s1.xlsx", exdir = paper)
stopifnot(file.rename(file.path(paper, "sciadv.adj8862_table_s1.xlsx"), file.path(paper, "tableS1.xlsx")))
unlink(c(bundle, file.path(paper, "sciadv.adj8862_tables_s1_to_s6.zip")))
