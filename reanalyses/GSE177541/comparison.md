# BARCS versus published results

BARCS genes: `results/SARS2_vs_T0/genes.csv` (19415 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TP53 | 2 | 19415 | 2.914 | 2.3e-14 | 2.2e-10 |
| CDKN1A | 1 | 19415 | 2.618 | 2.4e-16 | 4.6e-12 |
| ACE2 | 7 | 19415 | 3.550 | 2.1e-12 | 5.9e-09 |
| RAD54L2 | 21 | 19415 | 1.998 | 9.4e-08 | 8.7e-05 |
| HRK | 70 | 19415 | 1.542 | 1.1e-05 | 0.0029 |
| DYRK1A | 385 | 19415 | 2.274 | 0.00055 | 0.023 |
| DPF2 | 64 | 19415 | 1.871 | 8.7e-06 | 0.0024 |

## Agreement with the published table

Published: `paper/vero_sars_mageck.tsv` (score `pos_score`, lower is stronger); 19415 genes, 19412 shared with BARCS.

Spearman correlation of gene scores: **0.77**


Effect direction agreement: 84.6% of 19412 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 10 | 0.33 | 10 | 10 |
| 50 | 20 | 0.25 | 30 | 30 |
| 100 | 45 | 0.29 | 55 | 55 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): TMEM41B (10 / 31), PSENEN (12 / 28), B4GALT7 (13 / 33), SLC2A6 (14 / 211), OAZ2 (15 / 82), PSMB10 (16 / 210), UBALD2 (17 / 186), FGFR2 (18 / 26), ZEB1 (20 / 61), TPD52L1 (22 / 67)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): COL17A1 (8 / 1597), HRK (9 / 70), GPATCH8 (12 / 37), DPF2 (13 / 64), DYRK1A (14 / 385), PA2G4 (16 / 266), AMOTL2 (17 / 62), C3orf80 (20 / 198), A4GALT (21 / 792), AIG1 (22 / 6297)

## BARCS calls

Genes at FDR 0.05: 855; at FDR 0.10: 1614. Top 15: CDKN1A, TP53, C16orf74, multiKO_ENSCSAG00000011099_ENSCSAG00000011104, PLN, ENSCSAG00000006894, ACE2, SLC35B2, CDK4, TMEM41B, PTX3, PSENEN, B4GALT7, SLC2A6, OAZ2
