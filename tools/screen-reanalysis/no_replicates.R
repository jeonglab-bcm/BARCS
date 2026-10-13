# Guide-level fit for analyses with no residual degrees of freedom, such as
# one library per condition. Sourced by run_barcs.R.
#
# bb_screen() estimates each guide's overdispersion rho from its own
# replicates, so it refuses a saturated design. Here rho is pooled instead:
# under the intercept-only model every guide gives (libraries - 1) residual
# degrees of freedom, and rho is the single value at which the squared
# Pearson residuals of the reference guides add up to those degrees of
# freedom (the BARCS estimating equation, summed over guides). The reference
# guides are the non-targeting controls when at least 50 are usable, because
# they carry no condition effect; otherwise every guide is used, which treats
# real effects as noise and so overstates rho (conservative). Library totals
# for this step come from the controls when available, so a library-wide
# shift of the targeting guides does not count as noise.
#
# With rho fixed, the saturated beta-binomial fit is closed-form: each
# library's fitted proportion is its observed proportion (Haldane +0.5 for a
# guide with a zero count), the coefficients solve X beta = logit(mu), and the
# covariance is (X' W X)^-1 with the BARCS working weights. Because rho is
# pooled over many guides, the Wald statistic is referred to the normal
# distribution (reported as df = 1e6, as bb_screen() does for an infinite
# prior). The guide correlation is not estimable without replicates and is
# set to 0. Control-guide calibration and the empirical null in run_barcs.R
# apply unchanged and are the safeguard for both approximations.

pooled_rho <- function(counts, totals, use) {
  counts <- counts[use, , drop = FALSE]
  mu <- rowSums(counts) / sum(totals)
  keep <- mu > 0 & mu < 1
  counts <- counts[keep, , drop = FALSE]
  mu <- mu[keep]
  expected <- outer(mu, totals)
  binomial <- outer(mu * (1 - mu), totals)
  target <- nrow(counts) * (ncol(counts) - 1L)
  excess <- function(rho) {
    inflate <- matrix(1 + (totals - 1) * rho, nrow(counts), ncol(counts), byrow = TRUE)
    sum((counts - expected)^2 / (binomial * inflate)) - target
  }
  if (excess(0) <= 0) return(list(rho = 0, inflation = (excess(0) + target) / target, guides = nrow(counts)))
  upper <- 1e-6
  while (excess(upper) > 0 && upper < 0.5) upper <- upper * 10
  rho <- stats::uniroot(excess, c(0, upper), tol = 1e-14)$root
  list(rho = rho, inflation = (excess(0) + target) / target, guides = nrow(counts))
}

fit_no_replicates <- function(counts, data, formula, term, totals, guide, gene,
                              control, min_total_count) {
  x <- stats::model.matrix(formula, data)
  if (ncol(x) != nrow(x)) stop("fit_no_replicates() expects a saturated design.", call. = FALSE)
  term_index <- match(term, colnames(x))
  if (is.na(term_index)) stop("Coefficient ", term, " is not in the design.", call. = FALSE)
  usable <- rowSums(counts) >= min_total_count
  reference <- usable & control
  rho_totals <- totals
  if (sum(reference) >= 50L) {
    rho_totals <- barcs_control_totals(counts, control)
    source <- "control guides"
  } else {
    reference <- usable
    source <- "all guides (no or too few controls; conservative)"
  }
  pooled <- pooled_rho(counts, rho_totals, reference)
  rho <- pooled$rho
  message(sprintf("   no replicates: rho = %.3g pooled from %d %s (inflation %.2f at rho = 0)",
                  rho, pooled$guides, source, pooled$inflation))

  k <- counts[usable, , drop = FALSE]
  haldane <- rowSums(k == 0) > 0
  k[haldane, ] <- k[haldane, ] + 0.5
  n <- matrix(totals, nrow(k), ncol(k), byrow = TRUE)
  n[haldane, ] <- n[haldane, ] + 1
  mu <- k / n
  eta <- log(mu / (1 - mu))
  x_inverse <- solve(x)
  beta <- eta %*% t(x_inverse)
  weight <- n * mu * (1 - mu) / (1 + (n - 1) * rho)
  # Var(beta) = (X' W X)^-1 = X^-1 W^-1 X^-T for a square X.
  row_term <- x_inverse[term_index, ]
  variance <- as.vector((1 / weight) %*% (row_term^2))
  estimate <- beta[, term_index]
  std_error <- sqrt(variance)
  t_value <- estimate / std_error
  p_value <- 2 * stats::pnorm(-abs(t_value))

  # One row per input guide, as bb_screen() returns; filtered guides are NA.
  fill <- function(v) { out <- rep(NA_real_, length(usable)); out[usable] <- v; out }
  result <- data.frame(
    gene = gene, guide = guide,
    estimate = fill(estimate), std_error = fill(std_error), t_value = fill(t_value),
    df = 1e6, p_value = fill(p_value), rho = rho,
    mean_cpm = rowMeans(sweep(counts, 2L, totals, "/")) * 1e6,
    converged = usable, stringsAsFactors = FALSE
  )
  result$fdr <- stats::p.adjust(result$p_value, method = "BH")
  rownames(result) <- NULL
  attr(result, "moderated") <- FALSE
  attr(result, "prior_df") <- NA_real_
  attr(result, "test") <- "wald"
  attr(result, "guide_correlation") <- 0
  attr(result, "no_replicates") <- list(rho = rho, rho_source = source,
                                        rho_guides = pooled$guides,
                                        inflation_at_rho0 = pooled$inflation,
                                        haldane_guides = sum(haldane))
  result
}
