# BARCS versus published results

BARCS genes: `results/dld1_2d_vs_day0/genes.csv` (177 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PCBP1 | 15 | 177 | -1.085 | 9.3e-06 | 0.0001 |
| ATP5SL | 86 | 177 | -0.006 | 0.72 | 0.87 |
| CDC42 | 176 | 177 | 0.806 | 3.7e-05 | 0.00039 |
| CIRH1A | 32 | 177 | -0.394 | 0.024 | 0.096 |
| CNOT9 | 4 | 177 | -1.720 | 3e-09 | 1.3e-07 |

## Agreement with the published table

Published: `paper/SuppTable6_DLD1_2D.tsv` (score `neg|score`, lower is stronger); 177 genes, 177 shared with BARCS.

Spearman correlation of gene scores: **0.91**


Effect direction agreement: 88.1% of 177 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 22 | 0.79 | 3 | 3 |
| 50 | 47 | 0.89 | 3 | 3 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): GAPDH (6 / 13), INCENP (10 / 11)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): GFPT1 (9 / 13), TANGO6 (10 / 14)

## BARCS calls

Genes at FDR 0.05: 37; at FDR 0.10: 44. Top 15: SLC7A6OS, MRPL51, PGK1, CNOT9, TFRC, GAPDH, COASY, FEN1, AAMP, INCENP, NCAPD2, TMEM258, GFPT1, TANGO6, PCBP1
