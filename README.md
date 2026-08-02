
<!-- README.md is generated from README.Rmd. Please edit that file -->

# BARCS

<!-- badges: start -->

<!-- badges: end -->

**B**eta-binomial **A**nalysis and **R**egression for **C**RISPR pooled
**S**creens.

BARCS fits guide-level beta-binomial regression to pooled CRISPR screen
counts on an arbitrary full-rank design matrix, and tests a coefficient
or linear contrast against a Student *t* reference whose degrees of
freedom come from independently sequenced libraries — never from read
depth.

Guide counts are modelled against unfiltered full-library totals, so the
beta-binomial variance separates two things a binomial model conflates:
the sampling precision of sequencing, which grows with depth, and the
real variation between libraries, which does not.

The package covers the whole path from raw reads to a gene list: FASTQ
quantification, guide-level regression, negative-control calibration,
empirical-Bayes dispersion moderation, and several explicitly labelled
guide-to-gene summaries.

## Installation

``` r
# install.packages("pak")
pak::pak("jeonglab-bcm/BARCS")
```

Building from source needs a C++17 compiler; there are no runtime
dependencies beyond `Rcpp` and the base recommended packages.

## Quick start

``` r
library(BARCS)

data(evers_rt112)

screen <- bb_screen(
  counts  = evers_rt112$counts,
  totals  = colSums(evers_rt112$counts),
  data    = evers_rt112$design,
  formula = ~ group,
  term    = "groupafter",
  guide   = evers_rt112$guides$guide,
  gene    = evers_rt112$guides$gene
)

head(screen[order(screen$p_value), c("gene", "estimate", "std_error", "p_value", "fdr")])
#>       gene estimate std_error   p_value      fdr
#> 15   PSMC1   -1.484   0.01752 1.165e-07 4.97e-05
#> 36   PSMB2   -1.961   0.02559 1.737e-07 4.97e-05
#> 92   COPS4   -1.268   0.01959 3.414e-07 4.97e-05
#> 53  RPL35A   -1.461   0.02280 3.550e-07 4.97e-05
#> 113  PSMC2   -1.451   0.02332 3.998e-07 4.97e-05
#> 70   RPL34   -1.933   0.03204 4.521e-07 4.97e-05
```

Designs are ordinary R formulas, so dose, time, batch, donor, and
interactions all work the same way:

``` r
bb_screen(
  counts, data = design, formula = ~ dose + batch, term = "dose", totals = totals
)
```

## Starting from FASTQ

``` r
fasta   <- system.file("extdata", "toydata", "small_sample.fasta", package = "BARCS")
toydata <- system.file("extdata", "toydata", package = "BARCS")

design <- data.frame(
  sample_name = c("Base1", "Base2", "High1", "High2"),
  group       = c("Base", "Base", "High", "High"),
  fastq_path  = file.path(toydata, c("Base1.fastq.gz", "Base2.fastq.gz",
                                     "High1.fastq.gz", "High2.fastq.gz"))
)

quantified <- barcs_quant(fasta, design)
quantified
#> <barcs_counts>
#>   25 guides x 4 samples, guide length 20
#>   mappability: 100.0% to 100.0% (median 100.0%)
```

Matching is exact and position-free: a rolling window finds the guide
wherever it sits in the read, so no adapter offset or trimming step is
required. Reads that fail in the sequenced orientation are rescanned as
their reverse complement.

## The data contract

Three objects travel together, and keeping them aligned is the whole
discipline of using the package:

| Object | Shape | Rule |
|----|----|----|
| `counts` | guides × libraries | Raw integer read counts. |
| `totals` | one per library | Unfiltered mapped-guide totals. **Never recompute after filtering guides.** |
| `data` | one row per library | Same order as the columns of `counts`. |

## Documentation

``` r
vignette("BARCS")                  # getting started
vignette("barcs-quantification")   # FASTQ to counts, and library QC
vignette("barcs-gene-summaries")   # guide-to-gene, and what each null assumes
```

## Relationship to CB2

BARCS is the successor to [CB2](https://cran.r-project.org/package=CB2).
The two-group beta-binomial test of Jeong et al. (2019) is the special
case of `bbreg()` with a single indicator column. The quantification
layer is derived from CB2’s index and produces identical counts on
well-formed input, with several defects fixed — see `NEWS.md`. BARCS
does not depend on CB2 and does not carry over its tidyverse-based
plotting helpers.

## References

Jeong H-H, Kim SY, Rousseaux MWC, Zoghbi HY, Liu Z (2019). Beta-binomial
modeling of CRISPR pooled screen data identifies target genes with
greater sensitivity and fewer false negatives. *Genome Research*, 29(6),
999–1008. <doi:10.1101/gr.245571.118>

Baggerly KA, Deng L, Morris JS, Aldaz CM (2004). Overdispersed logistic
regression for SAGE. *BMC Bioinformatics*, 5, 144.
<doi:10.1186/1471-2105-5-144>

## License

MIT © BARCS authors
