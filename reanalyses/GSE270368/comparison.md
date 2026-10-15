# BARCS versus published results

BARCS genes: `results/GSI_vs_DMSO/genes.csv` (20706 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| SOX2 | 1462 | 20706 | -0.183 | 0.14 | 1 |

## Agreement with the published table

Published: `paper/mageck_gsi_vs_dmso.tsv` (score `neg|score`, lower is stronger); 17434 genes, 17433 shared with BARCS.

Spearman correlation of gene scores: **0.54**


Effect direction agreement: 76.7% of 17433 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 5 | 0.11 | 20 | 20 |
| 50 | 11 | 0.12 | 39 | 39 |
| 100 | 22 | 0.12 | 78 | 78 |
| 200 | 48 | 0.14 | 152 | 152 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): HNF4A (1 / 1716), OR2H1 (5 / 423), CAPN6 (6 / 40), BAHD1 (7 / 563), CCDC66 (8 / 433), CPB2 (9 / 3024), DDX60 (10 / 319), PEX5L (11 / 740), TAF5L (13 / 348), GPX7 (14 / 606), PCDHGA1 (15 / 92), ABCC5 (16 / 524), ZXDC (17 / 572), COL1A1 (18 / 339), DNTT (19 / 133), CP (20 / 400), HCAR3 (21 / 275), CSNK1E (22 / 485), SLC25A33 (24 / 93), SMARCA1 (26 / 5121)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): STK32A (1 / 236), GPER1 (2 / 1492), PTPN11 (3 / 18511), ANKRD42 (6 / 38), LRRC34 (8 / 406), ODF2 (9 / 37), SLCO1C1 (10 / 1300), SOX2 (11 / 1462), PTK6 (13 / 587), PATZ1 (14 / 6143), KCNG3 (16 / 32), PLXNC1 (17 / 839), MYRIP (18 / 145), FER1L6 (19 / 13244), MPHOSPH8 (20 / 34), GNRH1 (21 / 377), MMGT1 (22 / 155), IZUMO4 (23 / 1095), LMO4 (24 / 655), GJB6 (25 / 2502)

## BARCS calls

Genes at FDR 0.05: 3; at FDR 0.10: 3. Top 15: HNF4A, INTS4, SEMG2, KCNJ8, OR2H1, CAPN6, BAHD1, CCDC66, CPB2, DDX60, PEX5L, EPHA1, TAF5L, GPX7, PCDHGA1
