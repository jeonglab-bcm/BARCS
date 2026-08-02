# Optional guide-to-gene summaries.
#
# Every function here is explicitly labelled with the null it assumes. None of
# them treats guides as biological replicates; each one states in its
# documentation what exchangeability it does assume.

#' Test a shared guide effect against an empirical gene-level null
#'
#' This function is intended for exploratory screens in which several
#' independently designed guides target each gene but biological replication
#' is too limited for reliable guide-level reference distributions. It does
#' not treat guides as biological replicates. Instead, it estimates one shared
#' gene effect by inverse-variance weighting of guide coefficients, forms its
#' model-based Wald statistic, then calibrates the gene-statistic distribution
#' with a robust empirical null. It does not combine guide p-values by
#' Fisher's or Stouffer's method.
#'
#' For gene \eqn{g}, let \eqn{w_{gj} = \mathrm{SE}(\widehat\beta_{gj})^{-2}}.
#' The shared effect and raw statistic are
#' \deqn{\widehat\beta_g =
#' \frac{\sum_j w_{gj}\widehat\beta_{gj}}{\sum_j w_{gj}},\qquad
#' T_g = \widehat\beta_g\sqrt{\sum_j w_{gj}}.}{
#' beta_g = (sum_j w_gj beta_gj) / (sum_j w_gj),
#' T_g = beta_g * sqrt(sum_j w_gj).}
#' Its null center is the median score among control genes when enough are
#' supplied, and otherwise the median across all genes. The null scale is the
#' largest of `min_scale`, the all-gene MAD, and the control-gene tail scale.
#' The all-gene MAD assumes that fewer than half of genes are active.
#'
#' @param result A guide-level result from [bb_screen()]. If control
#'   calibration has already been applied, the retained `raw_std_error`
#'   column is used automatically.
#' @param control Optional non-missing logical vector identifying control
#'   guides. A control gene must contain only control guides.
#' @param min_guides Minimum number of finite guide scores required per gene.
#' @param alpha Tail probability used to estimate the control-gene scale.
#' @param min_control_genes Minimum number of valid control genes needed to
#'   use their median and tail scale.
#' @param min_scale Lower bound for the empirical-null scale.
#'
#' @return A data frame with one row per testable gene. `statistic` is the
#'   empirical-null standardized gene score and `p_value` uses a standard
#'   normal reference. The null parameters are also stored as the attributes
#'   `"null_center"`, `"null_scale"`, `"global_scale"`, `"control_scale"`, and
#'   `"control_genes"`.
#'
#' @family gene-level summaries
#' @export
#' @examples
#' guides <- barcs_example_guides()
#' bb_gene_consistency(
#'   guides,
#'   control = startsWith(guides$gene, "control"),
#'   min_control_genes = 2
#' )
bb_gene_consistency <- function(result, control = NULL, min_guides = 3L,
                                alpha = 0.05, min_control_genes = 10L,
                                min_scale = 1) {
  required <- c("gene", "estimate", "std_error")
  if (!is.data.frame(result) || !all(required %in% names(result))) {
    .bb_stop(
      "`result` must contain guide-level `gene`, `estimate`, and `std_error` columns."
    )
  }
  if (anyNA(result$gene)) {
    .bb_stop("`result$gene` cannot contain missing values.")
  }
  if (length(min_guides) != 1L || !is.finite(min_guides) ||
      min_guides < 2) {
    .bb_stop("`min_guides` must be an integer of at least two.")
  }
  if (length(alpha) != 1L || !is.finite(alpha) ||
      alpha <= 0 || alpha >= 0.5) {
    .bb_stop("`alpha` must be one finite number between 0 and 0.5.")
  }
  if (length(min_control_genes) != 1L ||
      !is.finite(min_control_genes) || min_control_genes < 2) {
    .bb_stop("`min_control_genes` must be an integer of at least two.")
  }
  if (length(min_scale) != 1L || !is.finite(min_scale) ||
      min_scale <= 0) {
    .bb_stop("`min_scale` must be positive.")
  }
  min_guides <- as.integer(min_guides)
  min_control_genes <- as.integer(min_control_genes)

  if (is.null(control)) {
    control <- rep(FALSE, nrow(result))
  } else if (!is.logical(control) || length(control) != nrow(result) ||
             anyNA(control)) {
    .bb_stop("`control` must be a non-missing logical vector, one per guide.")
  }
  control_by_gene <- split(control, result$gene)
  mixed_control <- vapply(
    control_by_gene,
    function(value) any(value) && !all(value),
    logical(1L)
  )
  if (any(mixed_control)) {
    .bb_stop("A gene cannot mix control and non-control guides.")
  }

  standard_error <- if ("raw_std_error" %in% names(result)) {
    result$raw_std_error
  } else {
    result$std_error
  }
  valid <- is.finite(result$estimate) &
    is.finite(standard_error) &
    standard_error > 0
  groups <- split(seq_len(nrow(result)), result$gene)
  pieces <- lapply(names(groups), function(gene_name) {
    index <- groups[[gene_name]]
    index <- index[valid[index]]
    if (length(index) < min_guides) {
      return(NULL)
    }
    guide_weight <- 1 / standard_error[index]^2
    gene_estimate <- sum(
      guide_weight * result$estimate[index]
    ) / sum(guide_weight)
    gene_standard_error <- sqrt(1 / sum(guide_weight))
    nonzero <- result$estimate[index] != 0
    agreement <- if (gene_estimate == 0 || !any(nonzero)) {
      NA_real_
    } else {
      mean(
        sign(result$estimate[index][nonzero]) == sign(gene_estimate)
      )
    }
    data.frame(
      gene = gene_name,
      n_guides = length(index),
      estimate = gene_estimate,
      std_error = gene_standard_error,
      raw_statistic = gene_estimate / gene_standard_error,
      guide_direction_agreement = agreement,
      converged_fraction = if ("converged" %in% names(result)) {
        mean(result$converged[index], na.rm = TRUE)
      } else {
        NA_real_
      },
      control_gene = all(control[index]),
      row.names = NULL
    )
  })
  pieces <- Filter(Negate(is.null), pieces)
  if (length(pieces) < 2L) {
    .bb_stop("At least two genes must have enough finite guide scores.")
  }
  gene_result <- do.call(rbind, pieces)
  rownames(gene_result) <- NULL

  global_center <- stats::median(gene_result$raw_statistic)
  global_scale <- stats::mad(
    gene_result$raw_statistic,
    center = global_center,
    constant = 1 / stats::qnorm(0.75)
  )
  if (!is.finite(global_scale) || global_scale <= 0) {
    global_scale <- 1
  }

  control_statistic <- gene_result$raw_statistic[
    gene_result$control_gene
  ]
  enough_controls <- length(control_statistic) >= min_control_genes
  null_center <- if (enough_controls) {
    stats::median(control_statistic)
  } else {
    global_center
  }
  control_scale <- if (enough_controls) {
    as.numeric(stats::quantile(
      abs(control_statistic - null_center),
      probs = 1 - alpha,
      names = FALSE,
      type = 8
    )) / stats::qnorm(1 - alpha / 2)
  } else {
    NA_real_
  }
  scale_candidates <- c(min_scale, global_scale, control_scale)
  null_scale <- max(scale_candidates[is.finite(scale_candidates)])

  gene_result$statistic <-
    (gene_result$raw_statistic - null_center) / null_scale
  gene_result$p_value <- 2 * stats::pnorm(-abs(gene_result$statistic))
  gene_result$fdr <- stats::p.adjust(gene_result$p_value, method = "BH")
  attr(gene_result, "null_center") <- null_center
  attr(gene_result, "null_scale") <- null_scale
  attr(gene_result, "global_scale") <- global_scale
  attr(gene_result, "control_scale") <- control_scale
  attr(gene_result, "control_genes") <- length(control_statistic)
  attr(gene_result, "null_assumption") <-
    paste(
      "Shared-effect guide-consistency empirical null;",
      "not biological-replicate inference."
    )
  gene_result
}

.bb_gene_pooling_inputs <- function(result, control, min_guides) {
  required <- c("gene", "estimate", "std_error")
  if (!is.data.frame(result) || !all(required %in% names(result))) {
    .bb_stop(
      "`result` must contain guide-level `gene`, `estimate`, and `std_error` columns."
    )
  }
  if (anyNA(result$gene) || any(!nzchar(as.character(result$gene)))) {
    .bb_stop("`result$gene` must contain non-missing gene identifiers.")
  }
  if (length(min_guides) != 1L || !is.finite(min_guides) ||
      min_guides < 2) {
    .bb_stop("`min_guides` must be an integer of at least two.")
  }
  if (is.null(control)) {
    control <- rep(FALSE, nrow(result))
  } else if (!is.logical(control) || length(control) != nrow(result) ||
             anyNA(control)) {
    .bb_stop("`control` must be a non-missing logical vector, one per guide.")
  }
  control_by_gene <- split(control, result$gene)
  mixed_control <- vapply(
    control_by_gene,
    function(value) any(value) && !all(value),
    logical(1L)
  )
  if (any(mixed_control)) {
    .bb_stop("A gene cannot mix control and non-control guides.")
  }
  standard_error <- if ("raw_std_error" %in% names(result)) {
    result$raw_std_error
  } else {
    result$std_error
  }
  valid <- is.finite(result$estimate) &
    is.finite(standard_error) &
    standard_error > 0
  if ("converged" %in% names(result)) {
    valid <- valid & !is.na(result$converged) & result$converged
  }
  list(
    result = result,
    control = control,
    standard_error = standard_error,
    valid = valid,
    min_guides = as.integer(min_guides)
  )
}

#' Reproduce the original BARCS guide-to-gene statistic
#'
#' Converts each two-sided guide p-value to a signed standard-normal score and
#' sums those scores within genes. This function exists to keep the historical
#' BARCS benchmark calculation explicit while newer effect-pooling methods are
#' evaluated beside it.
#'
#' @param result Guide-level result returned by [bb_screen()], optionally
#'   calibrated by [bb_calibrate_controls()].
#' @param min_guides Minimum number of finite guide results required per gene.
#'
#' @return One row per testable gene with the historical signed-z `statistic`,
#'   its `p_value`, and the Benjamini-Hochberg `fdr`.
#'
#' @family gene-level summaries
#' @export
#' @examples
#' bb_gene_original(barcs_example_guides())
bb_gene_original <- function(result, min_guides = 1L) {
  required <- c("gene", "estimate", "p_value")
  if (!is.data.frame(result) || !all(required %in% names(result))) {
    .bb_stop(
      "`result` must contain guide-level `gene`, `estimate`, and `p_value` columns."
    )
  }
  if (anyNA(result$gene) || any(!nzchar(as.character(result$gene)))) {
    .bb_stop("`result$gene` must contain non-missing gene identifiers.")
  }
  if (length(min_guides) != 1L || !is.finite(min_guides) ||
      min_guides < 1) {
    .bb_stop("`min_guides` must be one positive integer.")
  }
  min_guides <- as.integer(min_guides)
  valid <- is.finite(result$estimate) &
    is.finite(result$p_value) &
    result$p_value >= 0 &
    result$p_value <= 1
  if ("converged" %in% names(result)) {
    valid <- valid & !is.na(result$converged) & result$converged
  }
  groups <- split(seq_len(nrow(result)), result$gene)
  pieces <- lapply(names(groups), function(gene_name) {
    all_index <- groups[[gene_name]]
    index <- all_index[valid[all_index]]
    if (length(index) < min_guides) {
      return(NULL)
    }
    signed_z <- sign(result$estimate[index]) * stats::qnorm(
      pmax(result$p_value[index] / 2, .Machine$double.xmin),
      lower.tail = FALSE
    )
    combined_z <- sum(signed_z) / sqrt(length(signed_z))
    gene_estimate <- stats::median(result$estimate[index])
    data.frame(
      gene = gene_name,
      n_guides = length(index),
      estimate = gene_estimate,
      statistic = combined_z,
      guide_direction_agreement = if (gene_estimate == 0) {
        NA_real_
      } else {
        mean(sign(result$estimate[index]) == sign(gene_estimate))
      },
      effect_statistic_sign_agreement =
        gene_estimate == 0 || sign(gene_estimate) == sign(combined_z),
      p_value = 2 * stats::pnorm(-abs(combined_z)),
      converged_fraction = if ("converged" %in% names(result)) {
        mean(result$converged[all_index], na.rm = TRUE)
      } else {
        NA_real_
      },
      method = "original",
      row.names = NULL
    )
  })
  pieces <- Filter(Negate(is.null), pieces)
  if (!length(pieces)) {
    .bb_stop("No gene has enough finite guide results.")
  }
  gene_result <- do.call(rbind, pieces)
  rownames(gene_result) <- NULL
  gene_result$fdr <- stats::p.adjust(gene_result$p_value, method = "BH")
  gene_result
}

#' Test whether normally distributed guide coefficients have nonzero mean
#'
#' Treats the fitted guide coefficients within each gene as exchangeable
#' observations \eqn{\widehat\beta_{gj} \sim N(\mu_g, \sigma_g^2)}. The gene
#' effect is the arithmetic mean, the guide-effect standard deviation is
#' estimated by the ordinary sample standard deviation, and the standard error
#' of the mean is \eqn{s_g/\sqrt{m_g}}. Because \eqn{\sigma_g} is estimated
#' rather than known, the default p-value uses a Student t reference with
#' \eqn{m_g-1} degrees of freedom. A plug-in standard-normal p-value is
#' returned separately and can be selected explicitly for sensitivity
#' analysis.
#'
#' This is guide-consistency inference, not biological-replicate inference.
#' It deliberately gives every valid guide equal weight and does not use the
#' guide-specific regression standard errors.
#'
#' @param result Guide-level result returned by [bb_screen()].
#' @param min_guides Minimum number of finite guide coefficients per gene.
#' @param reference Reference distribution for the reported `p_value`:
#'   `"student_t"` (default) or the plug-in `"normal"` approximation.
#'
#' @return One row per testable gene with the estimated normal mean and
#'   standard deviation, standard error of the mean, t/z statistics, both
#'   reference p-values, the selected `p_value`, and FDR.
#'
#' @family gene-level summaries
#' @export
#' @examples
#' bb_gene_normal(barcs_example_guides(), min_guides = 3L)
bb_gene_normal <- function(result, min_guides = 3L,
                           reference = c("student_t", "normal")) {
  required <- c("gene", "estimate")
  if (!is.data.frame(result) || !all(required %in% names(result))) {
    .bb_stop("`result` must contain guide-level `gene` and `estimate` columns.")
  }
  if (anyNA(result$gene) || any(!nzchar(as.character(result$gene)))) {
    .bb_stop("`result$gene` must contain non-missing gene identifiers.")
  }
  if (length(min_guides) != 1L || !is.finite(min_guides) ||
      min_guides < 2) {
    .bb_stop("`min_guides` must be an integer of at least two.")
  }
  reference <- match.arg(reference)
  min_guides <- as.integer(min_guides)
  valid <- is.finite(result$estimate)
  if ("converged" %in% names(result)) {
    valid <- valid & !is.na(result$converged) & result$converged
  }

  groups <- split(seq_len(nrow(result)), result$gene)
  pieces <- lapply(names(groups), function(gene_name) {
    all_index <- groups[[gene_name]]
    index <- all_index[valid[all_index]]
    n_guides <- length(index)
    if (n_guides < min_guides) {
      return(NULL)
    }
    guide_beta <- result$estimate[index]
    mu <- mean(guide_beta)
    sigma <- stats::sd(guide_beta)
    standard_error <- sigma / sqrt(n_guides)
    statistic <- if (standard_error > 0) {
      mu / standard_error
    } else if (mu == 0) {
      0
    } else {
      sign(mu) * Inf
    }
    degrees_freedom <- n_guides - 1L
    student_p_value <- 2 * stats::pt(
      -abs(statistic), df = degrees_freedom
    )
    normal_p_value <- 2 * stats::pnorm(-abs(statistic))
    data.frame(
      gene = gene_name,
      n_guides = n_guides,
      estimate = mu,
      sigma = sigma,
      std_error = standard_error,
      statistic = statistic,
      df = degrees_freedom,
      student_p_value = student_p_value,
      normal_p_value = normal_p_value,
      p_value = if (reference == "student_t") {
        student_p_value
      } else {
        normal_p_value
      },
      guide_direction_agreement = if (mu == 0) {
        NA_real_
      } else {
        mean(sign(guide_beta) == sign(mu))
      },
      converged_fraction = if ("converged" %in% names(result)) {
        mean(result$converged[all_index], na.rm = TRUE)
      } else {
        NA_real_
      },
      method = paste0("normal_beta_", reference),
      row.names = NULL
    )
  })
  pieces <- Filter(Negate(is.null), pieces)
  if (!length(pieces)) {
    .bb_stop("No gene has enough finite guide coefficients.")
  }
  gene_result <- do.call(rbind, pieces)
  rownames(gene_result) <- NULL
  gene_result$fdr <- stats::p.adjust(gene_result$p_value, method = "BH")
  attr(gene_result, "reference") <- reference
  attr(gene_result, "null_assumption") <- paste(
    "Exchangeable normally distributed guide coefficients;",
    "not biological-replicate inference."
  )
  gene_result
}

.bb_gene_pooling_components <- function(inputs) {
  result <- inputs$result
  standard_error <- inputs$standard_error
  valid <- inputs$valid
  control <- inputs$control
  groups <- split(seq_len(nrow(result)), result$gene)
  pieces <- lapply(names(groups), function(gene_name) {
    all_index <- groups[[gene_name]]
    index <- all_index[valid[all_index]]
    if (length(index) < inputs$min_guides) {
      return(NULL)
    }
    estimate <- result$estimate[index]
    variance <- standard_error[index]^2
    fixed_weight <- 1 / variance
    fixed_estimate <- sum(fixed_weight * estimate) / sum(fixed_weight)
    q <- sum(fixed_weight * (estimate - fixed_estimate)^2)
    heterogeneity_df <- length(index) - 1
    c_value <- sum(fixed_weight) -
      sum(fixed_weight^2) / sum(fixed_weight)
    tau2 <- if (is.finite(c_value) && c_value > 0) {
      max(0, (q - heterogeneity_df) / c_value)
    } else {
      0
    }
    direction_agreement <- if (fixed_estimate == 0) {
      NA_real_
    } else {
      mean(sign(estimate) == sign(fixed_estimate))
    }
    data.frame(
      gene = gene_name,
      n_guides = length(index),
      fixed_estimate = fixed_estimate,
      fixed_information = sum(fixed_weight),
      heterogeneity_q = q,
      heterogeneity_df = heterogeneity_df,
      heterogeneity_c = c_value,
      raw_tau2 = tau2,
      i_squared = if (q > 0) {
        max(0, (q - heterogeneity_df) / q)
      } else {
        0
      },
      guide_direction_agreement = direction_agreement,
      converged_fraction = if ("converged" %in% names(result)) {
        mean(result$converged[all_index], na.rm = TRUE)
      } else {
        NA_real_
      },
      control_gene = all(control[all_index]),
      row.names = NULL
    )
  })
  pieces <- Filter(Negate(is.null), pieces)
  if (length(pieces) < 2L) {
    .bb_stop("At least two genes must have enough finite guide scores.")
  }
  components <- do.call(rbind, pieces)
  rownames(components) <- NULL
  components
}

.bb_calibrate_gene_statistics <- function(result, alpha,
                                          min_control_genes,
                                          min_scale) {
  if (length(alpha) != 1L || !is.finite(alpha) ||
      alpha <= 0 || alpha >= 0.5) {
    .bb_stop("`alpha` must be one finite number between 0 and 0.5.")
  }
  if (length(min_control_genes) != 1L ||
      !is.finite(min_control_genes) || min_control_genes < 2) {
    .bb_stop("`min_control_genes` must be an integer of at least two.")
  }
  if (length(min_scale) != 1L || !is.finite(min_scale) ||
      min_scale <= 0) {
    .bb_stop("`min_scale` must be positive.")
  }
  global_center <- stats::median(result$raw_statistic)
  global_scale <- stats::mad(
    result$raw_statistic,
    center = global_center,
    constant = 1 / stats::qnorm(0.75)
  )
  if (!is.finite(global_scale) || global_scale <= 0) {
    global_scale <- 1
  }
  control_statistic <- result$raw_statistic[result$control_gene]
  enough_controls <-
    length(control_statistic) >= as.integer(min_control_genes)
  null_center <- if (enough_controls) {
    stats::median(control_statistic)
  } else {
    global_center
  }
  control_scale <- if (enough_controls) {
    as.numeric(stats::quantile(
      abs(control_statistic - null_center),
      probs = 1 - alpha,
      names = FALSE,
      type = 8
    )) / stats::qnorm(1 - alpha / 2)
  } else {
    NA_real_
  }
  scale_candidates <- c(min_scale, global_scale, control_scale)
  null_scale <- max(scale_candidates[is.finite(scale_candidates)])
  result$statistic <-
    (result$raw_statistic - null_center) / null_scale
  result$p_value <- 2 * stats::pnorm(-abs(result$statistic))
  result$fdr <- stats::p.adjust(result$p_value, method = "BH")
  attr(result, "null_center") <- null_center
  attr(result, "null_scale") <- null_scale
  attr(result, "global_scale") <- global_scale
  attr(result, "control_scale") <- control_scale
  attr(result, "control_genes") <- length(control_statistic)
  result
}

.bb_finish_gene_pooling <- function(inputs, components, tau2,
                                    method, alpha,
                                    min_control_genes, min_scale) {
  result <- inputs$result
  standard_error <- inputs$standard_error
  valid <- inputs$valid
  groups <- split(seq_len(nrow(result)), result$gene)
  rows <- lapply(seq_len(nrow(components)), function(row_index) {
    gene_name <- components$gene[row_index]
    all_index <- groups[[gene_name]]
    index <- all_index[valid[all_index]]
    estimate <- result$estimate[index]
    variance <- standard_error[index]^2
    gene_tau2 <- tau2[row_index]
    weight <- 1 / (variance + gene_tau2)
    gene_estimate <- sum(weight * estimate) / sum(weight)
    gene_standard_error <- sqrt(1 / sum(weight))
    posterior_weight <- gene_tau2 / (gene_tau2 + variance)
    shrunken_guide_effect <-
      gene_estimate + posterior_weight * (estimate - gene_estimate)
    leave_one_out <- vapply(seq_along(index), function(drop_index) {
      keep <- seq_along(index) != drop_index
      sum(weight[keep] * estimate[keep]) / sum(weight[keep])
    }, numeric(1L))
    data.frame(
      gene = gene_name,
      n_guides = length(index),
      estimate = gene_estimate,
      std_error = gene_standard_error,
      raw_statistic = gene_estimate / gene_standard_error,
      tau2 = gene_tau2,
      raw_tau2 = components$raw_tau2[row_index],
      heterogeneity_q = components$heterogeneity_q[row_index],
      heterogeneity_df = components$heterogeneity_df[row_index],
      i_squared = components$i_squared[row_index],
      guide_direction_agreement =
        components$guide_direction_agreement[row_index],
      max_weight_fraction = max(weight / sum(weight)),
      max_shrinkage = max(abs(shrunken_guide_effect - estimate)),
      leave_one_out_max_change =
        max(abs(leave_one_out - gene_estimate)),
      leave_one_out_sign_stable = if (gene_estimate == 0) {
        NA
      } else {
        all(sign(leave_one_out) == sign(gene_estimate))
      },
      converged_fraction = components$converged_fraction[row_index],
      control_gene = components$control_gene[row_index],
      method = method,
      row.names = NULL
    )
  })
  pooled <- do.call(rbind, rows)
  rownames(pooled) <- NULL
  .bb_calibrate_gene_statistics(
    pooled,
    alpha = alpha,
    min_control_genes = min_control_genes,
    min_scale = min_scale
  )
}

#' Combine guide effects by random-effects partial pooling
#'
#' Preserves every guide-level BARCS coefficient and standard error. For each
#' gene, a DerSimonian-Laird guide-heterogeneity variance is estimated and
#' guide effects are combined with weights
#' \eqn{1 / \{\mathrm{SE}_{gj}^2 + \tau_g^2\}}{1 / (SE_gj^2 + tau_g^2)}. Guide
#' count is not used as biological residual degrees of freedom. The resulting
#' working statistic is calibrated with a robust gene-level empirical null.
#'
#' @param result Guide-level result returned by [bb_screen()].
#' @param control Optional logical vector identifying negative-control guides.
#' @param min_guides Minimum number of finite guides required per gene.
#' @param alpha Tail probability used for empirical-null calibration.
#' @param min_control_genes Minimum valid control genes required to use the
#'   control-only null.
#' @param min_scale Lower bound for empirical-null scale.
#'
#' @return One row per testable gene with the partially pooled effect,
#'   uncertainty, heterogeneity (`tau2`, `i_squared`), influence diagnostics
#'   (`max_weight_fraction`, `leave_one_out_max_change`), p-value, and FDR.
#'
#' @family gene-level summaries
#' @export
#' @examples
#' guides <- barcs_example_guides()
#' bb_gene_partial_pool(
#'   guides,
#'   control = startsWith(guides$gene, "control"),
#'   min_control_genes = 2
#' )
bb_gene_partial_pool <- function(result, control = NULL, min_guides = 2L,
                                 alpha = 0.05,
                                 min_control_genes = 10L,
                                 min_scale = 1) {
  inputs <- .bb_gene_pooling_inputs(result, control, min_guides)
  components <- .bb_gene_pooling_components(inputs)
  pooled <- .bb_finish_gene_pooling(
    inputs,
    components,
    tau2 = components$raw_tau2,
    method = "partial_pooling",
    alpha = alpha,
    min_control_genes = min_control_genes,
    min_scale = min_scale
  )
  attr(pooled, "heterogeneity_estimator") <- "DerSimonian-Laird"
  attr(pooled, "null_assumption") <-
    "Guide random-effects model with a robust gene-level empirical null."
  pooled
}

#' Combine guide effects with empirical-Bayes heterogeneity moderation
#'
#' Starts from the same random-effects guide model as
#' [bb_gene_partial_pool()]. A screen-wide heterogeneity variance is estimated
#' by pooling excess Cochran Q across genes. Each noisy gene-specific
#' heterogeneity estimate is then shrunk toward that screen-wide value:
#' \deqn{\widetilde\tau_g^2 =
#' \frac{d_g\widehat\tau_g^2 + d_0\tau_0^2}{d_g+d_0}.}{
#' tau_g^2 = (d_g * tau_g^2 + d_0 * tau_0^2) / (d_g + d_0).}
#' The prior scale is learned without truth labels; `prior_df` controls its
#' prespecified strength.
#'
#' @inheritParams bb_gene_partial_pool
#' @param prior_df Positive prior degrees of freedom controlling moderation.
#'
#' @return One row per testable gene with moderated heterogeneity and the same
#'   guide-agreement and influence diagnostics as partial pooling. The
#'   estimated `prior_tau2` and the supplied `prior_df` are stored as
#'   attributes.
#'
#' @family gene-level summaries
#' @export
#' @examples
#' guides <- barcs_example_guides()
#' bb_gene_eb_moderate(
#'   guides,
#'   control = startsWith(guides$gene, "control"),
#'   min_control_genes = 2,
#'   prior_df = 4
#' )
bb_gene_eb_moderate <- function(result, control = NULL, min_guides = 2L,
                                prior_df = 4,
                                alpha = 0.05,
                                min_control_genes = 10L,
                                min_scale = 1) {
  if (length(prior_df) != 1L || !is.finite(prior_df) || prior_df <= 0) {
    .bb_stop("`prior_df` must be one positive finite number.")
  }
  inputs <- .bb_gene_pooling_inputs(result, control, min_guides)
  components <- .bb_gene_pooling_components(inputs)
  total_c <- sum(components$heterogeneity_c)
  prior_tau2 <- if (is.finite(total_c) && total_c > 0) {
    max(
      0,
      sum(
        components$heterogeneity_q - components$heterogeneity_df
      ) / total_c
    )
  } else {
    0
  }
  moderated_tau2 <- (
    components$heterogeneity_df * components$raw_tau2 +
      prior_df * prior_tau2
  ) / (components$heterogeneity_df + prior_df)
  pooled <- .bb_finish_gene_pooling(
    inputs,
    components,
    tau2 = moderated_tau2,
    method = "empirical_bayes",
    alpha = alpha,
    min_control_genes = min_control_genes,
    min_scale = min_scale
  )
  attr(pooled, "prior_tau2") <- prior_tau2
  attr(pooled, "prior_df") <- prior_df
  attr(pooled, "heterogeneity_estimator") <-
    "DerSimonian-Laird moderated toward pooled excess-Q prior"
  attr(pooled, "null_assumption") <- paste(
    "Empirical-Bayes moderated guide random-effects model;",
    "not biological-replicate inference."
  )
  pooled
}
