test_that("guide-consistency pooling separates signal from null", {
  set.seed(406)
  input <- data.frame(
    gene = rep(c("control_a", "control_b", "null", "signal"), each = 5),
    estimate = c(
      rnorm(5, 0, 0.10),
      rnorm(5, 0, 0.10),
      rnorm(5, 0, 0.10),
      rnorm(5, 0.65, 0.08)
    ),
    std_error = rep(0.10, 20),
    converged = TRUE
  )
  control <- input$gene %in% c("control_a", "control_b")
  consistency <- bb_gene_consistency(
    input, control = control, min_control_genes = 2
  )

  expect_identical(nrow(consistency), 4L)
  expect_true(all(
    c("std_error", "raw_statistic", "statistic",
      "guide_direction_agreement", "control_gene", "p_value", "fdr") %in%
      names(consistency)
  ))
  expect_gte(attr(consistency, "null_scale"), 1)
  expect_identical(attr(consistency, "control_genes"), 2L)
  expect_lt(
    consistency$p_value[consistency$gene == "signal"],
    consistency$p_value[consistency$gene == "null"]
  )
  expect_equal(
    consistency$guide_direction_agreement[consistency$gene == "signal"], 1
  )
})

test_that("gene consistency prefers the retained pre-calibration errors", {
  set.seed(406)
  input <- data.frame(
    gene = rep(c("control_a", "control_b", "null", "signal"), each = 5),
    estimate = c(
      rnorm(5, 0, 0.10), rnorm(5, 0, 0.10),
      rnorm(5, 0, 0.10), rnorm(5, 0.65, 0.08)
    ),
    std_error = rep(0.10, 20),
    converged = TRUE
  )
  control <- input$gene %in% c("control_a", "control_b")
  baseline <- bb_gene_consistency(
    input, control = control, min_control_genes = 2
  )

  # Mimic a table that `bb_calibrate_controls()` has already widened: the
  # `raw_std_error` column must win, or the gene statistic would be penalised
  # twice for the same inflation.
  calibrated_input <- input
  calibrated_input$raw_std_error <- input$std_error
  calibrated_input$std_error <- input$std_error * 3
  calibrated <- bb_gene_consistency(
    calibrated_input, control = control, min_control_genes = 2
  )

  expect_equal(calibrated$raw_statistic, baseline$raw_statistic)
})

test_that("a gene may not mix control and non-control guides", {
  input <- barcs_example_guides()
  half_control <- rep(FALSE, nrow(input))
  half_control[input$gene == "control_a"][1:2] <- TRUE

  expect_error(
    bb_gene_consistency(input, control = half_control),
    "cannot mix control and non-control guides"
  )
  expect_error(
    bb_gene_partial_pool(input, control = half_control),
    "cannot mix control and non-control guides"
  )
})

test_that("the original signed-z aggregation is unchanged", {
  input <- barcs_example_guides()
  original <- bb_gene_original(input)
  consistent <- input$gene == "consistent"

  # The historical statistic converts each two-sided guide p-value back to a
  # signed normal deviate and averages, scaled by sqrt(m).
  signed_z <- sign(input$estimate[consistent]) *
    qnorm(input$p_value[consistent] / 2, lower.tail = FALSE)
  expected <- sum(signed_z) / sqrt(sum(consistent))

  expect_equal(
    original$statistic[original$gene == "consistent"], expected,
    tolerance = 1e-6
  )
  expect_true(all(original$method == "original"))
  expect_true(all(original$fdr >= original$p_value))
})

test_that("signed-z reduces to summed Wald statistics under a normal null", {
  # When the guide p-values come from a normal reference rather than a t one,
  # qnorm inverts them exactly and the statistic collapses to the closed form
  # the original BARCS benchmark used.
  input <- barcs_example_guides()
  input$p_value <- 2 * pnorm(-abs(input$estimate / input$std_error))
  consistent <- input$gene == "consistent"
  expected <- sum(
    input$estimate[consistent] / input$std_error[consistent]
  ) / sqrt(sum(consistent))

  original <- bb_gene_original(input)
  expect_equal(
    original$statistic[original$gene == "consistent"], expected,
    tolerance = 1e-6
  )
})

test_that("bb_gene_normal matches a one-sample t test on the coefficients", {
  input <- barcs_example_guides()
  normal <- bb_gene_normal(input, min_guides = 3L)
  row <- normal[normal$gene == "consistent", , drop = FALSE]
  beta <- input$estimate[input$gene == "consistent"]
  standard_error <- sd(beta) / sqrt(length(beta))
  statistic <- mean(beta) / standard_error

  expect_equal(row$estimate, mean(beta))
  expect_equal(row$sigma, sd(beta))
  expect_equal(row$std_error, standard_error)
  expect_equal(row$statistic, statistic)
  expect_equal(
    row$student_p_value,
    2 * pt(-abs(statistic), df = length(beta) - 1L)
  )
  expect_equal(row$normal_p_value, 2 * pnorm(-abs(statistic)))
  expect_identical(row$df, length(beta) - 1L)
  expect_identical(row$p_value, row$student_p_value)
  # The t reference is the more conservative of the two.
  expect_lt(row$normal_p_value, row$student_p_value)
  expect_identical(attr(normal, "reference"), "student_t")
})

test_that("bb_gene_normal can select the plug-in normal reference", {
  input <- barcs_example_guides()
  plugin <- bb_gene_normal(input, min_guides = 3L, reference = "normal")
  row <- plugin[plugin$gene == "consistent", , drop = FALSE]

  expect_identical(row$p_value, row$normal_p_value)
  expect_identical(attr(plugin, "reference"), "normal")
})

test_that("partial pooling separates concordant from discordant guides", {
  input <- barcs_example_guides()
  control <- startsWith(input$gene, "control")
  pooled <- bb_gene_partial_pool(
    input, control = control, min_control_genes = 2
  )
  consistent <- pooled[pooled$gene == "consistent", , drop = FALSE]
  discordant <- pooled[pooled$gene == "discordant", , drop = FALSE]

  expect_lt(consistent$raw_tau2, discordant$raw_tau2)
  expect_equal(consistent$guide_direction_agreement, 1)
  expect_lt(discordant$guide_direction_agreement, 1)
  expect_lt(consistent$p_value, discordant$p_value)
  expect_true(all(
    c("tau2", "raw_tau2", "i_squared", "max_weight_fraction",
      "leave_one_out_max_change", "leave_one_out_sign_stable") %in%
      names(pooled)
  ))
  expect_identical(
    attr(pooled, "heterogeneity_estimator"), "DerSimonian-Laird"
  )
})

test_that("empirical-Bayes moderation shrinks tau2 toward the screen prior", {
  input <- barcs_example_guides()
  control <- startsWith(input$gene, "control")
  moderated <- bb_gene_eb_moderate(
    input, control = control, min_control_genes = 2, prior_df = 4
  )
  prior_tau2 <- attr(moderated, "prior_tau2")

  expect_identical(attr(moderated, "prior_df"), 4)
  expect_true(is.finite(prior_tau2))
  # Every moderated value lies between the gene's own estimate and the prior.
  expect_true(all(
    moderated$tau2 >= pmin(moderated$raw_tau2, prior_tau2) - 1e-12
  ))
  expect_true(all(
    moderated$tau2 <= pmax(moderated$raw_tau2, prior_tau2) + 1e-12
  ))
  expect_error(
    bb_gene_eb_moderate(input, prior_df = 0),
    "one positive finite number"
  )
})

test_that("gene summaries reject malformed input", {
  expect_error(
    bb_gene_consistency(data.frame(gene = "a")),
    "`gene`, `estimate`, and `std_error`"
  )
  expect_error(
    bb_gene_original(data.frame(gene = "a", estimate = 1)),
    "`gene`, `estimate`, and `p_value`"
  )
  expect_error(
    bb_gene_normal(data.frame(gene = "a")),
    "`gene` and `estimate`"
  )
  # Too few genes survive the guide-count filter to estimate an empirical null.
  expect_error(
    bb_gene_consistency(barcs_example_guides(), min_guides = 50L),
    "At least two genes"
  )
})
