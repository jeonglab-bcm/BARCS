# BARCS versus published results

BARCS genes: `results/RSL3_vs_DMSO/genes.csv` (20669 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TRAPPC4 | 1 | 20669 | -0.798 | 5.6e-17 | 1.2e-12 |
| POLR3H | 3 | 20669 | -0.820 | 3e-13 | 2.1e-09 |
| PSMG4 | 4 | 20669 | -0.631 | 6e-13 | 3.1e-09 |
| LSM11 | 2 | 20669 | -0.571 | 1.3e-14 | 1.3e-10 |
| LONP1 | 5 | 20669 | -0.665 | 1.6e-12 | 5.8e-09 |
| GINS4 | 19 | 20669 | -0.653 | 3.7e-10 | 4e-07 |
| USP5 | 28 | 20669 | -0.561 | 1.3e-08 | 9.9e-06 |
| TPI1 | 87 | 20669 | -0.368 | 9.3e-06 | 0.0022 |

## Agreement with the published table

Published: `paper/TableS8.tsv` (score `neg|score`, lower is stronger); 20669 genes, 20645 shared with BARCS.

Spearman correlation of gene scores: **0.77**


Effect direction agreement: 69.8% of 20645 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 5 | 1.00 | 0 | 0 |
| 50 | 37 | 0.59 | 13 | 13 |
| 100 | 73 | 0.57 | 27 | 27 |
| 200 | 135 | 0.51 | 65 | 65 |
| 1000 | 685 | 0.52 | 315 | 315 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): none

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): none

## BARCS calls

Genes at FDR 0.05: 196; at FDR 0.10: 261. Top 15: TRAPPC4, LSM11, POLR3H, PSMG4, LONP1, SOD2, IARS2, hsa-mir-3180-4, PPP4C, SNAPC2, ATP6V0C, GFER, GPN2, CENPM, SNRNP35
