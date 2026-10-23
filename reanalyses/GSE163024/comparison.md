# BARCS versus published results

BARCS genes: `results/tdTomatoHigh_vs_plasmid/genes.csv` (18852 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| DENND4B | 1 | 18852 | 1.195 | 4.1e-26 | 7.8e-22 |
| TYROBP | 2 | 18852 | 1.809 | 1.4e-12 | 1.4e-08 |
| COL7A1 | 3 | 18852 | 0.277 | 2.4e-07 | 0.0015 |

## Agreement with the published table

Published: `suppl/GSE163024_COL7A1_CRISPRaScreen_Data.xlsx` (score `Z-score`, higher is stronger); 18854 genes, 18852 shared with BARCS.

Spearman correlation of gene scores: **0.72**


Effect direction agreement: 60.6% of 18852 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 3 | 0.18 | 7 | 7 |
| 25 | 3 | 0.06 | 22 | 22 |
| 50 | 8 | 0.09 | 42 | 42 |
| 100 | 17 | 0.09 | 83 | 83 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): DNAJC2 (4 / 36), BIVM (5 / 507), IFNE (6 / 60), CDC6 (7 / 56), STOML3 (8 / 67), CMAS (9 / 600), ZCCHC13 (10 / 27)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): SH2D1B (3 / 12357), OR6C3 (4 / 423), RNF114 (5 / 12386), ARSK (6 / 10657), PTCD2 (8 / 603), CLEC3B (9 / 3423), ZNF223 (10 / 137)

## BARCS calls

Genes at FDR 0.05: 3; at FDR 0.10: 3. Top 15: DENND4B, TYROBP, COL7A1, DNAJC2, BIVM, IFNE, CDC6, STOML3, CMAS, ZCCHC13, KRTAP1-3, IL17RB, GPT2, HDC, UBTFL1
