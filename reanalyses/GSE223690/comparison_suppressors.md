# BARCS versus published results

BARCS genes: `results/d14_low_vs_high/genes.csv` (20915 genes, direction: depleted)

## Agreement with the published table

Published: `paper/mmc2.xlsx` (score `neg|score`, lower is stronger); 21915 genes, 20890 shared with BARCS.

Spearman correlation of gene scores: **0.63**


Effect direction agreement: 96.8% of 20890 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 16 | 0.47 | 9 | 9 |
| 50 | 26 | 0.35 | 24 | 24 |
| 100 | 51 | 0.34 | 49 | 49 |
| 200 | 101 | 0.34 | 99 | 99 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): WDR6 (9 / 21), PTPRR (11 / 15)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): CAMK2B (5 / 15), RNF126 (8 / 38)

## BARCS calls

Genes at FDR 0.05: 20; at FDR 0.10: 35. Top 15: GET4, BAG6, DPH1, DNAJC24, USP10, NAA15, ASNA1, UBL4A, WDR6, QRFP, PTPRR, METTL14, OR56A5, ZKSCAN2, CAMK2B
