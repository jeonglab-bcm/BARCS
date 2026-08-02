# FASTQ to count matrix.
#
# The compiled scanner lives in `src/GuideIndex.h`; everything here is
# argument checking, transparent decompression, optional parallelism over
# samples, and assembly of the object the modelling functions expect.

# Expand a gzip-compressed FASTQ to a temporary plain file. R's connections
# already link against zlib, so this needs no package dependency.
.barcs_gunzip <- function(from, to) {
  input <- gzfile(from, open = "rb")
  on.exit(close(input), add = TRUE)
  output <- file(to, open = "wb")
  on.exit(close(output), add = TRUE)
  repeat {
    chunk <- readBin(input, what = "raw", n = 4194304L)
    if (!length(chunk)) {
      break
    }
    writeBin(chunk, output)
  }
  invisible(to)
}

# Read a guide-to-gene mapping table and align it to the library's guides.
.barcs_read_map <- function(map_path, guide) {
  extension <- tolower(tools::file_ext(map_path))
  if (!extension %in% c("csv", "tsv", "txt")) {
    .bb_stop("`map_path` must name a .csv, .tsv, or .txt file.")
  }
  map <- if (extension == "csv") {
    utils::read.csv(map_path, stringsAsFactors = FALSE, check.names = TRUE)
  } else {
    utils::read.delim(map_path, stringsAsFactors = FALSE, check.names = TRUE)
  }
  names(map) <- tolower(names(map))
  id_column <- intersect(c("id", "sgrna", "guide"), names(map))
  if (!length(id_column) || !"gene" %in% names(map)) {
    .bb_stop(paste0(
      "`map_path` must contain a `gene` column and a guide-identifier ",
      "column named `id`, `sgRNA`, or `guide`."
    ))
  }
  identifier <- as.character(map[[id_column[1L]]])
  if (anyDuplicated(identifier)) {
    .bb_stop("`map_path` names the same guide more than once.")
  }
  as.character(map$gene)[match(guide, identifier)]
}

#' Quantify guide abundance from FASTQ files
#'
#' Scans each sample's reads against a guide library FASTA and returns the
#' guide-by-sample count matrix that [bb_screen()] consumes, along with the
#' library totals that form the beta-binomial denominator.
#'
#' Matching is exact. Each read is scanned with a rolling window of the
#' library's guide length and credited to the first guide it matches, so no
#' fixed adapter or constant-region offset has to be supplied. Reads that
#' match nothing in the sequenced orientation are rescanned as their reverse
#' complement, and the orientation with more matches decides the sample's
#' reported counts.
#'
#' Guides whose sequence appears more than once in the FASTA are dropped
#' entirely, because a read matching them cannot be attributed to one guide.
#' Guides that are not the library's modal length, or that contain characters
#' other than A, C, G, and T, are dropped as well. All three counts are
#' returned so that a surprising library can be recognised rather than
#' silently tolerated.
#'
#' @section Totals versus reads:
#' The returned `totals` are mapped guide reads per sample, which is the
#' denominator the beta-binomial model needs. `reads` is the number of FASTQ
#' records in the file, which is larger and is only used for mappability. Pass
#' `totals` to [bb_screen()], and keep them fixed if you later filter guides
#' out of the count matrix.
#'
#' @param library_path Path to the guide library FASTA file. Sequences may be
#'   wrapped over several lines, and only the first whitespace-delimited token
#'   of each header is used as the guide name.
#' @param design Data frame of sample metadata with at least the columns
#'   `sample_name` and `fastq_path`. Paths ending in `.gz` are decompressed to
#'   a temporary file automatically.
#' @param map_path Optional path to a CSV or TSV guide-to-gene table. It must
#'   have a `gene` column and a guide-identifier column named `id`, `sgRNA`,
#'   or `guide`.
#' @param ncores Number of forked workers used to scan samples in parallel on
#'   Unix-like systems. Windows always uses one worker.
#' @param verbose Report library statistics and scanning progress.
#'
#' @return An object of class `barcs_counts`: a list with the guide-by-sample
#'   `counts` matrix, the mapped-read `totals` used as the model denominator,
#'   the per-sample FASTQ record `reads`, a `guides` data frame of guide names
#'   and sequences (plus `gene` when `map_path` is given), the per-sample
#'   `reverse_complement` flag, the `design` as supplied, and a `library`
#'   list of index diagnostics.
#'
#' @seealso [barcs_mappability()] for the per-sample mapping rate, and
#'   [bb_screen()] for the model that consumes `counts` and `totals`.
#' @export
#' @examples
#' fasta <- system.file(
#'   "extdata", "toydata", "small_sample.fasta", package = "BARCS"
#' )
#' toydata <- system.file("extdata", "toydata", package = "BARCS")
#' design <- data.frame(
#'   sample_name = c("Base1", "Base2", "High1", "High2"),
#'   group = c("Base", "Base", "High", "High"),
#'   fastq_path = file.path(
#'     toydata, c("Base1.fastq.gz", "Base2.fastq.gz",
#'                "High1.fastq.gz", "High2.fastq.gz")
#'   )
#' )
#'
#' quantified <- barcs_quant(fasta, design)
#' quantified
#' head(quantified$counts)
#' quantified$totals
barcs_quant <- function(library_path, design, map_path = NULL,
                        ncores = 1L, verbose = FALSE) {
  if (!is.character(library_path) || length(library_path) != 1L ||
      is.na(library_path)) {
    .bb_stop("`library_path` must be one file path.")
  }
  if (!file.exists(library_path)) {
    .bb_stop(sprintf(
      "The guide library FASTA file '%s' does not exist.", library_path
    ))
  }
  if (!is.data.frame(design)) {
    .bb_stop("`design` must be a data frame.")
  }
  if (!all(c("sample_name", "fastq_path") %in% names(design))) {
    .bb_stop("`design` must have both `sample_name` and `fastq_path` columns.")
  }
  if (!nrow(design)) {
    .bb_stop("`design` must describe at least one sample.")
  }
  sample_name <- as.character(design$sample_name)
  if (anyNA(sample_name) || anyDuplicated(sample_name)) {
    .bb_stop("`design$sample_name` must be unique and non-missing.")
  }
  fastq_path <- as.character(design$fastq_path)
  missing_fastq <- !file.exists(fastq_path)
  if (any(missing_fastq)) {
    .bb_stop(sprintf(
      "These FASTQ files do not exist: %s",
      paste(fastq_path[missing_fastq], collapse = ", ")
    ))
  }
  if (!is.null(map_path)) {
    if (!is.character(map_path) || length(map_path) != 1L ||
        !file.exists(map_path)) {
      .bb_stop("`map_path` must be one path to an existing file.")
    }
  }
  if (length(ncores) != 1L || !is.finite(ncores) || ncores < 1) {
    .bb_stop("`ncores` must be one positive integer.")
  }
  ncores <- as.integer(ncores)

  library_path <- normalizePath(library_path, mustWork = TRUE)
  fastq_path <- normalizePath(fastq_path, mustWork = TRUE)

  # The scanner reads plain text; expand anything gzipped up front so that a
  # worker never has to.
  compressed <- endsWith(tolower(fastq_path), ".gz")
  if (any(compressed)) {
    scratch <- vapply(
      which(compressed),
      function(i) tempfile(fileext = ".fastq"),
      character(1L)
    )
    on.exit(unlink(scratch), add = TRUE)
    for (k in seq_along(scratch)) {
      .barcs_gunzip(fastq_path[which(compressed)[k]], scratch[k])
    }
    fastq_path[compressed] <- scratch
  }

  n_samples <- length(fastq_path)
  workers <- min(ncores, n_samples)
  quantified <- if (workers > 1L && .Platform$OS.type == "unix") {
    # Each worker builds the guide index once and scans its own share of the
    # samples, so the FASTA is parsed `workers` times rather than once per
    # sample.
    chunks <- split(
      seq_len(n_samples),
      rep(seq_len(workers), length.out = n_samples)
    )
    pieces <- parallel::mclapply(
      chunks,
      function(index) barcs_quant_cpp(library_path, fastq_path[index], verbose),
      mc.cores = workers
    )
    failed <- vapply(pieces, inherits, logical(1L), what = "try-error")
    if (any(failed)) {
      .bb_stop(paste0(
        "Quantification failed in a forked worker: ",
        conditionMessage(attr(pieces[[which(failed)[1L]]], "condition"))
      ))
    }
    combined <- pieces[[1L]]
    combined$count <- matrix(
      unlist(lapply(pieces, `[[`, "count")),
      nrow = nrow(pieces[[1L]]$count)
    )[, order(unlist(chunks)), drop = FALSE]
    combined$reads <- unlist(lapply(pieces, `[[`, "reads"))[order(unlist(chunks))]
    combined$mapped <- unlist(lapply(pieces, `[[`, "mapped"))[order(unlist(chunks))]
    combined$reverse_complement <-
      unlist(lapply(pieces, `[[`, "reverse_complement"))[order(unlist(chunks))]
    combined
  } else {
    barcs_quant_cpp(library_path, fastq_path, verbose)
  }

  counts <- quantified$count
  dimnames(counts) <- list(quantified$guide, sample_name)
  guides <- data.frame(
    guide = quantified$guide,
    sequence = quantified$sequence,
    stringsAsFactors = FALSE
  )
  if (!is.null(map_path)) {
    guides$gene <- .barcs_read_map(map_path, quantified$guide)
    unmatched <- sum(is.na(guides$gene))
    if (unmatched > 0L) {
      warning(sprintf(
        "%d of %d library guides have no gene in `map_path`.",
        unmatched, nrow(guides)
      ), call. = FALSE)
    }
  }

  structure(
    list(
      counts = counts,
      totals = setNames(as.numeric(quantified$mapped), sample_name),
      reads = setNames(as.numeric(quantified$reads), sample_name),
      guides = guides,
      reverse_complement = setNames(
        as.logical(quantified$reverse_complement), sample_name
      ),
      design = design,
      library = list(
        path = library_path,
        guide_length = quantified$guide_length,
        n_guides = nrow(guides),
        n_duplicate = quantified$n_duplicate,
        n_wrong_length = quantified$n_wrong_length,
        n_invalid = quantified$n_invalid
      )
    ),
    class = "barcs_counts"
  )
}

#' @param x A `barcs_counts` object.
#' @param ... Ignored, present for S3 consistency.
#' @rdname barcs_quant
#' @export
print.barcs_counts <- function(x, ...) {
  cat("<barcs_counts>\n")
  cat(sprintf(
    "  %d guides x %d samples, guide length %d\n",
    nrow(x$counts), ncol(x$counts), x$library$guide_length
  ))
  dropped <- c(
    repeated = x$library$n_duplicate,
    `off-length` = x$library$n_wrong_length,
    `non-ACGT` = x$library$n_invalid
  )
  if (any(dropped > 0)) {
    cat(sprintf(
      "  dropped from library: %s\n",
      paste(sprintf("%d %s", dropped[dropped > 0], names(dropped)[dropped > 0]),
            collapse = ", ")
    ))
  }
  rate <- 100 * x$totals / x$reads
  cat(sprintf(
    "  mappability: %.1f%% to %.1f%% (median %.1f%%)\n",
    min(rate), max(rate), stats::median(rate)
  ))
  if (any(x$reverse_complement)) {
    cat(sprintf(
      "  reverse-complement samples: %s\n",
      paste(names(x$reverse_complement)[x$reverse_complement], collapse = ", ")
    ))
  }
  invisible(x)
}

#' Per-sample mapping rate
#'
#' Reports how many of each sample's reads carried a recognisable guide
#' barcode. A sample whose mappability is far below its peers usually points
#' at the wrong library FASTA, a trimming problem, or contamination, and is
#' worth resolving before any modelling.
#'
#' @param object A `barcs_counts` object returned by [barcs_quant()].
#'
#' @return A data frame with the columns of the original `design` (minus
#'   `fastq_path`) plus `total_reads`, `mapped_reads`, and `mappability` as a
#'   percentage.
#'
#' @export
#' @examples
#' fasta <- system.file(
#'   "extdata", "toydata", "small_sample.fasta", package = "BARCS"
#' )
#' toydata <- system.file("extdata", "toydata", package = "BARCS")
#' design <- data.frame(
#'   sample_name = c("Base1", "High1"),
#'   group = c("Base", "High"),
#'   fastq_path = file.path(toydata, c("Base1.fastq.gz", "High1.fastq.gz"))
#' )
#'
#' barcs_mappability(barcs_quant(fasta, design))
barcs_mappability <- function(object) {
  if (!inherits(object, "barcs_counts")) {
    .bb_stop("`object` must be a `barcs_counts` object from `barcs_quant()`.")
  }
  result <- object$design[, setdiff(names(object$design), "fastq_path"),
                          drop = FALSE]
  result$total_reads <- as.numeric(object$reads)
  result$mapped_reads <- as.numeric(object$totals)
  result$mappability <- 100 * result$mapped_reads / result$total_reads
  rownames(result) <- NULL
  result
}
