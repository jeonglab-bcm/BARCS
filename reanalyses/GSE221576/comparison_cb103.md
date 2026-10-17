# BARCS versus published results

BARCS genes: `results/CB103_vs_DMSO/genes.csv` (20708 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PIK3R1 | 1 | 20708 | 0.645 | 5.9e-08 | 0.00045 |
| JAK1 | 4 | 20708 | -2.326 | 8.7e-08 | 0.00045 |
| IL7R | 12 | 20708 | -1.302 | 8.9e-06 | 0.015 |
| NOTCH1 | 7 | 20708 | -0.789 | 2e-06 | 0.0057 |
| CDK6 | 2357 | 20708 | -0.253 | 0.052 | 0.46 |

## Agreement with the published table

Published: `paper/cb103_vs_dmso.tsv` (score `p`, lower is stronger); 18961 genes, 18937 shared with BARCS.

Spearman correlation of gene scores: **0.39**


Effect direction agreement: 77.3% of 18937 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 9 | 0.22 | 16 | 16 |
| 50 | 19 | 0.23 | 31 | 31 |
| 100 | 27 | 0.16 | 73 | 73 |
| 200 | 59 | 0.17 | 141 | 141 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): PIK3R1 (1 / 147), EXTL3 (2 / 45), NDST3 (5 / 169), RUNX2 (10 / 3403), EXT1 (15 / 39), WASH1 (16 / 40), FAM111B (22 / 1049), C3orf17 (23 / 814), MSI2 (24 / 78), LPCAT2 (26 / 64), B4GALT7 (28 / 676), PSENEN (29 / 56), TM9SF3 (33 / 767), SSNA1 (36 / 466), SLC25A6_X (37 / 28), DROSHA (39 / 391)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): hsa-mir-1299 (3 / 233), PDP1 (4 / 1696), hsa-mir-1273a (5 / 227), hsa-mir-566 (7 / 61), RBX1 (8 / 248), hsa-mir-8086 (10 / 301), BCL2L2-PABPN1 (12 / 86), FBXL17 (14 / 56), AAK1 (17 / 881), PF4 (18 / 4375), DCAF13 (19 / 1076), OCEL1 (20 / 6074), hsa-mir-1273d (21 / 139), FDX1L (22 / 55), ECH1 (23 / 3058), DDI2 (25 / 311)

## BARCS calls

Genes at FDR 0.05: 37; at FDR 0.10: 88. Top 15: PIK3R1, EXTL3, PPP4C, JAK1, NDST3, BRF1, NOTCH1, PTPN23, TRMT112, RUNX2, ARFRP1, IL7R, RNF144B, RPL17, EXT1
