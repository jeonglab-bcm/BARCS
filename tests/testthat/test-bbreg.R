test_that("equal library sizes reproduce the binomial GLM coefficients", {
  fixture <- fixture_equal_libraries()
  fit <- bbreg(fixture$count, fixture$total, ~ dose + batch, fixture$data)
  reference <- glm(
    cbind(fixture$count, fixture$total - fixture$count) ~ dose + batch,
    family = binomial(),
    data = fixture$data
  )

  # With equal library sizes the beta-binomial weights differ from the
  # binomial weights by a common multiplier, so the point estimates must
  # agree even though the standard errors need not.
  expect_equal(coef(fit), coef(reference), tolerance = 1e-5)
  expect_s3_class(fit, "bbreg")
  expect_true(fit$converged)
  expect_identical(
    fit$df.residual,
    nrow(fixture$data) - length(coef(fit))
  )
  expect_true(fit$rho >= 0 && fit$rho < 1)
  expect_true(all(fitted(fit) > 0 & fitted(fit) < 1))
})

test_that("a genuinely overdispersed guide widens the standard error", {
  fixture <- fixture_equal_libraries()
  count <- fixture_overdispersed(fixture$mu, fixture$total)
  fit <- bbreg(count, fixture$total, ~ dose + batch, fixture$data)
  reference <- glm(
    cbind(count, fixture$total - count) ~ dose + batch,
    family = binomial(),
    data = fixture$data
  )

  expect_gt(fit$rho, 0)
  expect_gt(
    fit$coefficient_table["dose", "std_error"],
    summary(reference)$coefficients["dose", "Std. Error"]
  )
})

test_that("a three-sample screen with one residual df is still estimable", {
  # A one-replicate low/bulk/high screen has three observations and two
  # coefficients. It is a diagnostic and ranking case rather than a
  # confirmatory design, but it must not fail outright.
  data <- data.frame(phenotype_z = c(-1.271, 0, 1.271))
  fit <- bbreg(c(70, 100, 145), rep(50000, 3L), ~phenotype_z, data)

  expect_true(fit$converged)
  expect_identical(fit$df.residual, 1L)
  expect_true(is.finite(coef(fit)[["phenotype_z"]]))
  expect_true(
    is.finite(fit$coefficient_table["phenotype_z", "p_value"])
  )
})

test_that("bb_contrast reproduces a single-coefficient test", {
  fixture <- fixture_equal_libraries()
  fit <- bbreg(fixture$count, fixture$total, ~ dose + batch, fixture$data)
  contrast <- bb_contrast(fit, c(dose = 1))

  expect_equal(contrast$estimate, coef(fit)[["dose"]], ignore_attr = TRUE)
  expect_equal(
    contrast$p_value,
    fit$coefficient_table["dose", "p_value"],
    ignore_attr = TRUE
  )
  expect_identical(contrast$df, fit$df.residual)
})

test_that("bb_contrast rejects malformed contrasts", {
  fixture <- fixture_equal_libraries()
  fit <- bbreg(fixture$count, fixture$total, ~ dose + batch, fixture$data)

  expect_error(bb_contrast(fit, c(nonexistent = 1)), "unknown coefficient")
  expect_error(bb_contrast(fit, c(1, 2)), "one value per coefficient")
  expect_error(bb_contrast(fit, c(1, NA, 0)), "without missing values")
  expect_error(bb_contrast(list(), 1), "fitted `bbreg` object")
})

test_that("a shifted null moves the contrast statistic but not the estimate", {
  fixture <- fixture_equal_libraries()
  fit <- bbreg(fixture$count, fixture$total, ~ dose + batch, fixture$data)
  at_zero <- bb_contrast(fit, c(dose = 1))
  at_truth <- bb_contrast(fit, c(dose = 1), null = at_zero$estimate)

  expect_equal(at_truth$estimate, at_zero$estimate)
  expect_equal(at_truth$t_value, 0)
  expect_equal(at_truth$p_value, 1)
})

test_that("invalid responses and designs fail loudly", {
  fixture <- fixture_equal_libraries()

  # A count larger than its own library total.
  expect_error(
    bbreg(c(2, 3), c(1, 4), ~1, data.frame(x = 1:2)),
    "0 <= `count` <= `total`"
  )
  # An aliased covariate leaves the design rank deficient.
  expect_error(
    bbreg(
      fixture$count, fixture$total, ~ dose + duplicate,
      transform(fixture$data, duplicate = dose)
    ),
    "not full rank"
  )
  expect_error(
    bbreg(c(1.5, 2), c(10, 10), ~1, data.frame(x = 1:2)),
    "integer-valued"
  )
  expect_error(
    bbreg(c(1, 2), c(10, 10), y ~ x, data.frame(x = 1:2, y = 1:2)),
    "one-sided formula"
  )
  # Two observations cannot support two coefficients.
  expect_error(
    bbreg(c(1, 2), c(10, 10), ~x, data.frame(x = c(0, 1))),
    "more observations than fitted coefficients"
  )
})

test_that("the S3 methods expose the fit consistently", {
  fixture <- fixture_equal_libraries()
  fit <- bbreg(fixture$count, fixture$total, ~ dose + batch, fixture$data)

  expect_named(coef(fit), colnames(fit$design))
  expect_identical(dim(vcov(fit)), c(3L, 3L))
  expect_equal(sqrt(diag(vcov(fit))), fit$coefficient_table[, "std_error"],
               ignore_attr = TRUE)
  expect_equal(
    residuals(fit, type = "response"),
    fixture$count / fixture$total - fitted(fit)
  )
  # Pearson residuals are standardised, so they are on a much smaller scale.
  expect_lt(
    max(abs(residuals(fit, type = "pearson"))),
    max(abs(residuals(fit, type = "response"))) * 1e6
  )
  expect_s3_class(summary(fit), "summary.bbreg")
  expect_output(print(summary(fit)), "Coefficients:")
  expect_output(print(summary(fit)), "intraclass correlation")
})

test_that("the compiled and R weighted-least-squares paths agree", {
  set.seed(11)
  x <- cbind(1, rnorm(20), rnorm(20))
  weight <- runif(20, 0.5, 2)
  response <- rnorm(20)

  compiled <- bb_wls_solve_cpp(x, weight, response, TRUE)
  information <- crossprod(x, weight * x)
  expected <- drop(solve(information, crossprod(x, weight * response)))

  expect_equal(drop(compiled$coefficient), expected)
  expect_equal(compiled$covariance, chol2inv(chol(information)))

  system <- bb_wls_system_cpp(x, weight, response)
  expect_equal(system$information, information)
  expect_equal(drop(system$score_target), drop(crossprod(x, weight * response)))
})
