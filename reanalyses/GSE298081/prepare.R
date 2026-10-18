#!/usr/bin/env Rscript
# GSE298081 / GSE298082 (Billmann, Costanzo et al., Cell 2026, PMID 42049019):
# HAP1 genome-wide TKOv3 genetic-interaction screens, rich (GSE298081) and
# minimal (GSE298082) medium. Builds two inputs inside <workdir>:
#
# 1. counts.tsv: the PTAR1 query screens and the parental wild-type (WT)
#    reference screens of one medium, with a Gene column. The deposited
#    matrices (GSE298081_gin_read_counts_matrix_rich.txt.gz and
#    GSE298082_gin_read_counts_matrix_min.txt.gz) have one guide per row
#    (REAGENT_ID = <gene>_<20-nt spacer>) and one raw-count column per library,
#    named by the sequencing library (Moffat_<n>, or Moffat_<a>_<b> for a T0
#    sequenced in two runs). Which library is the T0 and which are endpoints
#    A/B/C of each screen (GIN id) is taken from the paper's Data S1; the
#    endpoint libraries of a screen are summed into one column <GIN>_end. Two T0s
#    were shared between a rich- and a minimal-medium screen of the same
#    infection and were deposited only in the minimal matrix (Moffat_343_814
#    for WT GIN001; Moffat_619 for PTAR1 GIN043/GIN044), so for the rich series
#    the minimal matrix is downloaded too and those columns are added. Blank
#    cells (the matrices contain no zeros; the smallest value is 1) are guides
#    with no reads in that library and are written as 0.
# 2. paper/PTAR1_qGI.csv: the paper's PTAR1 genetic-interaction table (Data S7)
#    with the mean qGI of the replicate screens of this medium added
#    (rich: GIN003, GIN044; minimal: GIN043, GIN109), plus Data S1.
#
# Usage: Rscript prepare.R <workdir>   (workdir basename is the GSE)

workdir <- normalizePath(commandArgs(trailingOnly = TRUE)[[1]])
gse <- basename(workdir)
stopifnot(gse %in% c("GSE298081", "GSE298082"))
options(timeout = 600)

fetch <- function(url, dest, tries = 5) {
  for (i in seq_len(tries)) {
    ok <- tryCatch({
      utils::download.file(url, dest, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) FALSE, warning = function(w) FALSE)
    if (ok && file.exists(dest) && file.size(dest) > 0) return(invisible(dest))
    unlink(dest)
    Sys.sleep(10 * i)
  }
  stop("download failed: ", url)
}

## Paper supplement (Europe PMC bundle -> Cell supplementary zip -> mmc files)
paper <- file.path(workdir, "paper")
dir.create(paper, showWarnings = FALSE)
tmp <- file.path(workdir, "paper_tmp")
dir.create(tmp, showWarnings = FALSE)
bundle <- file.path(tmp, "europepmc_supp.zip")
if (!file.exists(file.path(paper, "DataS1_screens.xlsx")) ||
    !file.exists(file.path(paper, "DataS7_PTAR1.xlsx"))) {
  fetch("https://www.ebi.ac.uk/europepmc/webservices/rest/PMC13281610/supplementaryFiles", bundle)
  utils::unzip(bundle, files = "NIHMS2169707-supplement-Supp_Files.zip", exdir = tmp)
  inner <- file.path(tmp, "NIHMS2169707-supplement-Supp_Files.zip")
  utils::unzip(inner, files = c("1-s2.0-S0092867426003454-mmc2.xlsx",
                                "1-s2.0-S0092867426003454-mmc8.xlsx"), exdir = tmp)
  file.copy(file.path(tmp, "1-s2.0-S0092867426003454-mmc2.xlsx"),
            file.path(paper, "DataS1_screens.xlsx"), overwrite = TRUE)
  file.copy(file.path(tmp, "1-s2.0-S0092867426003454-mmc8.xlsx"),
            file.path(paper, "DataS7_PTAR1.xlsx"), overwrite = TRUE)
}
unlink(tmp, recursive = TRUE)

## Screens used
medium <- if (gse == "GSE298081") "rich" else "min"
gins <- if (medium == "rich") {
  list(PTAR1 = c("GIN003", "GIN044", "GIN288", "GIN298"),
       WT = c("GIN001", "GIN120", "GIN188", "GIN202", "GIN209", "GIN211", "GIN229",
              "GIN238", "GIN250", "GIN285", "GIN300", "GIN303", "GIN313", "GIN333",
              "GIN358", "GIN373"))
} else {
  list(PTAR1 = c("GIN043", "GIN053", "GIN109"),
       WT = c("GIN001", "GIN007", "GIN015", "GIN022", "GIN042", "GIN049",
              "GIN052", "GIN057", "GIN060", "GIN068", "GIN074", "GIN080", "GIN089",
              "GIN099", "GIN107", "GIN181"))
}
s1 <- as.data.frame(readxl::read_excel(file.path(paper, "DataS1_screens.xlsx"), sheet = 1))
names(s1) <- make.names(names(s1))
s1 <- s1[s1$Media.type == medium & s1$GIN_ID %in% unlist(gins), , drop = FALSE]
stopifnot(nrow(s1) == length(unlist(gins)), all(s1$Pass.QC == 1))
stopifnot(all(s1$Query.Gene[s1$GIN_ID %in% gins$PTAR1] == "PTAR1"),
          all(s1$Query.Gene[s1$GIN_ID %in% gins$WT] == "WT"))
t0col <- function(id) sub("\\+Moffat_", "_", id)
rows <- list()
for (i in seq_len(nrow(s1))) {
  r <- s1[i, ]
  query <- if (r$GIN_ID %in% gins$PTAR1) "PTAR1" else "WT"
  rows[[length(rows) + 1]] <- data.frame(column = t0col(r$T0.Sample.ID), screen = r$GIN_ID,
                                         query = query, phase = "T0", stringsAsFactors = FALSE)
  for (e in c("A", "B", "C")) {
    id <- r[[paste0("Endpoint", e, ".Sample.ID")]]
    if (is.na(id) || !nzchar(id)) next
    rows[[length(rows) + 1]] <- data.frame(column = id, screen = r$GIN_ID, query = query,
                                           phase = paste0("end", e), stringsAsFactors = FALSE)
  }
}
map <- do.call(rbind, rows)
map <- map[order(map$query != "PTAR1", map$screen, map$phase, method = "radix"), ]

## Counts
read_matrix <- function(path) {
  utils::read.delim(path, check.names = FALSE, stringsAsFactors = FALSE)
}
own <- read_matrix(file.path(workdir, "suppl", sprintf("%s_gin_read_counts_matrix_%s.txt.gz",
                                                        gse, medium)))
missing <- setdiff(map$column, names(own))
if (length(missing)) {
  stopifnot(medium == "rich", setequal(missing, c("Moffat_343_814", "Moffat_619")))
  other <- file.path(workdir, "GSE298082_gin_read_counts_matrix_min.txt.gz")
  if (!file.exists(other)) {
    fetch(paste0("https://ftp.ncbi.nlm.nih.gov/geo/series/GSE298nnn/GSE298082/suppl/",
                 "GSE298082_gin_read_counts_matrix_min.txt.gz"), other)
  }
  mtab <- read_matrix(other)
  stopifnot(identical(mtab$REAGENT_ID, own$REAGENT_ID))
  for (m in missing) own[[m]] <- mtab[[m]]
}
stopifnot(!anyDuplicated(own$REAGENT_ID), all(grepl("^.+_[ACGT]+$", own$REAGENT_ID)))
out <- data.frame(sgRNA = own$REAGENT_ID, Gene = sub("_[ACGT]+$", "", own$REAGENT_ID),
                  stringsAsFactors = FALSE)
lib <- function(m) {
  v <- own[[m]]
  stopifnot(!is.null(v))
  v[is.na(v)] <- 0  # blank cells are guides with no reads (the matrices hold no 0s)
  stopifnot(all(v == round(v)))
  v
}
# One T0 column per screen, and the endpoint libraries (A/B/C: parallel
# passages of the same infection) summed into one column per screen, so that
# the unit of replication in the model is the screen (infection).
screens <- unique(map$screen)
smap <- data.frame(column = character(), screen = character(), query = character(),
                   phase = character(), libraries = character(), stringsAsFactors = FALSE)
for (s in screens) {
  t0 <- map$column[map$screen == s & map$phase == "T0"]
  ends <- map$column[map$screen == s & map$phase != "T0"]
  stopifnot(length(t0) == 1, length(ends) >= 2)
  q <- unique(map$query[map$screen == s])
  out[[t0]] <- as.integer(lib(t0))
  end <- paste0(s, "_end")
  out[[end]] <- as.integer(Reduce(`+`, lapply(ends, lib)))
  smap <- rbind(smap, data.frame(column = c(t0, end), screen = s, query = q,
                                 phase = c("T0", "end"),
                                 libraries = c(t0, paste(ends, collapse = "+")),
                                 stringsAsFactors = FALSE))
}
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE,
                   row.names = FALSE)
utils::write.table(smap, file.path(workdir, "sample_map.tsv"), sep = "\t", quote = FALSE,
                   row.names = FALSE)

## Paper table: PTAR1 qGI (Data S7), mean of this medium's per-screen qGI
s7 <- as.data.frame(readxl::read_excel(file.path(paper, "DataS7_PTAR1.xlsx"),
                                       sheet = "PTAR1_HAP1 GIs"), check.names = FALSE)
cols <- grep(paste0("^qGI_PTAR1_[0-9]+_", medium, "$"), names(s7), value = TRUE)
fcol <- sub("^qGI_", "FDR_", cols)
stopifnot(length(cols) == 2, all(fcol %in% names(s7)))
s7$qGI_medium_mean <- rowMeans(as.matrix(s7[, cols]))
s7$FDR_medium_min <- apply(as.matrix(s7[, fcol]), 1, min)
s7 <- s7[order(s7$Gene, method = "radix"), ]
utils::write.csv(s7, file.path(paper, "PTAR1_qGI.csv"), row.names = FALSE)
message(sprintf("%s: %d guides x %d columns; paper table %d genes (%s)", gse, nrow(out),
                ncol(out) - 2, nrow(s7), paste(cols, collapse = ", ")))
