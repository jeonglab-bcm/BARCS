# BARCS versus published results

BARCS genes: `results/low_vs_high/genes.csv` (17991 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| BTN3A1 | 1 | 17991 | 2.159 | 3.4e-240 | 6.2e-236 |
| BTN3A2 | 7 | 17991 | 2.623 | 2.8e-120 | 5.6e-117 |
| IRF1 | 2 | 17991 | 2.518 | 2e-225 | 1.8e-221 |
| SPIB | 4 | 17991 | 1.019 | 3.9e-164 | 1.4e-160 |
| ECSIT | 9 | 17991 | 1.216 | 1.1e-97 | 1.2e-94 |
| NLRC5 | 3 | 17991 | 2.042 | 1.8e-184 | 1.1e-180 |
| FBXW7 | 8 | 17991 | 0.876 | 8.7e-109 | 1.3e-105 |
| IRF8 | 6 | 17991 | 1.538 | 7.7e-122 | 1.7e-118 |

## Agreement with the published table

Published: `paper/MOESM8.xlsx` (score `pos|score`, lower is stronger); 18000 genes, 17991 shared with BARCS.

Spearman correlation of gene scores: **0.76**


Effect direction agreement: 81.5% of 17991 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 18 | 0.56 | 7 | 7 |
| 50 | 34 | 0.52 | 16 | 16 |
| 100 | 77 | 0.63 | 23 | 23 |
| 200 | 168 | 0.72 | 32 | 32 |
| 500 | 427 | 0.75 | 73 | 73 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): BIRC6 (10 / 45), RFX5 (13 / 90), RIC8A (19 / 52), TMEM261 (20 / 37), RFXANK (21 / 147), ACAD9 (23 / 27), SPI1 (24 / 34)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): NDUFA13 (10 / 53), C17orf89 (12 / 28), SRPK1 (15 / 42), NDUFS7 (16 / 27), NDUFS8 (22 / 29), JMJD6 (23 / 64), NDUFS2 (24 / 38)

## BARCS calls

Genes at FDR 0.05: 2683; at FDR 0.10: 3244. Top 15: BTN3A1, IRF1, NLRC5, SPIB, RFXAP, IRF8, BTN3A2, FBXW7, ECSIT, BIRC6, NDUFA2, CNOT11, RFX5, NDUFV1, NDUFC2
