# Beta-binomial regression with t-based coefficient tests.
#
# This file holds the single-guide model: input validation, the weighted
# least-squares and dispersion helpers, the `bbreg()` fit itself, its S3
# methods, and contrast testing. Screen-wide application lives in `screen.R`,
# recalibration in `calibrate.R`, and gene summaries in `gene.R`.
#
# The mean model is
#
#   logit(mu_i) = x_i' beta
#
# fitted under the beta-binomial variance
#
#   Var(K_i) = n_i mu_i (1 - mu_i) {1 + (n_i - 1) rho}.
#
# Coefficients come from feasible IRLS, rho is estimated from the Pearson
# estimating equation, and coefficient tests use a Student t reference with
# residual degrees of freedom.


# ---- Input and design validation -------------------------------------------

.bb_stop <- function(message) {
  stop(message, call. = FALSE)
}

.bb_validate_response <- function(count, total) {
  if (!is.numeric(count) || !is.numeric(total)) {
    .bb_stop("`count` and `total` must be numeric.")
  }
  if (length(count) != length(total) || length(count) < 2L) {
    .bb_stop("`count` and `total` must have the same length (at least two).")
  }
  if (anyNA(count) || anyNA(total) ||
      any(!is.finite(count)) || any(!is.finite(total))) {
    .bb_stop("`count` and `total` cannot contain missing or non-finite values.")
  }
  if (any(total <= 0) || any(count < 0) || any(count > total)) {
    .bb_stop("Each observation must satisfy 0 <= `count` <= `total`, with `total` > 0.")
  }
  integer_like <- function(x) all(abs(x - round(x)) < sqrt(.Machine$double.eps))
  if (!integer_like(count) || !integer_like(total)) {
    .bb_stop("`count` and `total` must contain integer-valued counts.")
  }
  invisible(TRUE)
}

.bb_make_design <- function(formula, data, n) {
  if (!inherits(formula, "formula") || length(formula) != 2L) {
    .bb_stop("`formula` must be a one-sided formula, for example `~ dose + batch`.")
  }
  if (!is.data.frame(data) || nrow(data) != n) {
    .bb_stop("`data` must be a data frame with one row per observation.")
  }
  mf <- model.frame(formula, data = data, na.action = na.fail)
  x <- model.matrix(formula, data = mf)
  qr_x <- qr(x)
  if (qr_x$rank < ncol(x)) {
    .bb_stop("The design matrix is not full rank; remove aliased covariates.")
  }
  if (nrow(x) <= ncol(x)) {
    .bb_stop("The model needs more observations than fitted coefficients.")
  }
  list(x = x, terms = terms(mf), contrasts = attr(x, "contrasts"))
}


# ---- Weighted least-squares and dispersion helpers -------------------------

.bb_inverse <- function(a) {
  chol2inv(chol(a))
}

.bb_wls_system <- function(x, weight, response) {
  if (exists("bb_wls_system_cpp", mode = "function", inherits = TRUE)) {
    return(bb_wls_system_cpp(x, weight, response))
  }
  list(
    information = crossprod(x, weight * x),
    score_target = crossprod(x, weight * response)
  )
}

.bb_wls_solve <- function(x, weight, response, covariance = FALSE) {
  if (exists("bb_wls_solve_cpp", mode = "function", inherits = TRUE)) {
    result <- bb_wls_solve_cpp(x, weight, response, covariance)
    result$coefficient <- drop(result$coefficient)
    return(result)
  }
  system <- .bb_wls_system(x, weight, response)
  coefficient <- drop(solve(system$information, system$score_target))
  if (!covariance) {
    return(list(coefficient = coefficient))
  }
  list(
    coefficient = coefficient,
    covariance = .bb_inverse(system$information)
  )
}

.bb_estimate_rho <- function(count, total, mu, df_residual,
                             upper = 1 - 1e-8) {
  binomial_variance <- total * mu * (1 - mu)
  pearson <- function(rho) {
    sum((count - total * mu)^2 /
          (binomial_variance * (1 + (total - 1) * rho)))
  }
  q0 <- pearson(0)
  # `pearson_null` is the Pearson chi-square under the binomial model. Unlike
  # `rho` it is not truncated at the lower boundary, so `pearson_null /
  # df_residual` is an unconstrained estimate of the guide's variance
  # inflation and is the quantity `bb_moderate_dispersion()` shrinks.
  if (!is.finite(q0)) {
    return(list(rho = 0, scale = 1, pearson = q0, pearson_null = q0,
                boundary = TRUE))
  }
  if (q0 <= df_residual) {
    return(list(rho = 0, scale = 1, pearson = q0, pearson_null = q0,
                boundary = FALSE))
  }
  qu <- pearson(upper)
  if (qu >= df_residual) {
    return(list(
      rho = upper,
      scale = max(1, qu / df_residual),
      pearson = qu,
      pearson_null = q0,
      boundary = TRUE
    ))
  }
  rho <- uniroot(
    function(r) pearson(r) - df_residual,
    interval = c(0, upper),
    tol = 1e-10
  )$root
  list(rho = rho, scale = 1, pearson = pearson(rho), pearson_null = q0,
       boundary = FALSE)
}


# ---- Single-guide regression -----------------------------------------------

#' Fit beta-binomial regression for one guide
#'
#' Fits the logit mean model `logit(mu) = x'beta` to one guide's counts by
#' feasible iteratively reweighted least squares, under the beta-binomial
#' variance `n mu (1 - mu) {1 + (n - 1) rho}`. The intraclass correlation
#' `rho` is estimated from the Pearson estimating equation at each iteration,
#' and coefficients are tested against a Student t reference on residual
#' degrees of freedom.
#'
#' The degrees of freedom come from the number of independent sequenced
#' libraries minus the rank of the design, never from read depth. Sequencing
#' a library more deeply shrinks the binomial part of the variance but buys no
#' additional degrees of freedom.
#'
#' @param count Guide counts, one value per sample.
#' @param total Total library counts, one value per sample. These are the
#'   unfiltered mapped-guide totals and must not be recomputed after guide
#'   filtering.
#' @param formula One-sided mean-model formula, such as `~ dose + batch`.
#' @param data Sample-level covariates, one row per element of `count`, in the
#'   same order.
#' @param maxit Maximum feasible-IRLS iterations.
#' @param tolerance Relative convergence tolerance.
#' @param mu_bound Numerical bound applied to fitted proportions.
#'
#' @return An object of class `bbreg`: a list whose most useful elements are
#'   `coefficients`, `coefficient_table` (estimate, standard error, t value,
#'   degrees of freedom, p-value), `covariance`, `rho`, `df.residual`, and
#'   `converged`. Methods are provided for [coef()], [vcov()], [fitted()],
#'   [residuals()], and [summary()].
#'
#' @seealso [bb_contrast()] to test a linear combination of coefficients, and
#'   [bb_screen()] to apply this fit across a whole count matrix.
#' @family guide-level modelling
#' @export
#' @examples
#' set.seed(1)
#' design <- data.frame(
#'   dose = rep(c(0, 0.5, 1), each = 4),
#'   batch = factor(rep(c("a", "b"), 6))
#' )
#' total <- rep(50000L, nrow(design))
#' mu <- plogis(-6.5 + 1.1 * design$dose)
#' count <- rbinom(nrow(design), total, mu)
#'
#' fit <- bbreg(count, total, ~ dose + batch, design)
#' summary(fit)
#' coef(fit)
bbreg <- function(count, total, formula, data, maxit = 100L,
                  tolerance = 1e-8, mu_bound = 1e-8) {
  .bb_validate_response(count, total)
  count <- as.numeric(count)
  total <- as.numeric(total)
  design <- .bb_make_design(formula, data, length(count))
  x <- design$x
  rank <- ncol(x)
  df_residual <- nrow(x) - rank

  initial <- suppressWarnings(glm.fit(
    x = x,
    y = count / total,
    weights = total,
    family = binomial(link = "logit"),
    control = glm.control(maxit = 50L, epsilon = tolerance)
  ))
  beta <- initial$coefficients
  if (any(!is.finite(beta))) {
    pooled <- (sum(count) + 0.5) / (sum(total) + 1)
    beta <- numeric(rank)
    beta[1L] <- qlogis(pooled)
  }

  converged <- FALSE
  rho_fit <- list(rho = 0, scale = 1, pearson = NA_real_,
                  boundary = FALSE)
  for (iteration in seq_len(maxit)) {
    eta <- drop(x %*% beta)
    mu <- pmin(pmax(plogis(eta), mu_bound), 1 - mu_bound)
    rho_fit <- .bb_estimate_rho(count, total, mu, df_residual)
    rho <- rho_fit$rho

    working_response <- eta + (count / total - mu) / (mu * (1 - mu))
    working_weight <- total * mu * (1 - mu) /
      (1 + (total - 1) * rho)
    beta_new <- tryCatch(
      .bb_wls_solve(
        x, working_weight, working_response, covariance = FALSE
      )$coefficient,
      error = function(e) rep(NA_real_, rank)
    )
    if (any(!is.finite(beta_new))) {
      .bb_stop("The IRLS update was singular; inspect sparse counts and the design.")
    }

    change <- max(abs(beta_new - beta) / pmax(1, abs(beta)))
    beta <- beta_new
    if (change < tolerance) {
      converged <- TRUE
      break
    }
  }

  eta <- drop(x %*% beta)
  mu <- pmin(pmax(plogis(eta), mu_bound), 1 - mu_bound)
  rho_fit <- .bb_estimate_rho(count, total, mu, df_residual)
  rho <- rho_fit$rho
  working_weight <- total * mu * (1 - mu) /
    (1 + (total - 1) * rho)
  final_wls <- .bb_wls_solve(
    x, working_weight, eta, covariance = TRUE
  )
  unscaled_covariance <- final_wls$covariance
  covariance <- rho_fit$scale * unscaled_covariance
  standard_error <- sqrt(diag(covariance))
  statistic <- beta / standard_error
  p_value <- 2 * pt(-abs(statistic), df = df_residual)
  coefficient_table <- cbind(
    estimate = beta,
    std_error = standard_error,
    t_value = statistic,
    df = rep(df_residual, rank),
    p_value = p_value
  )
  rownames(coefficient_table) <- colnames(x)

  structure(list(
    coefficients = setNames(beta, colnames(x)),
    coefficient_table = coefficient_table,
    covariance = covariance,
    fitted.values = mu,
    linear.predictors = eta,
    residuals = count / total - mu,
    pearson = rho_fit$pearson,
    pearson_null = rho_fit$pearson_null,
    rho = rho,
    scale = rho_fit$scale,
    dispersion_boundary = rho_fit$boundary,
    df.residual = df_residual,
    rank = rank,
    count = count,
    total = total,
    formula = formula,
    data = data,
    design = x,
    weights = working_weight,
    converged = converged,
    iterations = iteration,
    call = match.call()
  ), class = "bbreg")
}


# ---- S3 methods ------------------------------------------------------------

#' Methods for fitted beta-binomial regressions
#'
#' Standard extractors for objects returned by [bbreg()].
#'
#' @param object,x A fitted `bbreg` object (`x` for `print.summary.bbreg()`,
#'   which takes the object returned by `summary()`).
#' @param type Residual scale: `"response"` returns the observed minus fitted
#'   proportion, `"pearson"` divides it by the fitted beta-binomial standard
#'   deviation.
#' @param digits Number of significant digits used when printing.
#' @param ... Ignored, present for S3 consistency.
#'
#' @return `coef()` a named coefficient vector; `vcov()` the coefficient
#'   covariance matrix; `fitted()` the fitted proportions; `residuals()` a
#'   residual vector; `summary()` an object of class `summary.bbreg`; and
#'   `print()` its argument, invisibly.
#'
#' @name bbreg-methods
#' @family guide-level modelling
#' @examples
#' set.seed(2)
#' design <- data.frame(dose = rep(c(0, 1), each = 5))
#' total <- rep(20000L, 10)
#' count <- rbinom(10, total, plogis(-6 + 0.8 * design$dose))
#' fit <- bbreg(count, total, ~ dose, design)
#'
#' coef(fit)
#' vcov(fit)
#' head(residuals(fit, type = "pearson"))
#' summary(fit)
NULL

#' @rdname bbreg-methods
#' @export
coef.bbreg <- function(object, ...) {
  object$coefficients
}

#' @rdname bbreg-methods
#' @export
vcov.bbreg <- function(object, ...) {
  object$covariance
}

#' @rdname bbreg-methods
#' @export
fitted.bbreg <- function(object, ...) {
  object$fitted.values
}

#' @rdname bbreg-methods
#' @export
residuals.bbreg <- function(object, type = c("response", "pearson"), ...) {
  type <- match.arg(type)
  if (type == "response") {
    return(object$residuals)
  }
  variance <- object$fitted.values * (1 - object$fitted.values) *
    (1 + (object$total - 1) * object$rho) / object$total
  object$residuals / sqrt(variance)
}

#' @rdname bbreg-methods
#' @export
summary.bbreg <- function(object, ...) {
  ans <- list(
    call = object$call,
    coefficients = object$coefficient_table,
    rho = object$rho,
    pearson = object$pearson,
    df.residual = object$df.residual,
    converged = object$converged,
    iterations = object$iterations
  )
  class(ans) <- "summary.bbreg"
  ans
}

#' @rdname bbreg-methods
#' @export
print.summary.bbreg <- function(x, digits = max(3L, getOption("digits") - 3L),
                                ...) {
  cat("Call:\n")
  print(x$call)
  cat("\nCoefficients:\n")
  printCoefmat(x$coefficients, digits = digits, P.values = TRUE,
               has.Pvalue = TRUE)
  cat("\nBeta-binomial intraclass correlation (rho):",
      formatC(x$rho, digits = digits), "\n")
  cat("Pearson statistic / residual df:",
      formatC(x$pearson, digits = digits), "/",
      x$df.residual, "\n")
  cat("Converged:", x$converged, "after", x$iterations, "iterations\n")
  invisible(x)
}


# ---- Contrasts -------------------------------------------------------------

#' Test a linear contrast of beta-binomial regression coefficients
#'
#' Forms `c'beta` for a user-supplied contrast vector, takes its standard
#' error from the fitted coefficient covariance, and tests it against the same
#' Student t reference [bbreg()] uses for individual coefficients.
#'
#' @param object A fitted `bbreg` object.
#' @param contrast Numeric contrast vector in coefficient order, or a named
#'   numeric vector whose names identify coefficients. Unnamed coefficients in
#'   a named contrast are given weight zero.
#' @param null Null value for the contrast.
#'
#' @return A one-row data frame with columns `estimate`, `std_error`,
#'   `t_value`, `df`, and `p_value`.
#'
#' @family guide-level modelling
#' @export
#' @examples
#' set.seed(3)
#' design <- data.frame(arm = factor(rep(c("ctrl", "low", "high"), each = 4)))
#' total <- rep(30000L, 12)
#' count <- rbinom(12, total, plogis(-6.5 + c(0, 0.4, 0.9)[design$arm]))
#' fit <- bbreg(count, total, ~ arm, design)
#'
#' # High versus low, given the model's treatment contrasts.
#' bb_contrast(fit, c(armlow = -1, armhigh = 1))
bb_contrast <- function(object, contrast, null = 0) {
  if (!inherits(object, "bbreg")) {
    .bb_stop("`object` must be a fitted `bbreg` object.")
  }
  p <- length(object$coefficients)
  if (!is.numeric(contrast) || anyNA(contrast)) {
    .bb_stop("`contrast` must be a numeric vector without missing values.")
  }
  if (!is.null(names(contrast))) {
    if (!all(names(contrast) %in% names(object$coefficients))) {
      .bb_stop("A named contrast contains an unknown coefficient.")
    }
    complete <- setNames(numeric(p), names(object$coefficients))
    complete[names(contrast)] <- contrast
    contrast <- complete
  }
  if (length(contrast) != p) {
    .bb_stop("An unnamed contrast must have one value per coefficient.")
  }
  estimate <- drop(crossprod(contrast, object$coefficients))
  standard_error <- sqrt(drop(t(contrast) %*% object$covariance %*% contrast))
  statistic <- (estimate - null) / standard_error
  data.frame(
    estimate = estimate,
    std_error = standard_error,
    t_value = statistic,
    df = object$df.residual,
    p_value = 2 * pt(-abs(statistic), df = object$df.residual),
    row.names = NULL
  )
}
