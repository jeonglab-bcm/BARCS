# BARCS versus published results

BARCS genes: `results/killing_vs_prekill/genes.csv` (17999 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| BTN3A1 | 1 | 17999 | 1.363 | 3e-20 | 3.5e-17 |
| BTN2A1 | 5 | 17999 | 1.193 | 5.1e-10 | 1.8e-08 |
| BTN3A2 | 7 | 17999 | 1.038 | 1.9e-08 | 4.5e-07 |
| IRF1 | 3 | 17999 | 1.085 | 1.7e-13 | 1.7e-11 |
| SPIB | 2 | 17999 | 0.957 | 1.1e-18 | 6.7e-16 |
| NLRC5 | 9 | 17999 | 0.617 | 1e-07 | 2.1e-06 |
| HMGCR | 64 | 17999 | 0.401 | 0.0049 | 0.04 |

## Agreement with the published table

Published: `paper/S1.xlsx` (score `pos|score`, lower is stronger); 18006 genes, 17999 shared with BARCS.

Spearman correlation of gene scores: **0.80**


Effect direction agreement: 87.1% of 17999 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 37 | 0.59 | 13 | 13 |
| 100 | 69 | 0.53 | 31 | 31 |
| 200 | 116 | 0.41 | 84 | 84 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): FOXP1 (17 / 34), JAK1 (18 / 29), SLC37A3 (22 / 66), ZNF699 (24 / 59), XPNPEP1 (25 / 44)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): SIRT1 (15 / 26), MGA (19 / 30), ZBTB7A (21 / 27), RCE1 (22 / 51), CSNK2A1 (24 / 47)

## BARCS calls

Genes at FDR 0.05: 2279; at FDR 0.10: 2455. Top 15: BTN3A1, SPIB, IRF1, FBXW7, BTN2A1, SPI1, BTN3A2, RFXAP, NLRC5, CREBBP, ACAT2, SQLE, IRF8, GLTSCR1, SLC25A19
