# BARCS versus published results

BARCS genes: `results/CRISPRi_T_vs_noT_D11/genes.csv` (1955 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PRMT7 | 38 | 1955 | -0.220 | 5.2e-08 | 2.7e-06 |
| CFLAR | 16 | 1955 | -0.132 | 3.7e-13 | 4.5e-11 |
| CREBBP | 1297 | 1955 | 0.010 | 0.58 | 0.86 |
| IRF1 | 13 | 1955 | 0.358 | 3.4e-15 | 5.1e-13 |
| ATF7IP | 8 | 1955 | 0.203 | 1.6e-22 | 4e-20 |
| CASP8 | 211 | 1955 | 0.046 | 0.015 | 0.14 |
| IFNGR1 | 1 | 1955 | 0.530 | 8.7e-98 | 1.7e-94 |
| IFNGR2 | 2 | 1955 | 0.518 | 7.6e-67 | 7.4e-64 |
| JAK1 | 18 | 1955 | 0.123 | 1.4e-11 | 1.5e-09 |
| JAK2 | 34 | 1955 | 0.191 | 3.3e-08 | 1.9e-06 |
| HLA-A | 47 | 1955 | 0.066 | 2e-06 | 8.5e-05 |
| TAP1 | 71 | 1955 | 0.138 | 6.7e-05 | 0.0019 |
| CD58 | 5 | 1955 | 0.435 | 5.4e-44 | 2.1e-41 |
| NLRC5 | 48 | 1955 | 0.159 | 2.2e-06 | 8.8e-05 |

## Agreement with the published table

Published: `paper/i_tcell.tsv` (score `p`, lower is stronger); 1955 genes, 1955 shared with BARCS.

Spearman correlation of gene scores: **0.49**


Effect direction agreement: 73.4% of 1955 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 19 | 0.61 | 6 | 6 |
| 50 | 38 | 0.61 | 12 | 12 |
| 100 | 74 | 0.59 | 26 | 26 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): OGFOD1 (10 / 84), PSMA6 (15 / 31), COX11 (19 / 41), TEFM (21 / 74), COPS8 (22 / 28), PSMB3 (24 / 195)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): EWSR1 (8 / 26), LSM6 (15 / 57), PRMT7 (17 / 38), AC007283.5 (20 / 35), EIF3D (22 / 31), SMG9 (25 / 46)

## BARCS calls

Genes at FDR 0.05: 134; at FDR 0.10: 175. Top 15: IFNGR1, IFNGR2, TOMM70, AZIN1, CD58, NEDD8, FDPS, ATF7IP, CHMP6, OGFOD1, DDA1, TGFBR2, IRF1, LMX1B, PSMA6
