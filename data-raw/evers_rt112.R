# Build data/evers_rt112.rda.
#
# Source: the `Evers_CRISPRn_RT112` object shipped with the CB2 package
# (MIT-licensed, same author), which packages the CRISPRn RT112 screen of
# Evers et al. (2016). That object stores its pieces as tibbles carrying
# readr column specifications and includes precomputed CB2 test results.
# BARCS has no tidyverse dependency and does not redistribute another
# package's results, so this script keeps only the raw inputs and converts
# them to base-R types.
#
# Re-run with:
#   Rscript data-raw/evers_rt112.R /path/to/CB2/data/Evers_CRISPRn_RT112.rda

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L || !file.exists(args[1L])) {
  stop("Pass the path to CB2's Evers_CRISPRn_RT112.rda", call. = FALSE)
}

source_env <- new.env()
load(args[1L], envir = source_env)
original <- get("Evers_CRISPRn_RT112", envir = source_env)

counts <- as.matrix(as.data.frame(original$count))
storage.mode(counts) <- "integer"
dimnames(counts) <- list(rownames(original$count), colnames(original$count))
attr(counts, "spec") <- NULL

design <- data.frame(
  sample_name = as.character(original$design$sample_name),
  group = factor(as.character(original$design$group),
                 levels = c("before", "after")),
  stringsAsFactors = FALSE
)
# The model matrix column order follows the factor levels, so `before` is the
# reference and the fitted coefficient reads as "after minus before".
stopifnot(identical(design$sample_name, colnames(counts)))

guide <- rownames(counts)
guides <- data.frame(
  guide = guide,
  gene = sub("_[^_]+$", "", guide),
  stringsAsFactors = FALSE
)
stopifnot(!anyNA(guides$gene), all(nzchar(guides$gene)))

evers_rt112 <- list(
  counts = counts,
  design = design,
  guides = guides,
  essential = sort(as.character(original$egenes)),
  nonessential = sort(as.character(original$ngenes))
)

dir.create("data", showWarnings = FALSE)
save(evers_rt112, file = "data/evers_rt112.rda", compress = "xz", version = 3)
