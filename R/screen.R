# Screen-wide application of the single-guide beta-binomial fit.

.bb_empty_screen_row <- function(mean_cpm) {
  c(
    estimate = NA_real_,
    std_error = NA_real_,
    t_value = NA_real_,
    df = NA_real_,
    p_value = NA_real_,
    rho = NA_real_,
    pearson_null = NA_real_,
    mean_cpm = mean_cpm,
    converged = 0
  )
}

#' Apply beta-binomial regression guide by guide
#'
#' Runs [bbreg()] on every row of a count matrix against a shared sample
#' design, reports one prespecified model-matrix coefficient per guide, and
#' adds a Benjamini-Hochberg false discovery rate across guides.
#'
#' Guides whose total count falls below `min_total_count`, and guides whose
#' fit errors, yield an all-missing row with `converged = FALSE` rather than
#' aborting the screen.
#'
#' @param counts Guide-by-sample count matrix or data frame.
#' @param data Sample-level covariate data frame, one row per column of
#'   `counts`, in the same order.
#' @param formula One-sided regression formula.
#' @param term Name of the model-matrix coefficient to report. It must match a
#'   column of `model.matrix(formula, data)`.
#' @param totals Optional integer-valued library-size vector holding the
#'   unfiltered mapped-guide total per sample. Defaults to the column sums of
#'   `counts`, which is only correct when `counts` has not been filtered.
#' @param guide Optional guide identifiers. Defaults to the row names of
#'   `counts`.
#' @param gene Optional gene identifier per guide. When supplied, a `gene`
#'   column is prepended and the result can be passed to the `bb_gene_*()`
#'   summaries.
#' @param min_total_count Guides whose summed count falls below this receive
#'   missing results.
#' @param ncores Number of forked workers on Unix-like systems. Windows always
#'   uses one worker.
#' @param ... Additional arguments passed to [bbreg()].
#'
#' @return A data frame with one row per guide and columns `guide`, the
#'   reported coefficient's `estimate`, `std_error`, `t_value`, `df` and
#'   `p_value`, the fitted dispersion `rho`, the untruncated binomial Pearson
#'   statistic `pearson_null`, the guide's `mean_cpm`, a `converged` flag, and
#'   the Benjamini-Hochberg `fdr`.
#'
#' @seealso [bb_calibrate_controls()] and [bb_moderate_dispersion()] to
#'   recalibrate these tests, and the `bb_gene_*()` functions to summarise
#'   them by gene.
#' @family guide-level modelling
#' @export
#' @examples
#' set.seed(4)
#' design <- data.frame(
#'   day = rep(c(0, 7, 14), each = 3),
#'   replicate = factor(rep(1:3, 3))
#' )
#' totals <- rep(60000L, nrow(design))
#' simulate_guide <- function(slope) {
#'   rbinom(nrow(design), totals, plogis(-7 + slope * design$day / 14))
#' }
#' counts <- rbind(
#'   geneA_sg1 = simulate_guide(-1.2),
#'   geneA_sg2 = simulate_guide(-1.0),
#'   geneB_sg1 = simulate_guide(0),
#'   geneB_sg2 = simulate_guide(0)
#' )
#'
#' bb_screen(
#'   counts = counts,
#'   data = design,
#'   formula = ~ I(day / 14) + replicate,
#'   term = "I(day/14)",
#'   totals = totals,
#'   gene = sub("_sg[0-9]+$", "", rownames(counts))
#' )
bb_screen <- function(counts, data, formula, term, totals = NULL,
                      guide = rownames(counts), gene = NULL,
                      min_total_count = 10, ncores = 1L, ...) {
  if (!is.matrix(counts) && !is.data.frame(counts)) {
    .bb_stop("`counts` must be a numeric matrix or data frame.")
  }
  counts <- as.matrix(counts)
  storage.mode(counts) <- "double"
  if (anyNA(counts) || any(!is.finite(counts)) || any(counts < 0)) {
    .bb_stop("`counts` must contain finite, non-negative values.")
  }
  if (nrow(data) != ncol(counts)) {
    .bb_stop("`data` must have one row per count-matrix column.")
  }
  if (is.null(totals)) {
    totals <- colSums(counts)
  }
  if (length(totals) != ncol(counts)) {
    .bb_stop("`totals` must have one value per count-matrix column.")
  }
  if (any(counts > rep(totals, each = nrow(counts)))) {
    .bb_stop("A guide count cannot exceed its sample's `total`.")
  }
  # Checked here as well as per guide because the per-guide failure is silent:
  # every fit would return an all-NA row with `converged = FALSE`, which reads
  # as a modelling failure rather than a malformed argument. Size-factor
  # normalization is the usual way to arrive with non-integer totals.
  if (any(abs(totals - round(totals)) >= sqrt(.Machine$double.eps))) {
    .bb_stop(paste0(
      "`totals` must be integer-valued library sizes; round them first. ",
      "A beta-binomial denominator counts sequenced reads, so a fractional ",
      "total has no likelihood."
    ))
  }
  if (is.null(guide)) {
    guide <- sprintf("guide_%d", seq_len(nrow(counts)))
  }
  if (length(guide) != nrow(counts) || anyDuplicated(guide)) {
    .bb_stop("`guide` must uniquely identify every row of `counts`.")
  }
  if (!is.null(gene) && length(gene) != nrow(counts)) {
    .bb_stop("`gene` must have one value per guide.")
  }
  if (length(ncores) != 1L || !is.finite(ncores) || ncores < 1) {
    .bb_stop("`ncores` must be one positive integer.")
  }
  ncores <- as.integer(ncores)

  design <- .bb_make_design(formula, data, ncol(counts))
  if (!term %in% colnames(design$x)) {
    .bb_stop(sprintf(
      "`term` must be one model-matrix coefficient: %s",
      paste(colnames(design$x), collapse = ", ")
    ))
  }

  one_guide <- function(i) {
    mean_cpm <- mean(counts[i, ] / totals * 1e6)
    if (sum(counts[i, ]) < min_total_count) {
      return(.bb_empty_screen_row(mean_cpm))
    }
    fit <- tryCatch(
      bbreg(counts[i, ], totals, formula, data, ...),
      error = function(e) NULL
    )
    if (is.null(fit)) {
      return(.bb_empty_screen_row(mean_cpm))
    }
    tab <- fit$coefficient_table[term, ]
    c(
      estimate = tab[["estimate"]],
      std_error = tab[["std_error"]],
      t_value = tab[["t_value"]],
      df = tab[["df"]],
      p_value = tab[["p_value"]],
      rho = fit$rho,
      pearson_null = fit$pearson_null,
      mean_cpm = mean_cpm,
      converged = as.numeric(fit$converged)
    )
  }
  if (ncores > 1L && .Platform$OS.type == "unix") {
    pieces <- parallel::mclapply(
      seq_len(nrow(counts)), one_guide, mc.cores = ncores
    )
    statistics <- do.call(rbind, pieces)
  } else {
    statistics <- t(vapply(
      seq_len(nrow(counts)), one_guide, numeric(9L)
    ))
  }
  result <- data.frame(
    guide = guide,
    statistics,
    row.names = NULL,
    check.names = FALSE
  )
  result$converged <- as.logical(result$converged)
  if (!is.null(gene)) {
    result <- cbind(gene = gene, result)
  }
  result$fdr <- p.adjust(result$p_value, method = "BH")
  result
}
