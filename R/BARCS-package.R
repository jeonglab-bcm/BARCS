#' @keywords internal
#'
#' @section Data contracts:
#' Three objects travel together through every BARCS analysis, and keeping
#' them aligned is the whole of the user-facing discipline:
#'
#' * `counts` is a guide-by-library matrix of raw read counts.
#' * `totals` holds the unfiltered mapped-guide total for each library. It is
#'   the beta-binomial denominator and must **not** be recomputed after guides
#'   are filtered out of `counts`.
#' * `data` has one row per library, in exactly the same order as the columns
#'   of `counts`.
#'
#' @section Workflow:
#' The exported functions follow the order in which an analysis meets them:
#'
#' 1. [barcs_quant()] maps FASTQ reads onto a guide library and returns
#'    `counts`, `totals`, and per-sample read totals.
#' 2. [bbreg()] fits the beta-binomial mean model for a single guide, and
#'    [bb_contrast()] tests a linear combination of its coefficients.
#' 3. [bb_screen()] applies that fit across a whole count matrix.
#' 4. [bb_calibrate_controls()] and [bb_moderate_dispersion()] recalibrate the
#'    guide-level tests using negative controls and a library-wide dispersion
#'    trend.
#' 5. The `bb_gene_*()` functions provide optional, explicitly labelled
#'    guide-to-gene summaries.
#'
#' @references
#' Jeong H-H, Kim SY, Rousseaux MWC, Zoghbi HY, Liu Z (2019).
#' Beta-binomial modeling of CRISPR pooled screen data identifies target genes
#' with greater sensitivity and fewer false negatives.
#' *Genome Research*, 29(6), 999-1008. \doi{10.1101/gr.245571.118}
#'
#' Baggerly KA, Deng L, Morris JS, Aldaz CM (2004).
#' Overdispersed logistic regression for SAGE: modelling multiple groups and
#' covariates. *BMC Bioinformatics*, 5, 144. \doi{10.1186/1471-2105-5-144}
#'
#' Smyth GK (2004). Linear models and empirical Bayes methods for assessing
#' differential expression in microarray experiments.
#' *Statistical Applications in Genetics and Molecular Biology*, 3(1), 3.
#' \doi{10.2202/1544-6115.1027}
#'
#' @importFrom Rcpp evalCpp
#' @importFrom stats binomial glm.control glm.fit model.frame model.matrix
#'   na.fail p.adjust plogis printCoefmat pt qlogis setNames terms uniroot
#' @useDynLib BARCS, .registration = TRUE
"_PACKAGE"
