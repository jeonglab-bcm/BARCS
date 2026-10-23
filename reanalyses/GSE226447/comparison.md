# BARCS versus published results

BARCS genes: `results/AMA_vs_PBS_median_ratio/genes.csv` (19028 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| STT3B | 9 | 19028 | 3.769 | 1.8e-05 | 0.038 |
| MGAT1 | 2 | 19028 | 5.997 | 3.9e-15 | 3.7e-11 |
| ALG10 | 164 | 19028 | 0.721 | 0.019 | 1 |
| STT3A | 1048 | 19028 | 0.645 | 0.25 | 1 |
| RPN2 | 937 | 19028 | 1.519 | 0.22 | 1 |

## Agreement with the published table

Published: `paper/41467_2023_37714_MOESM3_ESM.xlsx` (score `pos|score`, lower is stronger); 19110 genes, 19027 shared with BARCS.

Spearman correlation of gene scores: **0.77**


Effect direction agreement: 75.9% of 19027 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 12 | 0.32 | 13 | 13 |
| 50 | 21 | 0.27 | 29 | 29 |
| 100 | 44 | 0.28 | 56 | 56 |
| 200 | 89 | 0.29 | 111 | 111 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): COMMD3 (7 / 45), NELFCD (10 / 270)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): LAMTOR2 (7 / 26), TIGD5 (11 / 24)

## BARCS calls

Genes at FDR 0.05: 14; at FDR 0.10: 17. Top 15: WDR81, MGAT1, TAF4, SPPL3, SLC46A3, KIAA1033, COMMD3, PSENEN, STT3B, NELFCD, CFAP52, RALGAPB, FAM45A, RPL32, DCPS
