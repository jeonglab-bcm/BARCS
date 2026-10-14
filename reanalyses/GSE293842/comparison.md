# BARCS versus published results

BARCS genes: `results/day14_vs_day0_poolA/genes.csv` (763 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PIKFYVE | 26 | 763 | -0.487 | 0.0018 | 0.038 |
| PIK3C3 | 16 | 763 | -0.305 | 7.7e-05 | 0.0031 |
| ILK | 2 | 763 | -0.512 | 7.6e-10 | 1.4e-07 |
| PTK2 | 1 | 763 | -0.517 | 6.9e-10 | 1.4e-07 |

## Agreement with the published table

Published: `paper/TableS1.csv` (score `final`, lower is stronger); 764 genes, 763 shared with BARCS.

Spearman correlation of gene scores: **0.69**


Effect direction agreement: 72.9% of 763 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 9 | 0.82 | 1 | 1 |
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 37 | 0.59 | 13 | 13 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): CDK1 (7 / 19)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): TPR (7 / 12)

## BARCS calls

Genes at FDR 0.05: 36; at FDR 0.10: 47. Top 15: PTK2, ILK, CDK12, CHEK1, DTYMK, WEE1, CDK1, CLP1, TAF1, PKMYT1, PRKRA, TPR, CDC7, TRRAP, MAPK1
