# BARCS versus published results

BARCS genes: `results/poolB_FdU_vs_DMSO_E/genes.csv` (4986 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| EXO1 | 19 | 4986 | -0.719 | 6.2e-13 | 1.2e-10 |
| MSH2 | not tested | | | | |
| LIG1 | not tested | | | | |

## Agreement with the published table

Published: `paper/supp1_poolB.csv` (score `lfc`, lower is stronger); 5135 genes, 4986 shared with BARCS.

Spearman correlation of gene scores: **0.96**


Effect direction agreement: 95.9% of 4986 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 13 | 0.35 | 12 | 12 |
| 50 | 32 | 0.47 | 18 | 18 |
| 100 | 69 | 0.53 | 31 | 31 |
| 200 | 144 | 0.56 | 56 | 56 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): SP3 (9 / 45), ANKRD52 (13 / 42), RBM33 (16 / 49), FANCB (17 / 28), ALMS1 (18 / 44), EXO1 (19 / 37), SZRD1 (20 / 32), E2F3 (21 / 71), DDI2 (22 / 68), SGO2 (23 / 41), PCM1 (24 / 62), PDCD5 (25 / 58)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): NSMCE3 (6 / 65), CFLAR (7 / 28), TUBB (9 / 36), GABPA (13 / 40), SKA2 (16 / 108), RTF1 (17 / 176), PSMG2 (18 / 26), ISG15 (19 / 85), MOB4 (20 / 29), NPM1 (21 / 61), NUP43 (22 / 46), GOLGA6D (23 / 71)

## BARCS calls

Genes at FDR 0.05: 311; at FDR 0.10: 437. Top 15: HEXIM1, HUS1, SLX4, MED16, RAD9A, FANCM, MAD2L2, RAD17, SP3, WDR73, NCAPG2, KBTBD2, ANKRD52, CKS1B, ELOB
