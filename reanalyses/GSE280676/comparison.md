# BARCS versus published results

BARCS genes: `results/day16_vs_day1/genes.csv` (603 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TP53 | 2 | 603 | 2.196 | 1.5e-05 | 0.00045 |
| PTEN | 1 | 603 | 0.820 | 3.5e-06 | 0.00014 |
| VGLL4 | 3 | 603 | 0.698 | 9.3e-05 | 0.0019 |
| MPC1 | 18 | 603 | 0.169 | 0.13 | 0.31 |
| MPC2 | 80 | 603 | 0.331 | 0.5 | 0.71 |
| SMAD3 | 31 | 603 | 0.255 | 0.2 | 0.41 |
| SMAD4 | 4 | 603 | 1.071 | 0.0092 | 0.059 |
| SMAD5 | 42 | 603 | 0.455 | 0.26 | 0.48 |
| RUNX1 | 112 | 603 | 0.043 | 0.64 | 0.81 |

## Agreement with the published table

Published: `paper/mageck_day16.csv` (score `pos|score`, lower is stronger); 603 genes, 603 shared with BARCS.

Spearman correlation of gene scores: **0.73**


Effect direction agreement: 76.6% of 603 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 6 | 0.43 | 4 | 4 |
| 25 | 11 | 0.28 | 14 | 14 |
| 50 | 28 | 0.39 | 22 | 22 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): SMAD4 (4 / 13), INSL6 (5 / 26), NLK (8 / 65), ZKSCAN1 (10 / 145)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): IZUMO3 (4 / 25), TNNI2 (5 / 26), KCNMB1 (7 / 35), TEX30 (8 / 46)

## BARCS calls

Genes at FDR 0.05: 80; at FDR 0.10: 135. Top 15: PTEN, TP53, VGLL4, SMAD4, INSL6, ZBTB20, PDCD10, NLK, NR3C1, ZKSCAN1, FOXO4, GAD2, GAP43, RELA, OVOL2
