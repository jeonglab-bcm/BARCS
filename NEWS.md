# BARCS 0.1.0

First release. BARCS began as the regression layer inside CB2 and is now a
standalone package with no dependency on it.

## Modelling

* `bbreg()` fits guide-level beta-binomial regression on an arbitrary
  full-rank design matrix, with `coef()`, `vcov()`, `fitted()`,
  `residuals()`, and `summary()` methods.
* `bb_contrast()` tests any linear combination of fitted coefficients.
* `bb_screen()` applies the fit across a count matrix and returns one tidy row
  per guide with a Benjamini-Hochberg FDR.
* `bb_calibrate_controls()` estimates an empirical-null scale from
  negative-control guides, by far-tail quantile or by quantile-quantile slope.
* `bb_moderate_dispersion()` shrinks guide dispersion toward a library-wide
  abundance trend using the scaled-F moment estimator of Smyth (2004).
* `bb_gene_original()`, `bb_gene_normal()`, `bb_gene_consistency()`,
  `bb_gene_partial_pool()`, and `bb_gene_eb_moderate()` provide guide-to-gene
  summaries, each labelled with the null it assumes.

## Quantification

The guide-barcode scanner is derived from the AdaptiveHash index in CB2 and
produces identical counts on well-formed input. Four defects in that
implementation are fixed here:

* Reverse-complement counts were tallied and then discarded, so a library
  sequenced on the reverse strand returned counts of nearly zero. The
  orientation with more matches now decides the reported counts, and
  `reverse_complement` reports which was used.
* The FASTA parser read whitespace-delimited tokens, so a header carrying a
  description consumed the description as the guide sequence, and sequences
  wrapped over several lines were truncated. Parsing is now line-oriented.
* Bases were encoded with a bit trick that mapped every byte into `0:3`, so a
  degenerate IUPAC code silently hashed as a valid base. Non-ACGT characters
  are now rejected.
* The guide length was taken from the last FASTA entry, so a library with
  mixed lengths was encoded on inconsistent scales. The modal length is now
  enforced and off-length entries are reported.

Also new: long scans are interruptible, unreadable files raise an error
instead of returning zeros, and `barcs_quant()` separates mapped-guide
`totals` from FASTQ-record `reads` so the model denominator cannot be confused
with sequencing yield.

* `barcs_quant()` maps FASTQ reads onto a guide library, transparently
  handling gzip and optionally forking across samples.
* `barcs_mappability()` reports the per-sample mapping rate.
* `barcs_cpm()` normalises counts for display.

## Dependencies

Imports only `parallel`, `Rcpp`, `stats`, `tools`, and `utils`. The
tidyverse, `pheatmap`, `metap`, and `R.utils` dependencies of CB2 are gone;
the plotting helpers that required them are not carried over.

## Data

* `evers_rt112`, a 961-guide CRISPRn dropout screen with reference essential
  and non-essential gene sets.
* `inst/extdata/toydata`, a small synthetic FASTQ screen for the
  quantification examples.
