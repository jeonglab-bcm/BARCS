#!/usr/bin/env Rscript
# GSE246804 (Weiss et al. 2023, Cancer Res, PMID 37934115): the screen was
# deposited as a long-format table of pairwise drug-vs-DMSO comparisons
# (suppl/GSE246804_sgRNAData.txt.gz), not as a per-library count matrix. Each
# row is one guide in one treatment sample and carries the raw integer read
# counts of that treatment library (SAMPLE_COUNT) and of its matched DMSO
# control library (CONTROL_SAMPLE_COUNT); the DMSO counts are identical across
# the three drug arms of the same cell line and EPIC pool. This rebuilds, for
# each cell line, one genome-wide count matrix by stacking the three EPIC
# sub-pools (each gene is in exactly one pool) with columns DMSO, KRASG12Ci
# (AGENT_NAME FVH342 = JDQ443-class), SHP2i (LMD099 = SHP099/TNO155-class) and
# combo (FVH342_LMD099). Counts are the deposited integers, unchanged.
# Writes counts_<cell>.tsv.gz for the cell lines in `cells` below.
# Usage: Rscript prepare.R <workdir>
workdir <- commandArgs(trailingOnly = TRUE)[[1]]
src <- file.path(workdir, "suppl", "GSE246804_sgRNAData.txt.gz")
d <- read.delim(gzfile(src), check.names = FALSE, stringsAsFactors = FALSE,
                colClasses = "character")
d$cell <- sub("_.*", "", d$BIOSPECIMEN_NAME)
agent_col <- c(FVH342 = "KRASG12Ci", LMD099 = "SHP2i", "FVH342_LMD099" = "combo")
cells <- c("NCI-H23")
for (cl in cells) {
  s <- d[d$cell == cl, ]
  # Guide names repeat across the three EPIC pools, so key on guide + pool. The
  # output guide id carries the pool to stay unique in the stacked matrix.
  s$key <- paste(s$CRISPR_NAME, s$POOL_NAME, sep = "@")
  # DMSO: one value per guide-in-pool (identical across the three drug arms).
  dmso <- s[!duplicated(s$key), c("key", "CRISPR_NAME", "Gene", "POOL_NAME", "CONTROL_SAMPLE_COUNT")]
  names(dmso)[names(dmso) == "CONTROL_SAMPLE_COUNT"] <- "DMSO"
  out <- dmso
  for (ag in names(agent_col)) {
    a <- s[s$AGENT_NAME == ag, c("key", "SAMPLE_COUNT")]
    a <- a[!duplicated(a$key), ]
    names(a)[2] <- agent_col[[ag]]
    out <- merge(out, a, by = "key", all.x = TRUE)
  }
  out <- out[order(out$key, method = "radix"), ]
  for (col in c("DMSO", unname(agent_col))) out[[col]] <- as.integer(out[[col]])
  out$guide <- paste(out$CRISPR_NAME, out$POOL_NAME, sep = "@")
  out <- out[, c("guide", "Gene", "POOL_NAME", "DMSO", unname(agent_col))]
  f <- file.path(workdir, paste0("counts_", cl, ".tsv.gz"))
  con <- gzfile(f, "w"); utils::write.table(out, con, sep = "\t", quote = FALSE, row.names = FALSE); close(con)
  message("wrote ", f, ": ", nrow(out), " guides")
}

# Paper's own gene-level RSA scores (geneData.txt.gz) for the same cell line and
# the combination arm, stacked over the three pools, for the comparison. RSA
# sensitizer LogP (more negative = stronger sensitizer, depleted) and activator
# LogP (more negative = stronger rescuer, enriched); XTreatment_Control_LogFC.med
# is the median guide log fold change (combo vs DMSO).
gd <- read.delim(gzfile(file.path(workdir, "suppl", "GSE246804_geneData.txt.gz")),
                 check.names = FALSE, stringsAsFactors = FALSE)
gd$cell <- sub("_.*", "", gd$BIOSPECIMEN_NAME)
for (cl in cells) {
  g <- gd[gd$cell == cl & gd$AGENT_NAME == "FVH342_LMD099",
          c("Gene", "LogP_Treatment_Control.RSAsensitizor",
            "LogP_Treatment_Control.RSAactivator", "XTreatment_Control_LogFC.med")]
  names(g) <- c("gene", "rsa_sensitizer_logp", "rsa_activator_logp", "logfc_med")
  for (j in 2:4) g[[j]] <- signif(as.numeric(g[[j]]), 6)
  g <- g[!duplicated(g$gene), ]
  g <- g[order(g$rsa_sensitizer_logp), ]
  f <- file.path(workdir, "paper", paste0("rsa_", cl, ".tsv"))
  dir.create(file.path(workdir, "paper"), showWarnings = FALSE)
  utils::write.table(g, f, sep = "\t", quote = FALSE, row.names = FALSE)
  message("wrote ", f, ": ", nrow(g), " genes")
}
