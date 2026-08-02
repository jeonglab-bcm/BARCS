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
