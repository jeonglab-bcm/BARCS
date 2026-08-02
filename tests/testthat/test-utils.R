test_that("barcs_cpm normalises each column to its own library size", {
  counts <- cbind(a = c(10, 30, 60), b = c(20, 20, 60))
  cpm <- barcs_cpm(counts)

  expect_equal(colSums(cpm), c(a = 1e6, b = 1e6))
  expect_identical(dim(cpm), dim(counts))
  expect_identical(dimnames(cpm), dimnames(counts))
})

test_that("barcs_cpm honours supplied totals", {
  counts <- cbind(a = c(10, 30), b = c(20, 20))
  # Totals larger than the column sums are exactly the filtered-guide case.
  cpm <- barcs_cpm(counts, totals = c(100, 200))

  expect_equal(unname(cpm[, "a"]), c(1e5, 3e5))
  expect_equal(unname(cpm[, "b"]), c(1e5, 1e5))
})

test_that("barcs_cpm rejects impossible input", {
  expect_error(barcs_cpm(1:5), "matrix or data frame")
  expect_error(barcs_cpm(cbind(c(-1, 2))), "non-negative")
  expect_error(barcs_cpm(cbind(c(1, 2)), totals = 0), "positive, finite")
  expect_error(barcs_cpm(cbind(c(1, 2)), totals = c(1, 2)), "one per sample|positive, finite")
})

test_that("the example guide table is deterministic and well formed", {
  first <- barcs_example_guides()
  second <- barcs_example_guides()

  expect_identical(first, second)
  expect_identical(nrow(first), 20L)
  expect_setequal(
    unique(first$gene),
    c("control_a", "control_b", "consistent", "discordant")
  )
  expect_false(anyDuplicated(first$guide) > 0)
  expect_true(all(first$fdr >= first$p_value))
  expect_equal(first$t_value, first$estimate / first$std_error)
})

test_that("the bundled screen has the documented shape", {
  data(evers_rt112, envir = environment())

  expect_identical(dim(evers_rt112$counts), c(961L, 6L))
  expect_type(evers_rt112$counts, "integer")
  # The design rows must line up with the count columns, or every fit would
  # silently model the wrong sample.
  expect_identical(evers_rt112$design$sample_name, colnames(evers_rt112$counts))
  expect_identical(levels(evers_rt112$design$group), c("before", "after"))
  expect_identical(evers_rt112$guides$guide, rownames(evers_rt112$counts))
  expect_false(anyNA(evers_rt112$guides$gene))
  expect_true(all(
    c(evers_rt112$essential, evers_rt112$nonessential) %in%
      evers_rt112$guides$gene
  ))
})
