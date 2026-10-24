#!/usr/bin/env Rscript
# GSE177541 (Grodzki et al. 2022 Genome Med, PMID 35086559): builds the authors'
# MAGeCK gene summaries for the Vero E6 screens from Additional files 4 (SARS-CoV-2)
# and 5 (OC43). The count file BARCS reads is the GEO supplementary file as
# deposited (no change). In the paper's tables a few genes carry
# "<Ensembl id>/<symbol>" names; the GEO count file uses the Ensembl id alone, so
# the part before "/" becomes `gene` and the full name is kept as `paper_id`.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
base <- "https://static-content.springer.com/esm/art%3A10.1186%2Fs13073-022-01013-1/MediaObjects/"
convert <- function(file, sheet, out) {
  xl <- file.path(workdir, "paper", file)
  if (!file.exists(xl)) utils::download.file(paste0(base, file), xl, mode = "wb", quiet = TRUE)
  d <- as.data.frame(suppressWarnings(suppressMessages(readxl::read_excel(xl, sheet = sheet, col_names = FALSE))))
  head_row <- which(d[[1]] == "id")[1]
  names(d) <- as.character(unlist(d[head_row, ]))
  d <- d[-seq_len(head_row), ]
  num <- function(v) suppressWarnings(as.numeric(v))
  g <- data.frame(gene = sub("/.*$", "", d$id), paper_id = d$id, n_guides = num(d$num),
                  pos_score = num(d[["pos|score"]]), pos_p = num(d[["pos|p-value"]]),
                  pos_fdr = num(d[["pos|fdr"]]), pos_rank = num(d[["pos|rank"]]),
                  lfc = num(d[["pos|lfc"]]))
  g <- g[g$gene != "Non-Targeting", ]
  g <- g[order(g$pos_rank), ]
  utils::write.table(g, file.path(workdir, "paper", out), sep = "\t", quote = FALSE, row.names = FALSE)
}
convert("13073_2022_1013_MOESM4_ESM.xlsx", "2.Vero Grodzki Mageck ", "vero_sars_mageck.tsv")
convert("13073_2022_1013_MOESM5_ESM.xlsx", "2.VERO MAGECK oc43_1st", "vero_oc43_mageck.tsv")
