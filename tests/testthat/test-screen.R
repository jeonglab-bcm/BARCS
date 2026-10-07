test_that("bb_screen returns one tidy row per guide", {
  fixture <- fixture_equal_libraries()
  counts <- rbind(
    guide_a = fixture$count,
    guide_b = fixture_overdispersed(fixture$mu, fixture$total)
  )
  screen <- bb_screen(
    counts, fixture$data, ~ dose + batch,
    term = "dose",
    totals = fixture$total,
    gene = c("gene_a", "gene_b")
  )

  expect_identical(nrow(screen), 2L)
  expect_true(all(
    c("gene", "guide", "estimate", "std_error", "t_value", "df",
      "p_value", "rho", "pearson_null", "mean_cpm", "converged", "fdr") %in%
      names(screen)
  ))
  expect_identical(screen$guide, c("guide_a", "guide_b"))
  expect_true(all(screen$fdr >= screen$p_value, na.rm = TRUE))
  expect_true(all(screen$converged))
})

test_that("bb_screen agrees with a direct single-guide fit", {
  fixture <- fixture_equal_libraries()
  counts <- rbind(guide_a = fixture$count)
  screen <- bb_screen(
    counts, fixture$data, ~ dose + batch,
    term = "dose", totals = fixture$total, min_total_count = 0
  )
  direct <- bbreg(fixture$count, fixture$total, ~ dose + batch, fixture$data)

  expect_equal(screen$estimate, direct$coefficient_table["dose", "estimate"])
  expect_equal(screen$std_error, direct$coefficient_table["dose", "std_error"])
  expect_equal(screen$rho, direct$rho)
})

test_that("non-integer totals fail loudly instead of returning NA rows", {
  # Without the guard every guide fails individually and the screen returns a
  # table of NA rows, which reads as a modelling failure rather than a bad
  # argument. Size-factor normalisation is the usual route to a fractional
  # total.
  set.seed(909)
  counts <- matrix(
    rpois(40L * 6L, 300), 40L, 6L,
    dimnames = list(sprintf("guide_%d", 1:40), sprintf("sample_%d", 1:6))
  )
  data <- data.frame(arm = rep(0:1, each = 3))

  expect_error(
    bb_screen(
      counts = counts, totals = colSums(counts) + 0.5,
      data = data, formula = ~arm, term = "arm"
    ),
    "integer-valued library sizes"
  )
  integer_totals <- bb_screen(
    counts = counts, totals = colSums(counts),
    data = data, formula = ~arm, term = "arm"
  )
  expect_true(all(integer_totals$converged))
})

test_that("guides below min_total_count yield a labelled empty row", {
  set.seed(77)
  counts <- rbind(
    plenty = rpois(6L, 400),
    sparse = c(1, 0, 1, 0, 0, 1)
  )
  data <- data.frame(arm = rep(0:1, each = 3))
  screen <- bb_screen(
    counts, data, ~arm, term = "arm",
    totals = rep(10000, 6L), min_total_count = 10
  )

  expect_false(screen$converged[screen$guide == "sparse"])
  expect_true(is.na(screen$estimate[screen$guide == "sparse"]))
  # The abundance column survives even when the fit does not.
  expect_true(is.finite(screen$mean_cpm[screen$guide == "sparse"]))
  expect_true(screen$converged[screen$guide == "plenty"])
})

test_that("bb_screen validates its arguments", {
  counts <- matrix(rpois(30L, 200), 5L, 6L,
                   dimnames = list(sprintf("g%d", 1:5), NULL))
  data <- data.frame(arm = rep(0:1, each = 3))

  expect_error(
    bb_screen(counts, data, ~arm, term = "nope", totals = rep(5000, 6)),
    "must be one model-matrix coefficient"
  )
  expect_error(
    bb_screen(counts, data[1:2, , drop = FALSE], ~arm, term = "arm"),
    "one row per count-matrix column"
  )
  expect_error(
    bb_screen(counts, data, ~arm, term = "arm", totals = rep(5000, 3)),
    "one value per count-matrix column"
  )
  expect_error(
    bb_screen(counts, data, ~arm, term = "arm", totals = rep(10, 6)),
    "cannot exceed its sample's `total`"
  )
  expect_error(
    bb_screen(counts, data, ~arm, term = "arm",
              totals = rep(5000, 6), guide = rep("dup", 5)),
    "must uniquely identify"
  )
  expect_error(
    bb_screen(counts, data, ~arm, term = "arm",
              totals = rep(5000, 6), gene = c("a", "b")),
    "one value per guide"
  )
  expect_error(
    bb_screen(counts, data, ~arm, term = "arm",
              totals = rep(5000, 6), ncores = 0),
    "one positive integer"
  )
})

test_that("totals default to column sums only when counts are unfiltered", {
  set.seed(31)
  counts <- matrix(rpois(20L * 4L, 250), 20L, 4L,
                   dimnames = list(sprintf("g%02d", 1:20), NULL))
  data <- data.frame(arm = rep(0:1, each = 2))
  full <- bb_screen(counts, data, ~arm, term = "arm")

  # Dropping half the guides and letting the totals default silently changes
  # the denominator, which is exactly the mistake `totals` exists to prevent.
  filtered_wrong <- bb_screen(counts[1:10, ], data, ~arm, term = "arm")
  filtered_right <- bb_screen(
    counts[1:10, ], data, ~arm, term = "arm", totals = colSums(counts)
  )

  expect_equal(filtered_right$estimate, full$estimate[1:10])
  expect_false(isTRUE(all.equal(
    filtered_wrong$estimate, full$estimate[1:10]
  )))
})

test_that("forked and serial screens agree", {
  skip_on_os("windows")
  set.seed(52)
  counts <- matrix(rpois(12L * 6L, 300), 12L, 6L,
                   dimnames = list(sprintf("g%02d", 1:12), NULL))
  data <- data.frame(arm = rep(0:1, each = 3))

  serial <- bb_screen(counts, data, ~arm, term = "arm", ncores = 1L)
  forked <- bb_screen(counts, data, ~arm, term = "arm", ncores = 2L)
  expect_equal(serial, forked)
})

# Guides x samples counts with optional within-gene shared noise and a gene
# effect on `group`. Shared noise enters per gene and sample, which is exactly
# what makes a gene's guides correlated beyond the design.
fixture_correlated_screen <- function(correlation = 0, effect = 0,
                                      n_genes = 60L, guides = 4L,
                                      seed = 77) {
  set.seed(seed)
  n_samples <- 8L
  group <- rep(0:1, each = n_samples / 2L)
  gene <- rep(sprintf("G%03d", seq_len(n_genes)), each = guides)
  total <- rep(200000, n_samples)
  shared <- matrix(rnorm(n_genes * n_samples), n_genes)[
    rep(seq_len(n_genes), each = guides), ]
  noise <- sqrt(correlation) * shared +
    sqrt(1 - correlation) * matrix(rnorm(length(gene) * n_samples),
                                   length(gene))
  eta <- -7 + 0.25 * noise +
    outer(rep(effect, length(gene)), group)
  counts <- matrix(rbinom(length(eta), total[1], plogis(eta)),
                   nrow = length(gene))
  list(counts = counts, gene = gene, data = data.frame(group = group),
       total = total)
}

test_that("bb_screen() moderates by default once enough guides are usable", {
  x <- fixture_correlated_screen()
  moderated <- bb_screen(x$counts, x$data, ~ group, "group",
                         totals = x$total, gene = x$gene,
                         guide = sprintf("g%03d", seq_along(x$gene)))
  plain <- bb_screen(x$counts, x$data, ~ group, "group",
                     totals = x$total, gene = x$gene,
                     guide = sprintf("g%03d", seq_along(x$gene)),
                     moderate = FALSE)
  expect_true(attr(moderated, "moderated"))
  expect_false(attr(plain, "moderated"))
  expect_true("unmoderated_p_value" %in% names(moderated))
  expect_equal(moderated$estimate, plain$estimate)
  expect_equal(moderated$unmoderated_p_value, plain$p_value)
  expect_error(
    bb_screen(x$counts[1:8, ], x$data, ~ group, "group",
              totals = x$total, guide = sprintf("g%d", 1:8),
              moderate = TRUE),
    "usable guide fits"
  )
  expect_error(
    bb_screen(x$counts, x$data, ~ group, "group", totals = x$total,
              guide = sprintf("g%03d", seq_along(x$gene)), moderate = NA),
    "`moderate` must be"
  )
})

test_that("guide correlation detects shared noise but not real effects", {
  screen_correlation <- function(...) {
    x <- fixture_correlated_screen(...)
    attr(bb_screen(x$counts, x$data, ~ group, "group", totals = x$total,
                   gene = x$gene,
                   guide = sprintf("g%03d", seq_along(x$gene)),
                   moderate = FALSE), "guide_correlation")
  }
  independent <- screen_correlation(correlation = 0)
  correlated <- screen_correlation(correlation = 0.5)
  # Every guide of every gene shares a large effect, but the noise is
  # independent: the fitted mean absorbs the effect, so residuals stay
  # uncorrelated.
  effect_only <- screen_correlation(correlation = 0, effect = 1)

  expect_lt(independent, 0.08)
  expect_lt(effect_only, 0.08)
  expect_gt(correlated, 0.25)
})

test_that("bb_screen() records no correlation without genes", {
  x <- fixture_correlated_screen(n_genes = 15L)
  result <- bb_screen(x$counts, x$data, ~ group, "group", totals = x$total,
                      guide = sprintf("g%03d", seq_along(x$gene)))
  expect_null(attr(result, "guide_correlation"))
})

test_that("the likelihood ratio matches the binomial deviance when rho is zero", {
  fixture <- fixture_equal_libraries()
  fit <- bbreg(fixture$count, fixture$total, ~ dose + batch, fixture$data)
  fit$rho <- 0
  signed_root <- BARCS:::.bb_lr_statistic(fit, "dose")
  full <- glm(cbind(fixture$count, fixture$total - fixture$count) ~ dose + batch,
              family = binomial(), data = fixture$data)
  reduced <- update(full, . ~ . - dose)
  expect_equal(signed_root^2, deviance(reduced) - deviance(full), tolerance = 1e-5)
  expect_identical(sign(signed_root), sign(coef(full)[["dose"]]))
})

test_that("test = 'lr' reports the standard error the likelihood ratio implies", {
  fixture <- fixture_equal_libraries()
  counts <- rbind(
    guide_a = fixture$count,
    guide_b = fixture_overdispersed(fixture$mu, fixture$total)
  )
  screen <- bb_screen(counts, fixture$data, ~ dose + batch, term = "dose",
                      totals = fixture$total, test = "lr", moderate = FALSE)
  expect_true(all(c("wald_std_error", "lr_used") %in% names(screen)))
  expect_true(all(screen$lr_used))
  expect_identical(attr(screen, "test"), "lr")
  expect_equal(screen$t_value, screen$estimate / screen$std_error)

  wald <- bb_screen(counts, fixture$data, ~ dose + batch, term = "dose",
                    totals = fixture$total, moderate = FALSE)
  expect_false(any(c("wald_std_error", "lr_used") %in% names(wald)))
  expect_equal(screen$wald_std_error, wald$std_error)
})

test_that("the likelihood ratio rescues a guide the Wald test loses to Hauck-Donner", {
  # Rises about 400-fold in both treated libraries; one dispersion per guide
  # makes the Wald standard error explode at the low-abundance end.
  data <- data.frame(treated = rep(0:1, each = 2))
  totals <- c(61396142, 65624685, 73321962, 62453506)
  counts <- rbind(
    jackpot = c(23098, 22836, 10402692, 6203267),
    steady = c(500, 520, 600, 480)
  )
  wald <- bb_screen(counts, data, ~ treated, "treated", totals = totals,
                    moderate = FALSE)
  auto <- bb_screen(counts, data, ~ treated, "treated", totals = totals,
                    moderate = FALSE, test = "auto")
  expect_identical(auto$lr_used, c(TRUE, FALSE))
  expect_lt(auto$p_value[1], wald$p_value[1])
  expect_equal(auto$p_value[2], wald$p_value[2])
})

test_that("lr_fold is validated", {
  fixture <- fixture_equal_libraries()
  expect_error(
    bb_screen(rbind(g = fixture$count), fixture$data, ~ dose, "dose",
              totals = fixture$total, test = "auto", lr_fold = 1),
    "lr_fold"
  )
})
