# Small dependency-free utilities: count normalisation and a reproducible
# guide-level table used by the gene-summary examples and vignettes.

#' Counts per million
#'
#' Scales each column of a count matrix by its own column sum. This is a
#' presentation and diagnostic scale only. Never pass CPM values to
#' [bb_screen()]: the beta-binomial denominator has to be an integer count of
#' sequenced reads.
#'
#' @param counts Guide-by-sample numeric matrix or data frame of raw counts.
#' @param totals Optional per-sample library totals. Defaults to the column
#'   sums of `counts`, which is only correct when `counts` is unfiltered.
#'
#' @return A numeric matrix of the same shape as `counts`, in counts per
#'   million.
#'
#' @export
#' @examples
#' counts <- cbind(a = c(10, 30, 60), b = c(20, 20, 60))
#' barcs_cpm(counts)
barcs_cpm <- function(counts, totals = NULL) {
  if (!is.matrix(counts) && !is.data.frame(counts)) {
    .bb_stop("`counts` must be a numeric matrix or data frame.")
  }
  counts <- as.matrix(counts)
  storage.mode(counts) <- "double"
  if (anyNA(counts) || any(!is.finite(counts)) || any(counts < 0)) {
    .bb_stop("`counts` must contain finite, non-negative values.")
  }
  if (is.null(totals)) {
    totals <- colSums(counts)
  }
  if (length(totals) != ncol(counts) || anyNA(totals) ||
      any(!is.finite(totals)) || any(totals <= 0)) {
    .bb_stop("`totals` must be one positive, finite value per sample.")
  }
  sweep(counts, 2L, totals, "/") * 1e6
}

#' A small reproducible guide-level result
#'
#' Builds a deterministic table in the shape [bb_screen()] returns, with two
#' all-control genes, one gene whose guides agree, and one gene whose guides
#' disagree. It exists so that the `bb_gene_*()` examples and the vignettes
#' have a fixed, fast input that does not depend on a random seed or on
#' fitting a screen first.
#'
#' @return A data frame with columns `gene`, `guide`, `estimate`,
#'   `std_error`, `t_value`, `df`, `p_value`, `converged`, `mean_cpm`, and
#'   `fdr`.
#'
#' @export
#' @examples
#' guides <- barcs_example_guides()
#' str(guides)
#' table(guides$gene)
barcs_example_guides <- function() {
  estimate <- c(
    -0.04, 0.02, 0.01, -0.03, 0.04,
    0.03, -0.02, 0.04, -0.01, -0.03,
    -1.00, -0.90, -1.10, -1.00, -1.05,
    -1.00, -0.90, 0.80, 1.00, 0.20
  )
  gene <- rep(
    c("control_a", "control_b", "consistent", "discordant"),
    each = 5L
  )
  std_error <- rep(0.20, length(estimate))
  df <- rep(8L, length(estimate))
  t_value <- estimate / std_error
  p_value <- 2 * stats::pt(-abs(t_value), df = df)
  result <- data.frame(
    gene = gene,
    guide = sprintf("%s_sg%d", gene, rep(seq_len(5L), times = 4L)),
    estimate = estimate,
    std_error = std_error,
    t_value = t_value,
    df = df,
    p_value = p_value,
    converged = TRUE,
    mean_cpm = 100,
    row.names = NULL
  )
  result$fdr <- stats::p.adjust(result$p_value, method = "BH")
  result
}
