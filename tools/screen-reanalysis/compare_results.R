#!/usr/bin/env Rscript
# Compare BARCS gene results with what the original study reported.
#
#   Rscript tools/screen-reanalysis/compare_results.R <compare.json>
#
# compare.json (written by the agent, see SKILL.md):
#   barcs_genes      path to a BARCS genes.csv
#   direction        "depleted", "enriched", or "both": which BARCS hits to rank
#   named_hits       genes the paper highlights (abstract, figures, text)
#   published        optional table of the paper's own gene-level results:
#     file, sheet, gene_column, score_column,
#     score_better   "lower" (p-value, FDR, RRA score) or "higher" (|LFC|, rank score)
#     effect_column  optional signed effect, used for direction agreement
#   top_n            list of list sizes to compare (default [50, 100, 200])
#   out              output prefix (default <dir of compare.json>/comparison)
#
# Writes <out>.md (human-readable) and <out>_genes.csv (merged ranks).

suppressPackageStartupMessages(library(jsonlite))
`%||%` <- function(a, b) if (is.null(a)) b else a

args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: compare_results.R <compare.json>", call. = FALSE)
spec_path <- args[[1]]
spec <- fromJSON(spec_path, simplifyVector = TRUE)
here <- dirname(spec_path)
resolve <- function(p) if (file.exists(p)) p else file.path(here, p)
out <- spec$out %||% file.path(here, "comparison")
top_n <- spec$top_n %||% c(50, 100, 200)
direction <- spec$direction %||% "both"

barcs <- utils::read.csv(resolve(spec$barcs_genes), stringsAsFactors = FALSE)
barcs <- barcs[is.finite(barcs$p_value), , drop = FALSE]
signed <- sign(barcs$estimate) * -log10(pmax(barcs$p_value, 1e-300))
barcs$barcs_score <- switch(direction,
  depleted = -signed, enriched = signed, both = abs(signed))
barcs <- barcs[order(-barcs$barcs_score), , drop = FALSE]
barcs$barcs_rank <- seq_len(nrow(barcs))

lines <- c(sprintf("# BARCS versus published results\n\nBARCS genes: `%s` (%d genes, direction: %s)",
                   spec$barcs_genes, nrow(barcs), direction))

# ---- named hits ----------------------------------------------------------------
named <- unlist(spec$named_hits %||% character())
if (length(named)) {
  hit_rows <- barcs[match(toupper(named), toupper(barcs$gene)), , drop = FALSE]
  lines <- c(lines, "\n## Genes the paper highlights\n",
             "| Gene | BARCS rank | of | Effect | p | FDR |", "|---|---|---|---|---|---|")
  for (i in seq_along(named)) {
    r <- hit_rows[i, ]
    lines <- c(lines, if (is.na(r$gene)) sprintf("| %s | not tested | | | | |", named[i]) else
      sprintf("| %s | %d | %d | %.3f | %.2g | %.2g |", r$gene, r$barcs_rank, nrow(barcs),
              r$estimate, r$p_value, r$fdr))
  }
}

# ---- published table -------------------------------------------------------------
merged <- barcs
if (!is.null(spec$published) && length(spec$published)) {
  pub_spec <- spec$published
  pub_path <- resolve(pub_spec$file)
  published <- if (grepl("\\.xlsx?$", pub_path, ignore.case = TRUE)) {
    as.data.frame(readxl::read_excel(pub_path, sheet = pub_spec$sheet %||% 1L))
  } else {
    first <- readLines(if (grepl("\\.gz$", pub_path)) gzfile(pub_path) else pub_path, n = 1L)
    utils::read.delim(if (grepl("\\.gz$", pub_path)) gzfile(pub_path) else pub_path,
                      sep = if (grepl("\t", first)) "\t" else ",",
                      check.names = FALSE, stringsAsFactors = FALSE)
  }
  score <- suppressWarnings(as.numeric(published[[pub_spec$score_column]]))
  pub <- data.frame(gene = as.character(published[[pub_spec$gene_column]]),
                    published_score = if (identical(pub_spec$score_better, "lower")) -score else score)
  if (!is.null(pub_spec$effect_column)) {
    pub$published_effect <- suppressWarnings(as.numeric(published[[pub_spec$effect_column]]))
  }
  pub <- pub[is.finite(pub$published_score) & nzchar(pub$gene), , drop = FALSE]
  pub <- pub[!duplicated(toupper(pub$gene)), , drop = FALSE]
  pub <- pub[order(-pub$published_score), , drop = FALSE]
  pub$published_rank <- seq_len(nrow(pub))
  merged <- merge(barcs, pub, by.x = "gene", by.y = "gene", all = TRUE)
  shared <- merged[is.finite(merged$barcs_rank) & is.finite(merged$published_rank), ]

  rho <- suppressWarnings(stats::cor(shared$barcs_score, shared$published_score, method = "spearman"))
  lines <- c(lines, sprintf(
    "\n## Agreement with the published table\n\nPublished: `%s` (score `%s`, %s is stronger); %d genes, %d shared with BARCS.\n\nSpearman correlation of gene scores: **%.2f**",
    pub_spec$file, pub_spec$score_column, pub_spec$score_better %||% "higher",
    nrow(pub), nrow(shared), rho))
  if ("published_effect" %in% names(shared)) {
    both <- is.finite(shared$published_effect) & is.finite(shared$estimate)
    lines <- c(lines, sprintf("\n\nEffect direction agreement: %.1f%% of %d genes",
                              100 * mean(sign(shared$published_effect[both]) == sign(shared$estimate[both])),
                              sum(both)))
  }
  lines <- c(lines, "\n\n| Top N | Shared | Jaccard | BARCS only | Published only |",
             "|---|---|---|---|---|")
  for (n in top_n) {
    b <- shared$gene[shared$barcs_rank <= sort(shared$barcs_rank)[min(n, nrow(shared))]]
    p <- shared$gene[shared$published_rank <= sort(shared$published_rank)[min(n, nrow(shared))]]
    lines <- c(lines, sprintf("| %d | %d | %.2f | %d | %d |", n, length(intersect(b, p)),
                              length(intersect(b, p)) / length(union(b, p)),
                              length(setdiff(b, p)), length(setdiff(p, b))))
  }
  n <- top_n[1]
  b_top <- shared[order(shared$barcs_rank), ][seq_len(min(n, nrow(shared))), ]
  p_top <- shared[order(shared$published_rank), ][seq_len(min(n, nrow(shared))), ]
  barcs_only <- b_top[!b_top$gene %in% p_top$gene, ]
  pub_only <- p_top[!p_top$gene %in% b_top$gene, ]
  fmt <- function(d, own, other) if (!nrow(d)) "none" else
    paste(sprintf("%s (%d / %d)", d$gene, d[[own]], d[[other]]), collapse = ", ")
  lines <- c(lines,
    sprintf("\n### In the BARCS top %d but not the published top %d\n\nGene (BARCS rank / published rank): %s",
            n, n, fmt(utils::head(barcs_only, 25L), "barcs_rank", "published_rank")),
    sprintf("\n### In the published top %d but not the BARCS top %d\n\nGene (published rank / BARCS rank): %s",
            n, n, fmt(utils::head(pub_only, 25L), "published_rank", "barcs_rank")))
}

lines <- c(lines, sprintf(
  "\n## BARCS calls\n\nGenes at FDR 0.05: %d; at FDR 0.10: %d. Top 15: %s",
  sum(barcs$fdr < 0.05, na.rm = TRUE), sum(barcs$fdr < 0.10, na.rm = TRUE),
  paste(utils::head(barcs$gene, 15L), collapse = ", ")))

writeLines(lines, paste0(out, ".md"))
utils::write.csv(merged[order(merged$barcs_rank), ], paste0(out, "_genes.csv"), row.names = FALSE)
cat(paste(lines, collapse = "\n"), "\n")
