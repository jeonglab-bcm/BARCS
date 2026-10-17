# BARCS versus published results

BARCS genes: `results/CD58low_vs_mid/genes.csv` (19113 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CD58 | 1 | 19113 | 4.794 | 2.9e-23 | 5.5e-19 |
| CMTM6 | 13 | 19113 | 1.407 | 4.1e-10 | 6e-07 |

## Agreement with the published table

Published: `paper/cd58_mageck_combined.tsv` (score `mean_pos_rank`, lower is stronger); 19112 genes, 19085 shared with BARCS.

Spearman correlation of gene scores: **0.82**


Effect direction agreement: 80.5% of 19085 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 44 | 0.79 | 6 | 6 |
| 100 | 77 | 0.63 | 23 | 23 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): PIGO (8 / 12), PIGP (10 / 17)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): NF2 (9 / 11), CMTM6 (10 / 13)

## BARCS calls

Genes at FDR 0.05: 59; at FDR 0.10: 69. Top 15: CD58, PGAP2, CUL3, DNAJC13, PIGV, DYRK1A, KMT2D, PIGO, RUNX1, PIGP, NF2, TIPARP, CMTM6, ZBTB7A, PIGL
