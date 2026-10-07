#!/usr/bin/env Rscript
# Run BARCS on a screen described by a design file.
#
#   Rscript tools/screen-reanalysis/run_barcs.R <design.json> [--out results]
#
# The design file (written by the agent, see SKILL.md) names the count file,
# the guide and gene columns, every sample column with its covariates, and
# one or more analyses (formula + coefficient). For each analysis this writes
# <out>/<analysis>/guides.csv.gz, genes.csv, and run_info.json.

suppressPackageStartupMessages({
  library(jsonlite)
  library(BARCS)
})

args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Usage: run_barcs.R <design.json> [--out results]", call. = FALSE)
design_path <- args[[1]]
out_hit <- match("--out", args)
out_root <- if (is.na(out_hit)) file.path(dirname(design_path), "results") else args[[out_hit + 1L]]
ncores <- as.integer(Sys.getenv("BARCS_NCORES", "2"))

design <- fromJSON(design_path, simplifyVector = TRUE)
required <- c("counts_file", "guide_column", "gene_column", "samples", "analyses")
missing <- setdiff(required, names(design))
if (length(missing)) stop("design.json is missing: ", paste(missing, collapse = ", "), call. = FALSE)

counts_path <- design$counts_file
if (!file.exists(counts_path)) counts_path <- file.path(dirname(design_path), counts_path)
read_counts <- function(path) {
  if (grepl("\\.xlsx?$", path, ignore.case = TRUE)) {
    return(as.data.frame(readxl::read_excel(path, sheet = design$sheet %||% 1L)))
  }
  first <- readLines(if (grepl("\\.gz$", path)) gzfile(path) else path, n = 1L)
  utils::read.delim(if (grepl("\\.gz$", path)) gzfile(path) else path,
                    sep = if (grepl("\t", first)) "\t" else ",",
                    check.names = FALSE, stringsAsFactors = FALSE)
}
`%||%` <- function(a, b) if (is.null(a)) b else a
table <- read_counts(counts_path)

samples <- as.data.frame(design$samples, stringsAsFactors = FALSE)
if (!"column" %in% names(samples)) stop("Each sample needs a 'column'.", call. = FALSE)
absent <- setdiff(samples$column, names(table))
if (length(absent)) stop("Sample columns not in the count file: ", paste(absent, collapse = ", "),
                         call. = FALSE)

counts_all <- as.matrix(table[, samples$column, drop = FALSE])
storage.mode(counts_all) <- "double"
if (any(abs(counts_all - round(counts_all)) > 1e-8, na.rm = TRUE)) {
  stop("Sample columns are not integer counts; BARCS needs raw read counts.", call. = FALSE)
}
counts_all[is.na(counts_all)] <- 0
guide <- as.character(table[[design$guide_column]])
gene <- as.character(table[[design$gene_column]])
if (anyDuplicated(guide)) {
  guide <- make.unique(guide)
  message("Duplicate guide identifiers were made unique.")
}
control <- if (!is.null(design$control_gene_pattern) && nzchar(design$control_gene_pattern)) {
  grepl(design$control_gene_pattern, gene, ignore.case = TRUE)
} else {
  rep(FALSE, length(gene))
}
message(sprintf("%d guides, %d genes, %d control guides, %d samples.",
                length(guide), length(unique(gene)), sum(control), ncol(counts_all)))

# Share of reads held by the top 1% of guides in each library: a bottleneck or
# a few resistant clones push it far above the ~2-5% of an unselected library.
top_share <- function(counts) {
  apply(counts, 2L, function(v) sum(sort(v, decreasing = TRUE)[seq_len(ceiling(0.01 * length(v)))]) / sum(v))
}

# Median-of-ratios size factors (guides counted in every library), rescaled to
# read totals. Each total must still be at least that library's largest count;
# libraries where that floor binds are reported as capped.
median_ratio_totals <- function(counts, library_total) {
  positive <- rowSums(counts > 0) == ncol(counts)
  if (sum(positive) < 100L) stop("Too few guides with reads in every library for median-ratio totals.", call. = FALSE)
  log_mean <- rowMeans(log(counts[positive, , drop = FALSE]))
  size <- exp(apply(log(counts[positive, , drop = FALSE]) - log_mean, 2L, stats::median))
  totals <- size / mean(size) * mean(library_total)
  floor_hit <- totals < apply(counts, 2L, max)
  if (any(floor_hit)) message("   median-ratio totals capped at the largest count in: ",
                              paste(colnames(counts)[floor_hit], collapse = ", "))
  stats::setNames(round(pmax(totals, apply(counts, 2L, max))), colnames(counts))
}

# Totals are recorded once, over every guide, before any filtering.
library_totals <- colSums(counts_all)

analyses <- design$analyses
if (is.data.frame(analyses)) analyses <- split(analyses, seq_len(nrow(analyses)))
for (analysis in analyses) {
  analysis <- lapply(analysis, function(v) if (is.list(v) && length(v) == 1L) v[[1]] else v)
  name <- analysis$name
  keep <- if (!is.null(analysis$columns)) samples$column %in% unlist(analysis$columns) else
    rep(TRUE, nrow(samples))
  data <- samples[keep, , drop = FALSE]
  for (variable in names(design$factor_levels %||% list())) {
    if (variable %in% names(data)) {
      levels <- intersect(design$factor_levels[[variable]], unique(data[[variable]]))
      data[[variable]] <- factor(data[[variable]], levels = levels)
    }
  }
  counts <- counts_all[, keep, drop = FALSE]
  totals <- library_totals[keep]
  totals_method <- analysis$totals %||% design$totals %||% "library"
  if (identical(totals_method, "control")) {
    if (!any(control)) stop("Control totals requested but no control guides matched.", call. = FALSE)
    totals <- barcs_control_totals(counts, control)
  } else if (identical(totals_method, "median_ratio")) {
    totals <- median_ratio_totals(counts, library_totals[keep])
  }
  composition <- top_share(counts)
  if (max(composition) > 0.25) {
    message(sprintf("   WARNING: the top 1%% of guides hold up to %.0f%% of reads in one library; ",
                    100 * max(composition)),
            "a composition shift makes library-total depletion calls unreliable. ",
            "Consider \"totals\": \"median_ratio\" and interpret enrichment first.")
  }
  formula <- stats::as.formula(analysis$formula)
  message(sprintf("\n== %s: %s, coefficient %s, %d libraries", name,
                  deparse(formula), analysis$term, ncol(counts)))

  # "auto" (BARCS >= 0.2.1) switches guides whose abundance moves by orders of
  # magnitude to the likelihood-ratio test, where the Wald test breaks down.
  test <- analysis$test %||% design$test %||%
    if ("test" %in% names(formals(bb_screen))) "auto" else "wald"
  screen <- bb_screen(
    counts = counts, data = data, formula = formula, term = analysis$term,
    totals = totals, guide = guide, gene = gene,
    min_total_count = design$min_total_count %||% 30, ncores = ncores,
    test = test
  )
  # Non-targeting guides are a direct null: about 5% should reach p < 0.05.
  # Shared clonal structure between replicates, sort noise, or a dispersion
  # prior that 1-2 residual df cannot estimate all inflate that rate, and the
  # model FDR is then too optimistic. "auto" (default) calibrates against the
  # controls when there are at least 50 of them and more than 7.5% reach 0.05.
  control_rate <- function(x) {
    p <- x$p_value[control]
    if (sum(is.finite(p)) < 20L) NA_real_ else mean(p[is.finite(p)] < 0.05)
  }
  control_p05_raw <- control_rate(screen)
  calibrate <- analysis$calibrate %||% design$calibrate %||% "auto"
  do_calibrate <- isTRUE(calibrate) ||
    (identical(calibrate, "auto") && sum(control) >= 50L &&
       is.finite(control_p05_raw) && control_p05_raw > 0.075)
  if (do_calibrate && sum(control) >= 20L) {
    screen <- bb_calibrate_controls(screen, control = control, method = "tail_quantile")
    message(sprintf("   calibrated to %d control guides (%.1f%% reached p < 0.05 before)",
                    sum(control), 100 * control_p05_raw))
  }
  genes <- bb_gene_stouffer(screen[!control, , drop = FALSE],
                            correlation = attr(screen, "guide_correlation"))
  genes <- genes[order(genes$p_value), , drop = FALSE]

  out <- file.path(out_root, name)
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  utils::write.csv(screen, gzfile(file.path(out, "guides.csv.gz")), row.names = FALSE)
  utils::write.csv(genes, file.path(out, "genes.csv"), row.names = FALSE)
  info <- list(
    analysis = name, formula = deparse(formula), term = analysis$term,
    libraries = ncol(counts), residual_df = ncol(counts) - ncol(stats::model.matrix(formula, data)),
    guides = nrow(screen), genes = nrow(genes),
    moderated = attr(screen, "moderated"), prior_df = attr(screen, "prior_df"),
    guide_correlation = attr(screen, "guide_correlation"),
    control_scale = attr(screen, "control_scale"),
    control_guides = sum(control),
    control_p05_raw = control_p05_raw,
    control_p05 = control_rate(screen),
    totals_method = totals_method,
    test = test,
    guides_lr = if (is.null(screen$lr_used)) 0L else sum(screen$lr_used %in% TRUE),
    top1pct_read_share = as.list(round(composition, 3)),
    genes_fdr_0_10_up = sum(genes$fdr < 0.10 & genes$estimate > 0, na.rm = TRUE),
    genes_fdr_0_10_down = sum(genes$fdr < 0.10 & genes$estimate < 0, na.rm = TRUE),
    genes_fdr_0_05 = sum(genes$fdr < 0.05, na.rm = TRUE),
    genes_fdr_0_10 = sum(genes$fdr < 0.10, na.rm = TRUE),
    barcs_version = as.character(utils::packageVersion("BARCS"))
  )
  writeLines(toJSON(info, auto_unbox = TRUE, pretty = TRUE, null = "null"),
             file.path(out, "run_info.json"))
  message(sprintf("   %d genes at FDR 0.10; guide correlation %.3f; top: %s",
                  info$genes_fdr_0_10, info$guide_correlation %||% NA,
                  paste(utils::head(genes$gene, 8L), collapse = ", ")))
}
