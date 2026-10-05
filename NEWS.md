# BARCS 0.2.0

## Guide-level inference

* `bb_screen()` now moderates guide dispersions with
  `bb_moderate_dispersion()` by default whenever at least 50 guides are usable
  (`moderate = NULL`). On the four replicate-complete Cas13 screens of
  Liang et al. (2026), moderation raised the macro-average precision for
  essential genes from 0.838 to 0.876 and directional recall at gene FDR 0.10
  from 0.61 to 0.77, level with limma-voom and edgeR-QL on the same input.
  Use `moderate = FALSE` for the previous behaviour. The `"moderated"`
  attribute records which was used.
* `bb_moderate_dispersion()` refuses to moderate a result twice, and no longer
  warns when guides share the same abundance.
* `bb_screen()` estimates the within-gene correlation of guide residuals when
  `gene` is supplied, net of the between-gene baseline, and stores it as the
  `"guide_correlation"` attribute. A real gene effect is absorbed by the fitted
  mean and does not inflate the estimate.

## Gene-level summaries

* `bb_gene_stouffer()` is the recommended guide-to-gene summary: a directional
  Stouffer combination of guide tests with the median guide coefficient as the
  gene effect. It widens the null variance of the combined score from `m` to
  `m + m(m - 1)r` using the `"guide_correlation"` estimated by `bb_screen()`,
  which keeps the gene-level type I error near nominal when guides share
  noise; in simulated null screens with within-gene correlation 0.4 and five
  guides per gene the uncorrected rate was about 0.2. It is the summary benchmarked in the BARCS manuscript and ranked
  genes best in simulated FACS screens with known truth. `bb_gene_original()`
  remains as an alias; its `method` column now reads `"stouffer"`.
* `bb_gene_normal()`, `bb_gene_consistency()`, `bb_gene_partial_pool()`, and
  `bb_gene_eb_moderate()` are marked experimental and documented as
  sensitivity analyses.
* `bb_gene_consistency()` now drops guides whose fit did not converge, like
  the other summaries, and reports `converged_fraction` over all of a gene's
  guides.

## Denominators

* New `barcs_control_totals()` builds beta-binomial denominators that hold a
  chosen control class (non-targeting or safe-harbour guides) at a constant
  share of each library, removing composition shifts. Pass the result to
  `bb_screen(totals = )`. The main vignette shows it on `evers_rt112` with
  held-out controls.

## Package

* Kyu-Won Lee added as an author.
* Copyright holder named in `LICENSE`.
* Added `inst/CITATION` and `CITATION.cff`.

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
