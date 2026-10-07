# Screen-wide application of the single-guide beta-binomial fit.

.bb_empty_screen_row <- function(mean_cpm, n_samples) {
  c(
    estimate = NA_real_,
    std_error = NA_real_,
    t_value = NA_real_,
    df = NA_real_,
    p_value = NA_real_,
    wald_std_error = NA_real_,
    lr_used = NA_real_,
    rho = NA_real_,
    pearson_null = NA_real_,
    mean_cpm = mean_cpm,
    converged = 0,
    rep(NA_real_, n_samples)
  )
}

# Average within-gene correlation of guide Pearson residual vectors, minus the
# average correlation of guide pairs drawn from different genes.
#
# Residuals are what remains after the fitted mean has absorbed every design
# effect, so a true gene effect does not inflate this estimate; shared noise
# does. Each gene contributes equally to the within-gene average, so a large
# bucket of control guides labelled as one "gene" cannot dominate it. The
# between-gene baseline removes correlation that every guide shares, such as
# library-wide normalisation artefacts, and is formed from deterministic
# offset pairs so that the estimate does not consume random numbers.
.bb_guide_correlation <- function(residuals, gene) {
  usable <- rowSums(!is.finite(residuals)) == 0
  usable[usable] <- rowSums(residuals[usable, , drop = FALSE]^2) > 0
  residuals <- residuals[usable, , drop = FALSE]
  gene <- as.character(gene[usable])
  empty <- list(correlation = 0, within = NA_real_, between = NA_real_,
                genes = 0L)
  if (nrow(residuals) < 4L) {
    return(empty)
  }
  unit <- residuals / sqrt(rowSums(residuals^2))
  groups <- split(seq_len(nrow(unit)), gene)
  groups <- groups[lengths(groups) >= 2L]
  if (!length(groups)) {
    return(empty)
  }
  within <- vapply(groups, function(index) {
    gram <- tcrossprod(unit[index, , drop = FALSE])
    mean(gram[upper.tri(gram)])
  }, numeric(1L))
  ordering <- order(gene)
  n <- length(ordering)
  offsets <- unique(pmax(
    1L, round(n * c(0.13, 0.29, 0.41, 0.53, 0.67, 0.79))
  ))
  between <- unlist(lapply(offsets, function(offset) {
    first <- ordering
    second <- ordering[(seq_len(n) + offset - 1L) %% n + 1L]
    different <- gene[first] != gene[second]
    rowSums(unit[first[different], , drop = FALSE] *
              unit[second[different], , drop = FALSE])
  }))
  within_mean <- mean(within)
  between_mean <- if (length(between)) mean(between) else 0
  list(
    correlation = min(1, max(0, within_mean - between_mean)),
    within = within_mean,
    between = between_mean,
    genes = length(groups)
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
#' By default the guide dispersions are then moderated toward a library-wide
#' abundance trend with [bb_moderate_dispersion()] whenever at least 50 guides
#' are usable. A pooled screen leaves each guide only a few residual degrees of
#' freedom, and borrowing strength across guides is what lets the guide tests
#' match the ranking of limma-voom and edgeR-QL on real screens. Set
#' `moderate = FALSE` for the unmoderated fit.
#'
#' When `gene` is supplied, `bb_screen()` also estimates the average
#' correlation of guide residuals within genes, after subtracting the average
#' correlation between genes. Residuals exclude every fitted design effect, so
#' a real gene effect does not register as correlation, but noise shared by a
#' gene's guides does. The estimate is stored as the attribute
#' `"guide_correlation"` and used by [bb_gene_stouffer()] to widen the gene
#' statistic's null distribution accordingly.
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
#' @param moderate Moderate guide dispersions with [bb_moderate_dispersion()].
#'   `NULL` (default) moderates when at least 50 guides are usable and skips
#'   moderation otherwise; `TRUE` always moderates and errors if that is not
#'   possible; `FALSE` never moderates.
#' @param test Guide-level test of `term`. `"wald"` (default) uses the
#'   coefficient's Wald standard error. `"lr"` uses the likelihood ratio of the
#'   fits with and without `term`, both at the guide's fitted dispersion, and
#'   reports the standard error that ratio implies, `|estimate| / sqrt(LR)`, so
#'   moderation and the gene summaries apply unchanged. `"auto"` uses the
#'   likelihood ratio only for guides whose fitted proportions span more than
#'   `lr_fold` across samples, and the Wald test otherwise. With one dispersion
#'   per guide, a change of several orders of magnitude implies a very large
#'   logit-scale variance at the low-abundance end, and the Wald standard error
#'   then grows faster than the estimate (the Hauck-Donner effect): a guide that
#'   rises 400-fold in every replicate can test as null. The likelihood ratio
#'   does not have this failure. On ordinary screens the two tests rank guides
#'   alike, and the Wald test is the faster and slightly more conservative one.
#' @param lr_fold Fold range of fitted proportions above which `test = "auto"`
#'   switches a guide to the likelihood-ratio test.
#' @param ncores Number of forked workers on Unix-like systems. Windows always
#'   uses one worker.
#' @param ... Additional arguments passed to [bbreg()].
#'
#' @return A data frame with one row per guide and columns `guide`, the
#'   reported coefficient's `estimate`, `std_error`, `t_value`, `df` and
#'   `p_value`, the fitted dispersion `rho`, the untruncated binomial Pearson
#'   statistic `pearson_null`, the guide's `mean_cpm`, a `converged` flag, and
#'   the Benjamini-Hochberg `fdr`. When moderation ran, the columns documented
#'   in [bb_moderate_dispersion()] are added and the inferential columns are
#'   the moderated ones. The attribute `"moderated"` records whether
#'   moderation ran, and `"guide_correlation"` holds the within-gene residual
#'   correlation when `gene` was supplied, with its components in
#'   `"guide_correlation_detail"`. With `test = "lr"` or `"auto"` the Wald
#'   standard error is kept as `wald_std_error` and `lr_used` flags the guides
#'   tested by likelihood ratio; the attribute `"test"` records the choice.
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
                      min_total_count = 10, moderate = NULL,
                      test = c("wald", "lr", "auto"), lr_fold = 100,
                      ncores = 1L, ...) {
  test <- match.arg(test)
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
  if (length(lr_fold) != 1L || !is.finite(lr_fold) || lr_fold <= 1) {
    .bb_stop("`lr_fold` must be one number greater than one.")
  }
  if (!is.null(moderate) &&
      (!is.logical(moderate) || length(moderate) != 1L || is.na(moderate))) {
    .bb_stop("`moderate` must be NULL, TRUE, or FALSE.")
  }

  design <- .bb_make_design(formula, data, ncol(counts))
  if (!term %in% colnames(design$x)) {
    .bb_stop(sprintf(
      "`term` must be one model-matrix coefficient: %s",
      paste(colnames(design$x), collapse = ", ")
    ))
  }

  n_samples <- ncol(counts)
  one_guide <- function(i) {
    mean_cpm <- mean(counts[i, ] / totals * 1e6)
    if (sum(counts[i, ]) < min_total_count) {
      return(.bb_empty_screen_row(mean_cpm, n_samples))
    }
    fit <- tryCatch(
      bbreg(counts[i, ], totals, formula, data, ...),
      error = function(e) NULL
    )
    if (is.null(fit)) {
      return(.bb_empty_screen_row(mean_cpm, n_samples))
    }
    tab <- fit$coefficient_table[term, ]
    wald_std_error <- tab[["std_error"]]
    std_error <- wald_std_error
    fitted_range <- max(fit$fitted.values) / min(fit$fitted.values)
    use_lr <- test == "lr" || (test == "auto" && fitted_range > lr_fold)
    if (use_lr) {
      signed_root <- tryCatch(.bb_lr_statistic(fit, term),
                              error = function(e) NA_real_)
      if (!is.finite(signed_root)) {
        return(.bb_empty_screen_row(mean_cpm, n_samples))
      }
      # The standard error the likelihood ratio implies, so that
      # estimate / std_error equals the signed root of the ratio.
      if (abs(signed_root) > 1e-8 && tab[["estimate"]] != 0) {
        std_error <- abs(tab[["estimate"]]) / abs(signed_root)
      }
    }
    t_value <- tab[["estimate"]] / std_error
    c(
      estimate = tab[["estimate"]],
      std_error = std_error,
      t_value = t_value,
      df = tab[["df"]],
      p_value = 2 * stats::pt(-abs(t_value), df = tab[["df"]]),
      wald_std_error = wald_std_error,
      lr_used = as.numeric(use_lr),
      rho = fit$rho,
      pearson_null = fit$pearson_null,
      mean_cpm = mean_cpm,
      converged = as.numeric(fit$converged),
      unname(stats::residuals(fit, type = "pearson"))
    )
  }
  if (ncores > 1L && .Platform$OS.type == "unix") {
    pieces <- parallel::mclapply(
      seq_len(nrow(counts)), one_guide, mc.cores = ncores
    )
    statistics <- do.call(rbind, pieces)
  } else {
    statistics <- t(vapply(
      seq_len(nrow(counts)), one_guide, numeric(11L + n_samples)
    ))
  }
  residual_matrix <- statistics[, -seq_len(11L), drop = FALSE]
  statistics <- statistics[, seq_len(11L), drop = FALSE]
  result <- data.frame(
    guide = guide,
    statistics,
    row.names = NULL,
    check.names = FALSE
  )
  result$converged <- as.logical(result$converged)
  if (test == "wald") {
    result$wald_std_error <- NULL
    result$lr_used <- NULL
  } else {
    result$lr_used <- as.logical(result$lr_used)
  }
  if (!is.null(gene)) {
    result <- cbind(gene = gene, result)
  }
  result$fdr <- p.adjust(result$p_value, method = "BH")

  usable <- sum(
    is.finite(result$pearson_null) & is.finite(result$std_error) &
      result$converged
  )
  run_moderation <- if (is.null(moderate)) usable >= 50L else moderate
  if (run_moderation) {
    result <- bb_moderate_dispersion(result)
  }
  attr(result, "moderated") <- run_moderation
  attr(result, "test") <- test
  if (!is.null(gene)) {
    fitted <- result$converged %in% TRUE
    correlation <- .bb_guide_correlation(
      residual_matrix[fitted, , drop = FALSE], gene[fitted]
    )
    attr(result, "guide_correlation") <- correlation$correlation
    attr(result, "guide_correlation_detail") <- unlist(correlation)
  }
  result
}
