# BARCS versus published results

BARCS genes: `results/KO_T_vs_noT_D11/genes.csv` (1948 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PRMT7 | 119 | 1948 | -0.054 | 0.01 | 0.16 |
| CFLAR | 8 | 1948 | -0.351 | 2.3e-16 | 5.6e-14 |
| CREBBP | 12 | 1948 | -0.320 | 1.5e-12 | 2.5e-10 |
| IRF1 | 26 | 1948 | 0.177 | 1.9e-05 | 0.0014 |
| ATF7IP | 224 | 1948 | -0.050 | 0.036 | 0.31 |
| CASP8 | 10 | 1948 | 0.276 | 4.8e-13 | 9.3e-11 |
| IFNGR1 | 2 | 1948 | 0.438 | 3e-30 | 2.9e-27 |
| IFNGR2 | 1 | 1948 | 0.501 | 6.2e-36 | 1.2e-32 |
| JAK1 | 18 | 1948 | 0.192 | 9.9e-07 | 0.00011 |
| JAK2 | 6 | 1948 | 0.194 | 2.4e-18 | 7.7e-16 |
| HLA-A | 3 | 1948 | 0.232 | 1.8e-23 | 1.2e-20 |
| TAP1 | 11 | 1948 | 0.231 | 7.4e-13 | 1.3e-10 |
| CD58 | 13 | 1948 | 0.293 | 3.3e-12 | 5e-10 |

## Agreement with the published table

Published: `paper/ko_tcell.tsv` (score `p`, lower is stronger); 1948 genes, 1948 shared with BARCS.

Spearman correlation of gene scores: **0.49**


Effect direction agreement: 74.3% of 1948 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 17 | 0.52 | 8 | 8 |
| 50 | 33 | 0.49 | 17 | 17 |
| 100 | 55 | 0.38 | 45 | 45 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): METAP2 (5 / 26), TAP1 (11 / 29), TAP2 (15 / 90), JAK1 (18 / 35), NF1 (20 / 36), HNRNPM (21 / 255), MAEA (22 / 31), SP3 (24 / 40)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): STK11 (9 / 27), CLK1 (13 / 65), LIN54 (18 / 32), AC092069.1 (21 / 189), RP11-14D22.2 (22 / 51), SUPT6H (23 / 41), HNRNPC (24 / 42), SRSF9 (25 / 35)

## BARCS calls

Genes at FDR 0.05: 52; at FDR 0.10: 88. Top 15: IFNGR2, IFNGR1, HLA-A, ESR1, METAP2, JAK2, GATA3, CFLAR, PTEN, CASP8, TAP1, CREBBP, CD58, EP300, TAP2
