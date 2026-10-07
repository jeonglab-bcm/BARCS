# GSE291338 reanalysis with BARCS 0.2.0

**Paper.** "CDK4/6 inhibition overcomes venetoclax resistance mechanisms with enhanced combination activity in acute myeloid leukemia", *Cell Reports Medicine* (2026), PMID 41468895, doi:10.1016/j.xcrm.2025.102526 (PMC12866115).

**Screen.** OCI-AML2 cells, genome-wide library (90,709 guides, about 5 per gene). Arms: day 0, DMSO, palbociclib, venetoclax, and ven+palbo, with 2 replicates per treated arm. The paper's supplementary Table (mmc2) gives guide- and gene-level results for each arm versus DMSO.

**Design.** Column names state arm and replicate. Each drug arm vs DMSO, `~ treatment`, 4 libraries, 2 residual df. Library totals for palbo; median-ratio totals for ven and combo.

## Library composition

| Library | Top 1% of guides: share of reads |
|---|---|
| DMSO, day 0 | 2–3% |
| Palbociclib | about 8% |
| Venetoclax | 90–94% |
| Ven+palbo | 60–84% |

Venetoclax killed nearly every clone. The survivors are mostly BAX and PMAIP1 knockouts: the five BAX guides alone hold about half of each ven library.

## Results

| Arm | Genes at FDR 0.10 (up / down) | Named genes |
|---|---|---|
| Palbo vs DMSO | 248 / 1,102 | CEBPE #3, HNRNPU #16, IKZF1 #109, RB1 #1,187 (FDR 0.09) |
| Ven vs DMSO | 98 / 13,006 | BAX p = 0.76, PMAIP1 p = 0.77 |
| Combo vs DMSO | 52 / 2,920 | IKZF1 p = 0.49 |

**Palbociclib.** The arm without a bottleneck agrees with the paper.
- 8 of the paper's top 25 genes are in BARCS's top 25; the paper's table lists 2,346 tiered genes.
- RB1, the paper's palbo resistance gene, is enriched at FDR 0.09.

**Venetoclax and combination.** These arms are where BARCS fails.
- Every BAX guide rises from about 20,000 to 2–10 million reads in both ven replicates.
- BARCS still estimates a huge effect (about 9.5 log odds), but the standard errors are about 75, so p is about 0.8.
- This is the Hauck–Donner effect: when a guide approaches a large share of a library, the Wald standard error grows faster than the estimate. A likelihood-ratio test would not have this failure.
- The depletion calls in these arms (thousands of genes) reflect the population collapse, not gene-specific dropout, even after median-ratio normalization. That normalization was capped because single guides exceed the median-based totals.

## Limits

- Two replicates per arm give 2 residual degrees of freedom.
- For ven and combo, only enrichment is interpretable, and BARCS's current test cannot rank the strongest enrichment.
- **Proposed package fix:** a likelihood-ratio test, used when the Wald standard error is inflated.
