# BARCS versus published results

BARCS genes: `results/suppressor_GFPhigh_vs_unsorted/genes.csv` (93 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| OTUD5 | 1 | 93 | 0.672 | 2.4e-07 | 2.2e-05 |
| USP45 | 3 | 93 | 0.501 | 0.015 | 0.47 |

## Agreement with the published table

Published: `paper/EV1_GFP_high.tsv` (score `pos|p-value`, lower is stronger); 94 genes, 93 shared with BARCS.

Spearman correlation of gene scores: **0.69**


Effect direction agreement: 95.7% of 93 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 5 | 1.00 | 0 | 0 |
| 10 | 6 | 0.43 | 4 | 4 |
| 20 | 11 | 0.38 | 9 | 9 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): none

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): none

## BARCS calls

Genes at FDR 0.05: 2; at FDR 0.10: 2. Top 15: OTUD5, EIF3H, USP45, BAP1, USP47, USP32, USP19, USP50, OTUD1, USP4, USP6, USP42, USP3, USP51, USP21
