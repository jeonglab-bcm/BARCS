# BARCS versus published results

BARCS genes: `results/poolD_FdU_vs_DMSO_E/genes.csv` (4952 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| EXO1 | not tested | | | | |
| MSH2 | 68 | 4952 | -0.470 | 2.1e-06 | 8e-05 |
| LIG1 | 86 | 4952 | -0.439 | 6.9e-06 | 0.00021 |

## Agreement with the published table

Published: `paper/supp1_poolD.csv` (score `lfc`, lower is stronger); 5134 genes, 4944 shared with BARCS.

Spearman correlation of gene scores: **0.94**


Effect direction agreement: 93.5% of 4944 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 17 | 0.52 | 8 | 8 |
| 50 | 33 | 0.49 | 17 | 17 |
| 100 | 67 | 0.50 | 33 | 33 |
| 200 | 134 | 0.50 | 66 | 66 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): TGIF1 (14 / 41), CNOT6 (15 / 77), POLE3 (17 / 26), TOX4 (18 / 56), MCM9 (19 / 35), LARP1 (20 / 37), FANCC (21 / 33), RSBN1L (25 / 61)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): PSMD4 (3 / 96), RAD1 (7 / 31), RBM39 (12 / 144), MED24 (13 / 53), MED23 (15 / 39), PSMD3 (16 / 589), COPS4 (19 / 262), LARP7 (23 / 26)

## BARCS calls

Genes at FDR 0.05: 491; at FDR 0.10: 646. Top 15: OGFR, FANCA, NBN, ERCC4, FAAP24, YPEL5, RNASEH2B, FAAP100, CENPX, CENPS-CORT, RFWD3, WDR61, CCNF, TGIF1, CNOT6
