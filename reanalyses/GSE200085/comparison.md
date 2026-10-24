# BARCS versus published results

BARCS genes: `results/hPi_vs_control_grafts/genes.csv` (19112 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CXCL10 | 1181 | 19112 | 0.425 | 0.19 | 0.87 |
| B2M | 10254 | 19112 | -0.498 | 0.72 | 0.96 |
| HLA-A | 4015 | 19112 | 0.056 | 0.57 | 0.95 |
| TAP1 | 4005 | 19112 | 0.030 | 0.56 | 0.95 |
| TAP2 | 4191 | 19112 | 0.397 | 0.58 | 0.95 |
| STAT1 | 51 | 19112 | 0.277 | 0.0095 | 0.57 |
| JAK1 | 8260 | 19112 | -0.112 | 0.94 | 1 |
| JAK2 | 6350 | 19112 | 0.022 | 0.83 | 0.98 |

## Agreement with the published table

Published: `paper/invivo_screen.tsv` (score `signed_score`, higher is stronger); 11689 genes, 11225 shared with BARCS.

Spearman correlation of gene scores: **0.89**


Effect direction agreement: 84.8% of 11225 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 4 | 0.09 | 21 | 21 |
| 50 | 12 | 0.14 | 38 | 38 |
| 100 | 30 | 0.18 | 70 | 70 |
| 150 | 50 | 0.20 | 100 | 100 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): TOR2A (7 / 48), UVRAG (12 / 38), UPP1 (13 / 139), HERC4 (16 / 56), COMTD1 (18 / 242), CSDE1 (20 / 79), PRKCD (22 / 64), MTFP1 (23 / 120), ZNF383 (25 / 67), COLGALT1 (27 / 97), FBXW4 (28 / 153), DCTN1 (30 / 212), DCLRE1C (31 / 100), SETD9 (32 / 74), UNC5D (35 / 181), HEATR3 (37 / 35), CREB3L4 (38 / 233), TRIM33 (39 / 124), ATP6V1B2 (40 / 54), BATF (41 / 99), ZNF568 (42 / 77)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): CXCL10 (1 / 1181), ATXN1 (2 / 1367), HNRNPA1 (3 / 5606), EEA1 (4 / 2662), SMC6 (5 / 1970), RECQL (6 / 1827), MVK (8 / 872), KLF12 (9 / 43), KBTBD6 (10 / 18426), FEN1 (13 / 50), M6PR (14 / 2367), ZNF613 (15 / 12077), MMP24 (16 / 200), URB1 (18 / 105), LGALS8 (19 / 938), FASTKD1 (20 / 133), SATL1 (22 / 67), SH3BP4 (23 / 1406), KXD1 (24 / 3329), RNF149 (26 / 7581), CNPY2 (27 / 1675)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 1. Top 15: ZNF14, IGSF11, HTR1A, ZDHHC6, ZGLP1, TRAPPC5, TOR2A, PRR21, TCEB3CL2, FSD1, CCDC78, UVRAG, UPP1, TGM6, GPR176
