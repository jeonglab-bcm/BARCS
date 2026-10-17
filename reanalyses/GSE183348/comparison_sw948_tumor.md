# BARCS versus published results

BARCS genes: `results/sw948_tumor_vs_day0/genes.csv` (177 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PCBP1 | 3 | 177 | -0.979 | 3e-07 | 1.8e-05 |
| ATP5SL | 57 | 177 | -0.185 | 0.32 | 0.83 |
| CDC42 | 175 | 177 | 0.494 | 0.03 | 0.17 |
| CIRH1A | 5 | 177 | -0.719 | 4.5e-05 | 0.0016 |
| CNOT9 | 22 | 177 | -0.363 | 0.0079 | 0.058 |

## Agreement with the published table

Published: `paper/SuppTable6_SW948_Tumor.tsv` (score `neg|score`, lower is stronger); 177 genes, 177 shared with BARCS.

Spearman correlation of gene scores: **0.81**


Effect direction agreement: 83.1% of 177 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 7 | 0.54 | 3 | 3 |
| 25 | 22 | 0.79 | 3 | 3 |
| 50 | 40 | 0.67 | 10 | 10 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): ARPC2 (6 / 15), COASY (8 / 18), CSE1L (9 / 22)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): RPLP0 (6 / 27), AAMP (8 / 21), USP37 (9 / 25)

## BARCS calls

Genes at FDR 0.05: 21; at FDR 0.10: 28. Top 15: TANGO6, PGK1, PCBP1, ADRM1, CIRH1A, ARPC2, TMEM258, COASY, CSE1L, GAPDH, EXOSC5, MRPL51, FAM182B, FEN1, NCAPD2
