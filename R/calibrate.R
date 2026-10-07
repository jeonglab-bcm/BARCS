# Recalibration of guide-level tests: an empirical null estimated from
# negative controls, and empirical-Bayes moderation of guide dispersion.

#' Calibrate guide-level t tests with negative-control guides
#'
#' Estimates a one-parameter empirical-null scale from the absolute
#' negative-control t statistics. The scale matches their empirical
#' `(1 - alpha)` quantile to the corresponding two-sided Student t cutoff.
#' Scales below `min_scale` are truncated, so calibration need not make an
#' already conservative analysis more liberal.
#'
#' All finite control guides must share one residual degrees-of-freedom value,
#' which holds when every guide is fitted with the same complete design.
#' Heterogeneous guide designs need separate calibration strata.
#'
#' @param result A guide-level data frame returned by [bb_screen()].
#' @param control Logical vector identifying negative-control guides, one
#'   element per row of `result`.
#' @param alpha Tail probability at which to estimate the null scale.
#' @param min_controls Minimum number of finite negative controls required.
#' @param min_scale Lower bound for the estimated scale.
#' @param method Null-scale estimator. `"tail_quantile"` (default) matches the
#'   empirical `(1 - alpha)` quantile of the absolute control statistics to the
#'   corresponding two-sided Student t cutoff. `"qq_slope"` instead fits the
#'   slope of the control quantile-quantile plot against the t reference over
#'   the 0.50 to 0.95 probability band, which uses many order statistics rather
#'   than one and is markedly less variable.
#'
#' @return `result` with recalibrated standard errors, t statistics, p-values,
#'   and FDR. Original inferential columns are retained with a `raw_` prefix;
#'   the estimated scale and `alpha` are stored as the attributes
#'   `"control_scale"` and `"control_alpha"`.
#'
#' @family recalibration
#' @export
#' @examples
#' # A control set whose null t statistics are inflated by a factor of 1.5.
#' set.seed(5)
#' n <- 400
#' result <- data.frame(
#'   estimate = rnorm(n),
#'   std_error = 1,
#'   t_value = 1.5 * rt(n, df = 10),
#'   df = 10
#' )
#' result$p_value <- 2 * pt(-abs(result$t_value), df = 10)
#' result$fdr <- p.adjust(result$p_value, method = "BH")
#'
#' calibrated <- bb_calibrate_controls(result, control = rep(TRUE, n))
#' attr(calibrated, "control_scale")
bb_calibrate_controls <- function(result, control, alpha = 0.05,
                                  min_controls = 20L, min_scale = 1,
                                  method = c("tail_quantile", "qq_slope")) {
  method <- match.arg(method)
  required <- c("estimate", "std_error", "t_value", "df", "p_value", "fdr")
  if (!is.data.frame(result) || !all(required %in% names(result))) {
    .bb_stop(
      "`result` must be a guide-level result from `bb_screen()`."
    )
  }
  if (!is.logical(control) || length(control) != nrow(result) ||
      anyNA(control)) {
    .bb_stop("`control` must be a non-missing logical vector, one per guide.")
  }
  if (length(alpha) != 1L || !is.finite(alpha) ||
      alpha <= 0 || alpha >= 0.5) {
    .bb_stop("`alpha` must be one finite number between 0 and 0.5.")
  }
  if (length(min_controls) != 1L || !is.finite(min_controls) ||
      min_controls < 2) {
    .bb_stop("`min_controls` must be at least two.")
  }
  if (length(min_scale) != 1L || !is.finite(min_scale) ||
      min_scale <= 0) {
    .bb_stop("`min_scale` must be positive.")
  }

  valid <- control & is.finite(result$t_value) & is.finite(result$df)
  if (sum(valid) < as.integer(min_controls)) {
    .bb_stop(sprintf(
      "At least %d finite negative-control statistics are required.",
      as.integer(min_controls)
    ))
  }
  control_df <- unique(result$df[valid])
  if (length(control_df) != 1L || control_df <= 0) {
    .bb_stop("Finite negative-control guides must share one positive `df`.")
  }
  if (method == "tail_quantile") {
    # One order statistic in the far tail. Simple, but with a few hundred
    # controls it is a high-variance estimate of the null scale.
    empirical_cutoff <- as.numeric(stats::quantile(
      abs(result$t_value[valid]),
      probs = 1 - alpha,
      names = FALSE,
      type = 8
    ))
    reference_cutoff <- stats::qt(1 - alpha / 2, df = control_df)
    ratio <- empirical_cutoff / reference_cutoff
  } else {
    # Slope of the control quantile-quantile plot against the t reference,
    # through the origin, over the probability band where a few hundred
    # controls still supply many order statistics. This uses the same null
    # information but averages over the band instead of trusting one point.
    probabilities <- seq(0.50, 0.95, by = 0.01)
    empirical <- as.numeric(stats::quantile(
      abs(result$t_value[valid]),
      probs = probabilities,
      names = FALSE,
      type = 8
    ))
    reference <- stats::qt((1 + probabilities) / 2, df = control_df)
    ratio <- sum(empirical * reference) / sum(reference^2)
  }
  scale <- max(min_scale, ratio)

  result$raw_std_error <- result$std_error
  result$raw_t_value <- result$t_value
  result$raw_p_value <- result$p_value
  result$raw_fdr <- result$fdr
  result$std_error <- result$std_error * scale
  result$t_value <- result$t_value / scale
  result$p_value <- 2 * pt(-abs(result$t_value), df = result$df)
  result$fdr <- p.adjust(result$p_value, method = "BH")
  attr(result, "control_scale") <- scale
  attr(result, "control_alpha") <- alpha
  result
}

#' Gene-level empirical null from negative-control pseudo-genes
#'
#' Replaces the model p-values of a [bb_gene_stouffer()] result with p-values
#' read off an empirical null built from the negative-control guides. Each
#' null draw is a pseudo-gene: as many control guides as the gene has, drawn
#' without replacement and summarized like a real gene. A gene's p-value is
#' its two-sided conformal rank among the null draws of its own guide count,
#' `2 * min(1 + #{null >= observed}, 1 + #{null <= observed}) / (1 + n_null)`,
#' capped at one, and FDR is Benjamini-Hochberg on those p-values. Ranks are
#' signed, so a null that is shifted or skewed (for example by a
#' compositional shift that moves every control the same way) is used as it
#' is rather than folded onto its absolute value.
#'
#' Use this when the guide model and [bb_calibrate_controls()] still leave
#' the gene-level FDR too generous: most often when replicate libraries are
#' split from one infected population, so replicates share clone sizes and
#' guide-level variance is underestimated in a way a residual cannot see. A
#' one-parameter rescaling of the guide statistics matches the body of the
#' control distribution but not a heavy, clone-driven tail. The empirical
#' null uses the control tail itself, so its validity rests only on the
#' controls being exchangeable with the guides of null genes (same library,
#' same fitting design and filters), not on the beta-binomial model.
#'
#' Genes and pseudo-genes are compared on the mean of their signed guide z
#' scores. Pseudo-genes are drawn from controls that do not share a gene, so
#' they lack the within-gene guide correlation `r` that [bb_gene_stouffer()]
#' corrects for. Their deviation from the control centre is therefore widened
#' by `sqrt(1 + (m - 1) r)`, which gives a pseudo-gene of `m` guides the null
#' mean and variance of a real gene of `m` correlated guides.
#'
#' For genes of one guide the p-values are conformal and the FDR guarantee
#' is exact under exchangeability. Pseudo-genes of several guides reuse one
#' finite set of controls, so for them control is approximate: in simulated
#' screens with heavy-tailed clonal noise it held the realized FDP near
#' nominal where [bb_calibrate_controls()] did not, but no method held it
#' when a third of the controls reached p < 0.05.
#'
#' The null has limited resolution. With `n` controls and genes of one
#' guide, there are only `n` distinct null values, so the smallest p-value is
#' `2 / (n + 1)`, and Benjamini-Hochberg across `G` genes can call nothing
#' unless about `0.2 G / (n + 1)` genes all reach that floor. A screen of
#' 20,000 one-guide elements and 1,000 controls therefore returns no calls
#' at FDR 0.10 however strong its hits are; read such a result as "the
#' controls cannot confirm the model's calls", not as "no hits". Genes of
#' several guides do not hit this limit as early. The empirical null is not
#' uniformly more conservative than the model: where the model is
#' conservative relative to the controls it calls more genes. Results depend
#' on the random draws; call [set.seed()] first for reproducibility.
#'
#' @param gene_result Gene-level result from [bb_gene_stouffer()] on the
#'   targeting guides.
#' @param guide_result Guide-level result from [bb_screen()] (optionally
#'   moderated or calibrated) that includes the control guides.
#' @param control Logical vector identifying negative-control guides, one
#'   element per row of `guide_result`.
#' @param n_null Number of pseudo-genes drawn for each guide count of two or
#'   more. Genes with one guide are compared with every control guide
#'   directly.
#' @param min_controls Minimum number of usable control guides.
#'
#' @return `gene_result` with empirical `p_value` and `fdr`. The model values
#'   are kept as `raw_p_value` and `raw_fdr`. The attribute
#'   `"empirical_null"` records the number of usable controls and the null
#'   draws used for each guide count. Genes with more guides than there are
#'   usable controls get `NA`.
#'
#' @family recalibration
#' @family gene-level summaries
#' @export
#' @examples
#' # 400 control and 400 targeting guides, two guides per gene, whose null
#' # statistics have a heavier tail than the model assumes.
#' set.seed(7)
#' n <- 800
#' control <- rep(c(TRUE, FALSE), each = n / 2)
#' guides <- data.frame(
#'   gene = c(rep("NTC", n / 2), rep(sprintf("g%03d", 1:200), each = 2)),
#'   estimate = rt(n, df = 3) / 4,
#'   std_error = 0.25
#' )
#' guides$estimate[n - 1:2] <- 3
#' guides$p_value <- 2 * pnorm(-abs(guides$estimate / guides$std_error))
#'
#' genes <- bb_gene_stouffer(guides[!control, ])
#' empirical <- bb_gene_empirical_null(genes, guides, control)
#' c(model = sum(genes$fdr < 0.1), empirical = sum(empirical$fdr < 0.1))
bb_gene_empirical_null <- function(gene_result, guide_result, control,
                                   n_null = 1e5, min_controls = 100L) {
  if (!is.data.frame(gene_result) ||
      !all(c("n_guides", "statistic", "p_value", "fdr") %in%
             names(gene_result))) {
    .bb_stop("`gene_result` must be a gene-level result from `bb_gene_stouffer()`.")
  }
  if ("method" %in% names(gene_result) &&
      any(gene_result$method != "stouffer")) {
    .bb_stop("`gene_result` must come from `bb_gene_stouffer()`.")
  }
  if ("raw_p_value" %in% names(gene_result)) {
    .bb_stop("`gene_result` already carries an empirical null.")
  }
  required <- c("estimate", "p_value")
  if (!is.data.frame(guide_result) ||
      !all(required %in% names(guide_result))) {
    .bb_stop(
      "`guide_result` must contain guide-level `estimate` and `p_value` columns."
    )
  }
  if (!is.logical(control) || length(control) != nrow(guide_result) ||
      anyNA(control)) {
    .bb_stop("`control` must be a non-missing logical vector, one per guide.")
  }
  if (length(n_null) != 1L || !is.finite(n_null) || n_null < 100) {
    .bb_stop("`n_null` must be at least 100.")
  }
  if (length(min_controls) != 1L || !is.finite(min_controls) ||
      min_controls < 2) {
    .bb_stop("`min_controls` must be at least two.")
  }
  n_null <- as.integer(n_null)

  # The same guide validity and z transform as `bb_gene_stouffer()`.
  valid <- control & is.finite(guide_result$estimate) &
    is.finite(guide_result$p_value) &
    guide_result$p_value >= 0 & guide_result$p_value <= 1
  if ("converged" %in% names(guide_result)) {
    valid <- valid & !is.na(guide_result$converged) & guide_result$converged
  }
  n_controls <- sum(valid)
  if (n_controls < as.integer(min_controls)) {
    .bb_stop(sprintf(
      "At least %d usable negative-control guides are required.",
      as.integer(min_controls)
    ))
  }
  control_z <- sign(guide_result$estimate[valid]) * stats::qnorm(
    pmax(guide_result$p_value[valid] / 2, .Machine$double.xmin),
    lower.tail = FALSE
  )
  centre <- mean(control_z)
  correlation <- attr(gene_result, "guide_correlation")
  if (is.null(correlation)) {
    correlation <- 0
  }

  # Mean signed guide z of each gene, recovered from the Stouffer statistic.
  m_gene <- gene_result$n_guides
  observed <- gene_result$statistic *
    sqrt(m_gene + m_gene * (m_gene - 1) * correlation) / m_gene

  p_value <- rep(NA_real_, nrow(gene_result))
  sizes <- sort(unique(m_gene))
  draws <- stats::setNames(integer(length(sizes)), sizes)
  for (m in sizes) {
    if (m > n_controls) {
      next
    }
    rows <- which(m_gene == m)
    if (m == 1L) {
      null <- control_z
    } else {
      null <- vapply(seq_len(n_null), function(i) {
        mean(control_z[sample.int(n_controls, m)])
      }, numeric(1))
      # Controls share no gene: widen to the within-gene correlation.
      null <- centre + (null - centre) * sqrt(1 + (m - 1) * correlation)
    }
    null <- sort(null)
    upper <- length(null) -
      findInterval(observed[rows], null, left.open = TRUE)
    lower <- findInterval(observed[rows], null)
    p_value[rows] <- pmin(
      1, 2 * (1 + pmin(upper, lower)) / (1 + length(null))
    )
    p_value[rows][!is.finite(observed[rows])] <- NA_real_
    draws[as.character(m)] <- length(null)
  }

  gene_result$raw_p_value <- gene_result$p_value
  gene_result$raw_fdr <- gene_result$fdr
  gene_result$p_value <- p_value
  gene_result$fdr <- stats::p.adjust(p_value, method = "BH")
  attr(gene_result, "empirical_null") <- list(
    n_controls = n_controls,
    n_null = draws
  )
  gene_result
}

# Newton iteration solving trigamma(y) = x, used by the scaled-F moment
# estimator in `bb_moderate_dispersion()`.
.bb_trigamma_inverse <- function(x) {
  if (!is.finite(x) || x <= 0) {
    return(Inf)
  }
  if (x > 1e7) {
    return(1 / sqrt(x))
  }
  if (x < 1e-6) {
    return(1 / x)
  }
  y <- 0.5 + 1 / x
  for (iteration in seq_len(50L)) {
    tri <- trigamma(y)
    step <- tri * (1 - tri / x) / psigamma(y, deriv = 2L)
    y <- y + step
    if (abs(step / y) < 1e-8) {
      break
    }
  }
  y
}

#' Moderate guide dispersion toward a library-wide trend
#'
#' [bb_screen()] estimates one beta-binomial dispersion per guide from that
#' guide's own residuals. A pooled screen leaves few residual degrees of
#' freedom per guide, so that estimate is noisy: it inflates some standard
#' errors and deflates others, and the noise carries through to the gene
#' ranking. This function applies the standard empirical-Bayes remedy. It
#' shrinks each guide's variance inflation toward a trend fitted across the
#' whole library and returns a moderated `t` statistic on
#' `df_residual + prior_df` degrees of freedom.
#'
#' The shrinkage target and the prior degrees of freedom are estimated from
#' the data by the scaled-F moment method of Smyth (2004), so the function
#' carries no tuning constant that could be fitted to an outcome.
#'
#' Moderation improves power on screen data for a specific reason. A handful
#' of guides whose own residuals understate their variance drive the
#' negative-control tail, and [bb_calibrate_controls()] can only answer that
#' tail with a blanket penalty applied to every guide in the screen.
#' Correcting those guides individually removes the need for the blanket
#' penalty, so most guides end up tested more sharply even though the noisy
#' ones are tested more strictly.
#'
#' `one_way` and `borrow_df` provide a strictly conservative variant, under
#' which the moderated guide test is never more liberal than the unmoderated
#' one. It is not the default: on the held-out scenarios it gave up most of
#' the power gain without being needed for calibration.
#'
#' Guide variance inflation is taken as `pearson_null / df_residual`, the
#' Pearson dispersion under the binomial model. Unlike `rho` it is not
#' truncated at zero, so it behaves like a scaled chi-square statistic and is
#' the right quantity to shrink. Rescaling the stored standard error by the
#' square root of the moderated-to-fitted inflation ratio is exact when the
#' sample library totals are equal and is a close approximation otherwise.
#'
#' [bb_screen()] calls this function by default, so it is needed directly
#' only to moderate an unmoderated fit (`bb_screen(moderate = FALSE)`) with
#' non-default settings. Moderating an already moderated result is an error.
#'
#' This is guide-level variance moderation. It is independent of, and can be
#' combined with, the gene-level moderation in [bb_gene_eb_moderate()].
#'
#' @param result Guide-level result returned by [bb_screen()], carrying the
#'   `pearson_null` column.
#' @param trend Shrink toward an abundance trend in `mean_cpm` (default) or
#'   toward one library-wide constant.
#' @param one_way Only ever raise a guide's variance toward the library
#'   estimate, never lower it. Off by default. Lowering the variance of a
#'   genuinely noisy guide is the mechanism that makes shared-dispersion count
#'   models anti-conservative, so this is available as a conservative guard,
#'   but on the held-out CRISPulator scenarios it costs real power and was not
#'   needed to hold the realized false-discovery proportion below nominal.
#' @param borrow_df Claim the prior degrees of freedom in the reference
#'   distribution, as ordinary moderated-`t` inference does. On by default.
#'   Turning it off uses the moderated variance while keeping the residual
#'   degrees of freedom the design alone supports.
#' @param span Smoother span used for the abundance trend.
#' @param min_guides Minimum number of usable guides required.
#'
#' @return `result` with moderated standard errors, `t` statistics, degrees of
#'   freedom, p-values, and FDR. The unmoderated columns are retained with an
#'   `unmoderated_` prefix, the per-guide `variance_inflation` and
#'   `moderated_inflation` are added, and the estimated `prior_df` and
#'   `df_total` are stored as attributes.
#'
#' @family recalibration
#' @export
#' @examples
#' # 300 guides sharing a common true variance inflation of 2, each estimated
#' # from only 7 residual degrees of freedom.
#' set.seed(6)
#' n <- 300
#' df_residual <- 7
#' result <- data.frame(
#'   guide = sprintf("g%03d", seq_len(n)),
#'   estimate = rnorm(n, 0, 0.05),
#'   df = df_residual,
#'   mean_cpm = exp(rnorm(n, 6, 0.4)),
#'   converged = TRUE
#' )
#' result$pearson_null <- 2 * rchisq(n, df = df_residual)
#' result$std_error <- 0.05 * sqrt(pmax(1, result$pearson_null / df_residual))
#' result$t_value <- result$estimate / result$std_error
#' result$p_value <- 2 * pt(-abs(result$t_value), df_residual)
#'
#' moderated <- bb_moderate_dispersion(result, trend = FALSE)
#' attr(moderated, "prior_df")
#' # Shrinkage concentrates the inflation estimates on the shared truth.
#' c(raw = sd(result$pearson_null / df_residual),
#'   moderated = sd(moderated$moderated_inflation))
bb_moderate_dispersion <- function(result, trend = TRUE, one_way = FALSE,
                                   borrow_df = TRUE, span = 0.5,
                                   min_guides = 50L) {
  required <- c("estimate", "std_error", "t_value", "df", "p_value",
                "pearson_null")
  if (!is.data.frame(result) || !all(required %in% names(result))) {
    .bb_stop(
      "`result` must be a guide-level result from `bb_screen()` carrying `pearson_null`."
    )
  }
  if (length(min_guides) != 1L || !is.finite(min_guides) || min_guides < 2) {
    .bb_stop("`min_guides` must be at least two.")
  }
  if (isTRUE(attr(result, "moderated")) ||
      "unmoderated_std_error" %in% names(result)) {
    .bb_stop(paste0(
      "`result` is already moderated; `bb_screen()` moderates by default. ",
      "Refit with `bb_screen(moderate = FALSE)` to moderate it differently."
    ))
  }

  usable <- is.finite(result$pearson_null) & result$pearson_null >= 0 &
    is.finite(result$std_error) & result$std_error > 0 &
    is.finite(result$estimate) & is.finite(result$df) & result$df > 0
  if ("converged" %in% names(result)) {
    usable <- usable & !is.na(result$converged) & result$converged
  }
  if (sum(usable) < as.integer(min_guides)) {
    .bb_stop(sprintf(
      "At least %d usable guide fits are required to moderate dispersion.",
      as.integer(min_guides)
    ))
  }
  df_residual <- unique(result$df[usable])
  if (length(df_residual) != 1L) {
    .bb_stop("Usable guides must share one residual degrees-of-freedom value.")
  }

  inflation <- pmax(result$pearson_null[usable] / df_residual, 1e-8)
  log_inflation <- log(inflation)

  if (isTRUE(trend) && "mean_cpm" %in% names(result)) {
    abundance <- log(pmax(result$mean_cpm[usable], .Machine$double.eps))
    ordering <- order(abundance)
    smooth <- stats::lowess(
      abundance[ordering], log_inflation[ordering], f = span
    )
    # Guides with identical abundance give tied smoother abscissae; average
    # them explicitly rather than letting approx() warn on every screen.
    trend_log <- stats::approx(
      smooth$x, smooth$y, xout = abundance, rule = 2, ties = mean
    )$y
  } else {
    trend_log <- rep(mean(log_inflation), length(log_inflation))
  }

  # Scaled-F moment estimator (Smyth 2004) on the log dispersion scale.
  residual_log <- log_inflation - trend_log
  centred <- residual_log - digamma(df_residual / 2) + log(df_residual / 2)
  n_guides <- length(centred)
  excess_variance <- n_guides / (n_guides - 1) *
    mean((centred - mean(centred))^2) - trigamma(df_residual / 2)
  if (excess_variance > 0) {
    prior_df <- 2 * .bb_trigamma_inverse(excess_variance)
    location <- mean(centred) + digamma(prior_df / 2) - log(prior_df / 2)
  } else {
    prior_df <- Inf
    location <- mean(centred)
  }
  prior_inflation <- exp(trend_log + location)

  prior_df_used <- min(prior_df, 1e6)
  moderated <- (df_residual * inflation + prior_df_used * prior_inflation) /
    (df_residual + prior_df_used)

  # `bb_screen()` already scaled the standard error by the fitted inflation,
  # which is truncated at one because `rho` cannot be negative.
  fitted_inflation <- pmax(1, inflation)
  if (isTRUE(one_way)) {
    # Raise a guide's variance toward the library when its own residuals look
    # implausibly quiet, but never lower it below what its own data support.
    # Shrinking a genuinely noisy guide down is what makes shared-dispersion
    # count models anti-conservative on screen data, and this screens that
    # failure mode out while keeping the correction that matters.
    moderated <- pmax(moderated, fitted_inflation)
  }
  df_total <- if (isTRUE(borrow_df)) {
    df_residual + prior_df_used
  } else {
    # Use the better variance estimate without also claiming the degrees of
    # freedom the prior would buy. The extra df is the part of moderation that
    # depends on the prior being exactly right.
    df_residual
  }
  rescale <- sqrt(moderated / fitted_inflation)

  moderated_result <- result
  moderated_result$unmoderated_std_error <- result$std_error
  moderated_result$unmoderated_t_value <- result$t_value
  moderated_result$unmoderated_df <- result$df
  moderated_result$unmoderated_p_value <- result$p_value
  moderated_result$variance_inflation <- NA_real_
  moderated_result$variance_inflation[usable] <- inflation
  moderated_result$moderated_inflation <- NA_real_
  moderated_result$moderated_inflation[usable] <- moderated

  moderated_result$std_error[!usable] <- NA_real_
  moderated_result$t_value[!usable] <- NA_real_
  moderated_result$df[!usable] <- NA_real_
  moderated_result$p_value[!usable] <- NA_real_
  moderated_result$std_error[usable] <- result$std_error[usable] * rescale
  moderated_result$t_value[usable] <- result$estimate[usable] /
    moderated_result$std_error[usable]
  moderated_result$df[usable] <- df_total
  moderated_result$p_value[usable] <- 2 * stats::pt(
    -abs(moderated_result$t_value[usable]), df = df_total
  )
  moderated_result$fdr <- stats::p.adjust(
    moderated_result$p_value, method = "BH"
  )
  attr(moderated_result, "prior_df") <- prior_df
  attr(moderated_result, "df_total") <- df_total
  moderated_result
}
