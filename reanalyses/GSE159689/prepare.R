#!/usr/bin/env Rscript
# GSE159689 (Romine et al. 2021 Blood Cancer Discov, PMID 34568834): builds
# counts.tsv from the GEO count matrix. Each day-14 library was sequenced twice
# (columns <name> and <name>_addtl, one GSM each); the two reads of a library
# agree closely (Spearman 0.97-0.98, near-Poisson spread, constant ratio), so
# they are summed into one library. Columns are renamed to short sample names.
# Usage: Rscript prepare.R <workdir>   (after fetch_geo.R GSE159689)
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
f <- file.path(workdir, "suppl", "GSE159689_beti_crispr_counts_for_geo.txt.gz")
x <- utils::read.delim(f, check.names = FALSE, stringsAsFactors = FALSE)
libs <- c(Par_DMSO_1 = "LIB190430JT_S9_OCI-AMl2_DMSO_D14_S38",
          Par_DMSO_2 = "LIB190430JT_S9_OCI-AMl2_DMSO_D14dup_S39",
          Par_JQ1_1 = "LIB190430JT_S9_OCI-AMl2_JQ1_D14_S36",
          Par_JQ1_2 = "LIB190430JT_S9_OCI-AMl2_JQ1_D14dup_S37",
          Res_JQ1_1 = "LIB190430JT_S9_AML2_JQ1R_QJ1_d14_S8",
          Res_JQ1_2 = "LIB190430JT_S9_AML2_JQ1R_QJ1_d14dup1_S9",
          Res_DMSO_1 = "LIB190430JT_S9_AML2_JQ1R_dmso_d14_S6",
          Res_DMSO_2 = "LIB190430JT_S9_AML2_JQ1R_dmso_d14dup1_S7",
          Res_DMSO_3 = "LIB190430JT_S9_AML2_JQ1R_dmso_d14dup3_S10")
single <- c(Par_d21_DMSO_1 = "LIB191213BD_S11_aml2_d21_DMSO_1_L008",
            Par_d21_DMSO_2 = "LIB191213BD_S11_aml2_d21_DMSO_2_L008",
            Par_d21_CPI_1 = "LIB191213BD_S11_aml2_d21_cpi_1_L007",
            Par_d21_CPI_2 = "LIB191213BD_S11_aml2_d21_cpi_2_L007")
out <- data.frame(sgRNA = x$sgRNA, gene = x$Gene)
for (s in names(libs)) out[[s]] <- as.integer(x[[libs[[s]]]] + x[[paste0(libs[[s]], "_addtl")]])
for (s in names(single)) out[[s]] <- as.integer(x[[single[[s]]]])
stopifnot(!anyDuplicated(out$sgRNA))
utils::write.table(out, file.path(workdir, "counts.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
