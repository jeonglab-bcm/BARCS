# BARCS versus published results

BARCS genes: `results/inx315_vs_dmso/genes.csv` (18006 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CCNB1 | 1 | 18006 | -3.475 | 3e-06 | 0.048 |
| FOXM1 | 2 | 18006 | -2.115 | 1.1e-05 | 0.063 |
| MTR | 3 | 18006 | -2.766 | 7.1e-05 | 0.26 |

## Agreement with the published table

Published: `paper/SupplementaryData2.xlsx` (score `normZ`, lower is stronger); 18049 genes, 17980 shared with BARCS.

Spearman correlation of gene scores: **0.94**


Effect direction agreement: 82.1% of 17980 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 16 | 0.67 | 4 | 4 |
| 50 | 39 | 0.64 | 11 | 11 |
| 100 | 70 | 0.54 | 30 | 30 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): PGP (6 / 23), NUDT2 (9 / 42), DEFB119 (19 / 30), FAM49B (20 / 40)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): SENP8 (13 / 23), LIN37 (14 / 73), CDC25A (18 / 22), FAM122A (19 / 489)

## BARCS calls

Genes at FDR 0.05: 2; at FDR 0.10: 3. Top 15: CCNB1, FOXM1, MTR, PCM1, TADA2B, PGP, PDCD10, CDK8, NUDT2, TSC2, TSC1, CNTROB, CCNC, UXS1, CCNT1
