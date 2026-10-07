# Simulated 2-replicate sort screen with shared clonal noise per guide.
suppressPackageStartupMessages(library(BARCS))
`%||%` <- function(a, b) if (length(a) == 0 || is.na(a)) b else a
args <- commandArgs(TRUE)
tau <- as.numeric(args[1]); seed <- as.integer(args[2]); reps <- as.integer(args[3] %||% "2")
`%||%` <- function(a, b) if (is.null(a) || is.na(a)) b else a
set.seed(seed)
n_gene <- 3000; m <- 4; n_ctrl <- 1000; n_hit <- 150
gene <- c(rep(sprintf("G%04d", seq_len(n_gene)), each = m), rep("NTC", n_ctrl))
n <- length(gene); control <- gene == "NTC"
effect_gene <- setNames(rep(0, n_gene), sprintf("G%04d", seq_len(n_gene)))
hit <- sample(names(effect_gene), n_hit)
effect_gene[hit] <- sample(c(-1, 1), n_hit, TRUE) * runif(n_hit, 0.6, 1.5)
guide_eff <- ifelse(control, 0, effect_gene[gene]) * runif(n, 0.5, 1)  # guide efficacy
noise <- if (length(args) >= 4) args[4] else "normal"
clonal <- if (noise == "t3") tau * rt(n, 3) / sqrt(3) else rnorm(n, 0, tau)  # shared by all replicates
base <- rnorm(n, 0, 0.8)                      # library representation
data <- expand.grid(bin = c("high", "low"), replicate = paste0("R", seq_len(reps)))
data$bin <- factor(data$bin, c("high", "low")); data$replicate <- factor(data$replicate)
total <- 5e6; rho <- 1e-6; prec <- 1 / rho - 1
counts <- sapply(seq_len(nrow(data)), function(j) {
  eta <- base + (data$bin[j] == "low") * (guide_eff + clonal) + rnorm(n, 0, 0.1)
  mu <- exp(eta) / sum(exp(eta))
  rbinom(n, total, rbeta(n, mu * prec, (1 - mu) * prec))
})
screen <- bb_screen(counts, data, ~ replicate + bin, "binlow", gene = gene,
                    guide = sprintf("g%05d", seq_len(n)), ncores = 1)
cal <- bb_calibrate_controls(screen, control, method = "tail_quantile")
r <- attr(screen, "guide_correlation")
g_model <- bb_gene_stouffer(screen[!control, ], correlation = r)
g_cal <- bb_gene_stouffer(cal[!control, ], correlation = r)
g_emp <- bb_gene_empirical_null(g_model, screen, control, n_null = 2e4)
score <- function(g, label) {
  call <- g$fdr < 0.1 & !is.na(g$fdr); true <- g$gene %in% hit
  data.frame(tau = tau, noise = noise, reps = reps, seed = seed, method = label, calls = sum(call),
             fdp = if (sum(call)) mean(!true[call]) else 0,
             power = sum(call & true) / n_hit,
             ctrl_p05 = mean(screen$p_value[control] < 0.05, na.rm = TRUE))
}
out <- rbind(score(g_model, "model"), score(g_cal, "calibrated"), score(g_emp, "empirical"))
write.table(out, stdout(), sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)
