# BARCS versus published results

BARCS genes: `results/hct116_tumor_vs_day0/genes.csv` (177 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PCBP1 | 2 | 177 | -1.791 | 5.9e-14 | 5.2e-12 |
| ATP5SL | 32 | 177 | -0.556 | 0.058 | 0.29 |
| CDC42 | 175 | 177 | 0.571 | 0.053 | 0.28 |
| CIRH1A | 11 | 177 | -0.878 | 6.9e-06 | 0.00011 |
| CNOT9 | 34 | 177 | -0.430 | 0.069 | 0.33 |

## Agreement with the published table

Published: `paper/SuppTable6_HCT116_Tumor.tsv` (score `neg|score`, lower is stronger); 177 genes, 177 shared with BARCS.

Spearman correlation of gene scores: **0.83**


Effect direction agreement: 84.7% of 177 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 22 | 0.79 | 3 | 3 |
| 50 | 41 | 0.69 | 9 | 9 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): EXOSC5 (6 / 12), TMEM258 (8 / 15)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): FEN1 (7 / 24), MRPL51 (9 / 13)

## BARCS calls

Genes at FDR 0.05: 27; at FDR 0.10: 29. Top 15: GAPDH, PCBP1, NCAPD2, TANGO6, TFRC, EXOSC5, PGK1, TMEM258, SLC7A6OS, RPLP0, CIRH1A, USP37, MRPL51, INCENP, COASY
