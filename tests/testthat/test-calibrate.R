test_that("control calibration restores the nominal null rejection rate", {
  # 100 controls drawn from a t reference inflated by 1.8, plus one real hit.
  control_t <- 1.8 * qt((seq_len(100) - 0.5) / 100, df = 8)
  result <- data.frame(
    estimate = rep(1, 101),
    std_error = rep(1, 101),
    t_value = c(control_t, 5),
    df = rep(8, 101),
    p_value = 2 * pt(-abs(c(control_t, 5)), df = 8)
  )
  result$fdr <- p.adjust(result$p_value, method = "BH")

  calibrated <- bb_calibrate_controls(result, c(rep(TRUE, 100), FALSE))

  expect_gt(attr(calibrated, "control_scale"), 1)
  expect_identical(calibrated$raw_t_value, result$t_value)
  expect_identical(calibrated$raw_p_value, result$p_value)
  expect_true(all(calibrated$p_value >= result$p_value))
  # An absolute band: the realised control rejection rate must land near the
  # nominal 5%, not merely within 2% relative of it.
  expect_lte(
    abs(mean(calibrated$p_value[seq_len(100)] < 0.05) - 0.05), 0.02
  )
})

test_that("the qq-slope estimator recovers a known inflated null scale", {
  set.seed(4242)
  n <- 600L
  truth <- 1.4
  result <- data.frame(
    estimate = rnorm(n),
    std_error = 1,
    df = 12,
    rho = 0
  )
  result$t_value <- truth * rt(n, df = 12)
  result$p_value <- 2 * pt(-abs(result$t_value), 12)
  result$fdr <- p.adjust(result$p_value, method = "BH")

  calibrated <- bb_calibrate_controls(
    result, rep(TRUE, n), method = "qq_slope"
  )
  expect_equal(attr(calibrated, "control_scale"), truth, tolerance = 0.12)

  # The floor at one still applies to an already well-calibrated null.
  well_calibrated <- bb_calibrate_controls(
    transform(result, t_value = rt(n, df = 12)),
    rep(TRUE, n), method = "qq_slope"
  )
  expect_gte(attr(well_calibrated, "control_scale"), 1)
})

test_that("bb_calibrate_controls validates its arguments", {
  result <- data.frame(
    estimate = 1, std_error = 1, t_value = 1, df = 8,
    p_value = 0.3, fdr = 0.3
  )

  expect_error(
    bb_calibrate_controls(data.frame(a = 1), TRUE),
    "guide-level result"
  )
  expect_error(
    bb_calibrate_controls(result, c(TRUE, FALSE)),
    "one per guide"
  )
  expect_error(
    bb_calibrate_controls(result, TRUE, alpha = 0.9),
    "between 0 and 0.5"
  )
  expect_error(
    bb_calibrate_controls(result, TRUE),
    "finite negative-control statistics are required"
  )

  mixed_df <- result[rep(1L, 30L), ]
  mixed_df$df <- rep(c(8, 9), 15)
  expect_error(
    bb_calibrate_controls(mixed_df, rep(TRUE, 30L)),
    "share one positive `df`"
  )
})

test_that("trigamma inversion inverts trigamma", {
  expect_equal(trigamma(.bb_trigamma_inverse(0.4)), 0.4, tolerance = 1e-8)
  expect_equal(trigamma(.bb_trigamma_inverse(2.5)), 2.5, tolerance = 1e-8)
  expect_true(is.infinite(.bb_trigamma_inverse(-1)))
  expect_true(is.infinite(.bb_trigamma_inverse(0)))
})

test_that("conservative moderation never sharpens a guide test", {
  input <- fixture_moderation()
  df_residual <- unique(input$df)
  moderated <- bb_moderate_dispersion(
    input, trend = FALSE, one_way = TRUE, borrow_df = FALSE
  )
  own_inflation <- input$pearson_null / df_residual
  fitted_inflation <- pmax(1, own_inflation)

  # Only the variance changes; the estimates are untouched.
  expect_identical(moderated$estimate, input$estimate)
  expect_identical(moderated$unmoderated_p_value, input$p_value)
  # Shrinkage reduces the spread of the inflation estimates.
  expect_lt(sd(moderated$moderated_inflation), sd(own_inflation))
  expect_gt(attr(moderated, "prior_df"), 0)
  # With both guards on, the reference df is unchanged and no guide's
  # variance is lowered, so no p-value can shrink.
  expect_true(all(moderated$df == df_residual))
  expect_true(all(moderated$moderated_inflation >= fitted_inflation - 1e-9))
  expect_true(all(moderated$std_error >= input$std_error - 1e-9))
  expect_true(all(moderated$p_value >= input$p_value - 1e-9))
})

test_that("default moderation borrows df and concentrates on the truth", {
  input <- fixture_moderation()
  df_residual <- unique(input$df)
  true_inflation <- 2
  conservative <- bb_moderate_dispersion(
    input, trend = FALSE, one_way = TRUE, borrow_df = FALSE
  )
  moderated <- bb_moderate_dispersion(input, trend = FALSE)

  expect_length(unique(moderated$df), 1L)
  expect_gt(unique(moderated$df), df_residual)
  expect_lt(
    sd(moderated$moderated_inflation),
    sd(conservative$moderated_inflation)
  )
  expect_equal(
    median(moderated$moderated_inflation), true_inflation, tolerance = 0.25
  )
})

test_that("abundance-trend moderation runs and keeps the retained columns", {
  input <- fixture_moderation()
  moderated <- bb_moderate_dispersion(input, trend = TRUE)

  expect_true(all(
    c("unmoderated_std_error", "unmoderated_t_value", "unmoderated_df",
      "unmoderated_p_value", "variance_inflation", "moderated_inflation") %in%
      names(moderated)
  ))
  expect_identical(moderated$unmoderated_df, input$df)
  expect_true(all(is.finite(moderated$moderated_inflation)))
})

test_that("bb_moderate_dispersion validates its arguments", {
  input <- fixture_moderation()

  expect_error(
    bb_moderate_dispersion(input[, setdiff(names(input), "pearson_null")]),
    "carrying `pearson_null`"
  )
  expect_error(
    bb_moderate_dispersion(input[1:10, ]),
    "usable guide fits are required"
  )
  mixed <- input
  mixed$df <- rep(c(7L, 8L), length.out = nrow(mixed))
  expect_error(
    bb_moderate_dispersion(mixed, trend = FALSE),
    "share one residual degrees-of-freedom value"
  )
})
