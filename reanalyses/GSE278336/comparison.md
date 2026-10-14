# BARCS versus published results

BARCS genes: `results/Lb_KRAB_day21_vs_day5/genes.csv` (199 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| RPL34 | 1 | 199 | -1.180 | 2.4e-27 | 4.7e-25 |
| MDM4 | 5 | 199 | -0.868 | 3.1e-16 | 1.2e-14 |
| RPS20 | 11 | 199 | -0.737 | 1.8e-09 | 3.2e-08 |
| SMC2 | 2 | 199 | -0.734 | 2.4e-18 | 2.4e-16 |
| XPO1 | 3 | 199 | -0.925 | 4.9e-17 | 3.3e-15 |
| SNRPE | 7 | 199 | -0.694 | 1.1e-12 | 3.1e-11 |

## Agreement with the published table

Published: `paper/SupplementaryData1.xlsx` (score `wald_Lb.KRAB`, lower is stronger); 201 genes, 198 shared with BARCS.

Spearman correlation of gene scores: **0.17**


Effect direction agreement: 92.9% of 198 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 6 | 0.43 | 4 | 4 |
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 32 | 0.47 | 18 | 18 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): RPS18 (6 / 12), CCT3 (8 / 13), SEM1 (9 / 15), RPSA (10 / 21)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): BCL2L2 (2 / 191), RPS20 (5 / 11), CHEK2-MTOR (9 / 192), LSM5 (10 / 17)

## BARCS calls

Genes at FDR 0.05: 41; at FDR 0.10: 46. Top 15: RPL34, SMC2, XPO1, RPL17, MDM4, RPS18, SNRPE, CCT3, SEM1, RPSA, RPS20, LIAS, RPS8, WDR12, RPS4X
