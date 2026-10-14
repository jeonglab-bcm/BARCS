# BARCS versus published results

BARCS genes: `results/poolA_FdU_vs_DMSO_E/genes.csv` (4853 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| UNG | 7 | 4853 | -3.199 | 1.7e-29 | 5.9e-27 |
| METTL3 | 74 | 4853 | -0.872 | 4.2e-08 | 1.7e-06 |
| METTL4 | 105 | 4853 | -0.410 | 2.4e-06 | 7.1e-05 |
| METTL14 | 91 | 4853 | -0.411 | 3.9e-07 | 1.3e-05 |
| APEX1 | 8 | 4853 | -2.511 | 2.2e-29 | 7e-27 |
| LIG1 | 10 | 4853 | -0.485 | 1.6e-24 | 4.5e-22 |

## Agreement with the published table

Published: `paper/supp1_poolA.csv` (score `lfc`, lower is stronger); 4986 genes, 4839 shared with BARCS.

Spearman correlation of gene scores: **0.97**


Effect direction agreement: 94.1% of 4839 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 18 | 0.56 | 7 | 7 |
| 50 | 36 | 0.56 | 14 | 14 |
| 100 | 74 | 0.59 | 26 | 26 |
| 200 | 164 | 0.69 | 36 | 36 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): BRD2 (9 / 30), LIG1 (10 / 97), CAD (13 / 28), USP7 (14 / 38), CDK6 (21 / 32), ZNF534 (22 / 138), SLC29A1 (23 / 39)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): VRK1 (13 / 29), UBE2C (15 / 31), DTYMK (16 / 52), INO80 (17 / 71), SETD1A (18 / 50), CCND1 (19 / 38), PRDM10 (21 / 28)

## BARCS calls

Genes at FDR 0.05: 547; at FDR 0.10: 693. Top 15: ERCC1, APEX1_2, ERCC4, UNG_2, APEX2, TYMS, UNG, APEX1, BRD2, LIG1, USP18, MARK2, CAD, USP7, UBE2H
