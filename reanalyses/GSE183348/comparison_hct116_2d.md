# BARCS versus published results

BARCS genes: `results/hct116_2d_vs_day0/genes.csv` (177 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PCBP1 | 7 | 177 | -2.443 | 3.9e-08 | 9.8e-07 |
| ATP5SL | 31 | 177 | -0.972 | 0.00054 | 0.0031 |
| CDC42 | 22 | 177 | -1.343 | 7.9e-05 | 0.00062 |
| CIRH1A | 11 | 177 | -1.257 | 1.6e-07 | 2.6e-06 |
| CNOT9 | 19 | 177 | -1.501 | 2.6e-06 | 2.4e-05 |

## Agreement with the published table

Published: `paper/SuppTable6_HCT116_2D.tsv` (score `neg|score`, lower is stronger); 177 genes, 177 shared with BARCS.

Spearman correlation of gene scores: **0.91**


Effect direction agreement: 89.8% of 177 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 7 | 0.54 | 3 | 3 |
| 25 | 23 | 0.85 | 2 | 2 |
| 50 | 47 | 0.89 | 3 | 3 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): RPLP0 (2 / 11), HTT (8 / 12), CSE1L (10 / 19)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): NCAPD2 (6 / 29), EXOSC5 (8 / 17), CIRH1A (9 / 11)

## BARCS calls

Genes at FDR 0.05: 35; at FDR 0.10: 37. Top 15: TFRC, RPLP0, PGK1, TANGO6, GAPDH, COASY, PCBP1, HTT, MRPL51, CSE1L, CIRH1A, AAMP, TMEM258, FEN1, SLC7A6OS
