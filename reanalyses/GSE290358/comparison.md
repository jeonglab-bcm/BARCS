# BARCS versus published results

BARCS genes: `results/High_vs_Low/genes.csv` (19363 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ZEB1 | 1 | 19363 | 2.003 | 1.5e-10 | 3e-06 |
| FGFR1 | 5 | 19363 | 1.854 | 1.1e-07 | 0.00044 |
| F11R | 3 | 19363 | -2.386 | 8.3e-09 | 5.3e-05 |

## Agreement with the published table

Published: `paper/mageck_high_vs_low.tsv` (score `score`, lower is stronger); 19364 genes, 19357 shared with BARCS.

Spearman correlation of gene scores: **0.29**


Effect direction agreement: 87.2% of 19357 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 5 | 0.33 | 5 | 5 |
| 25 | 13 | 0.35 | 12 | 12 |
| 50 | 21 | 0.27 | 29 | 29 |
| 100 | 37 | 0.23 | 63 | 63 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): ZEB1 (1 / 11), KANSL1 (6 / 85), E4F1 (8 / 22), SPPL3 (9 / 24), ATP8B1 (10 / 17)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): KAT8 (3 / 13), DAD1 (4 / 11), RPL38 (5 / 19), ERBB2 (9 / 41), CCT6A (10 / 30)

## BARCS calls

Genes at FDR 0.05: 13; at FDR 0.10: 19. Top 15: ZEB1, INTS10, F11R, GRB2, FGFR1, KANSL1, NUS1, E4F1, SPPL3, ATP8B1, DAD1, WDR75, KAT8, SIN3A, ACTB
