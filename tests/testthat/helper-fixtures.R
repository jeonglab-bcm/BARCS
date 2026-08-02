# Deterministic fixtures shared by several test files.
#
# Temporary files are left in the session's `tempdir()`, which R removes when
# the process exits, so nothing here needs explicit cleanup.

# A balanced dose-by-batch design with equal library sizes. Equal totals are
# what make the beta-binomial and binomial coefficient estimates comparable.
fixture_equal_libraries <- function(seed = 404) {
  set.seed(seed)
  data <- data.frame(
    dose = rep(seq(-1, 1, length.out = 8), 2),
    batch = factor(rep(c("a", "b"), each = 8))
  )
  total <- rep(50000, nrow(data))
  mu <- plogis(-6.2 + 0.7 * data$dose + 0.15 * (data$batch == "b"))
  list(
    data = data,
    total = total,
    mu = mu,
    count = rbinom(length(mu), total, mu)
  )
}

# The same design, but with counts drawn through a beta mixing distribution so
# that the guide is genuinely overdispersed relative to a binomial.
fixture_overdispersed <- function(mu, total, rho = 0.003, seed = 405) {
  set.seed(seed)
  precision <- 1 / rho - 1
  latent <- rbeta(length(mu), mu * precision, (1 - mu) * precision)
  rbinom(length(mu), total, latent)
}

# Guide-level input for the dispersion-moderation tests: one shared true
# variance inflation, estimated per guide from only a few residual df.
fixture_moderation <- function(n = 400L, df_residual = 7L,
                               true_inflation = 2, seed = 9021) {
  set.seed(seed)
  result <- data.frame(
    guide = sprintf("g%04d", seq_len(n)),
    gene = rep(sprintf("gene%03d", seq_len(n / 4L)), each = 4L),
    estimate = rnorm(n, 0, 0.05),
    df = df_residual,
    rho = 0,
    mean_cpm = exp(rnorm(n, 6, 0.4)),
    converged = TRUE
  )
  result$pearson_null <- true_inflation * rchisq(n, df = df_residual)
  result$std_error <- 0.05 *
    sqrt(pmax(1, result$pearson_null / df_residual))
  result$t_value <- result$estimate / result$std_error
  result$p_value <- 2 * pt(-abs(result$t_value), df_residual)
  result
}

toydata_path <- function(...) {
  system.file("extdata", "toydata", ..., package = "BARCS", mustWork = TRUE)
}

# Expand one of the gzipped toy FASTQ fixtures to a plain temporary file.
plain_fastq <- function(sample_name) {
  path <- tempfile(fileext = ".fastq")
  .barcs_gunzip(toydata_path(paste0(sample_name, ".fastq.gz")), path)
  path
}

reverse_complement <- function(sequence) {
  vapply(
    sequence,
    function(one) {
      paste(rev(strsplit(chartr("ACGTacgt", "TGCAtgca", one), "")[[1]]),
            collapse = "")
    },
    character(1L),
    USE.NAMES = FALSE
  )
}

# Rewrite a FASTQ so that every read is its own reverse complement.
reverse_complement_fastq <- function(from) {
  lines <- readLines(from)
  sequence_lines <- seq(2L, length(lines), by = 4L)
  lines[sequence_lines] <- reverse_complement(lines[sequence_lines])
  to <- tempfile(fileext = ".fastq")
  writeLines(lines, to)
  to
}
