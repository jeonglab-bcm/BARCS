# BARCS versus published results

BARCS genes: `results/d7_low_vs_high/genes.csv` (20915 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| EIF2A | 6 | 20915 | 0.340 | 1.3e-05 | 0.018 |

## Agreement with the published table

Published: `paper/mmc2.xlsx` (score `pos|score`, lower is stronger); 21915 genes, 20891 shared with BARCS.

Spearman correlation of gene scores: **0.65**


Effect direction agreement: 99.5% of 20891 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 5 | 0.33 | 5 | 5 |
| 25 | 10 | 0.25 | 15 | 15 |
| 50 | 27 | 0.37 | 23 | 23 |
| 100 | 63 | 0.46 | 37 | 37 |
| 200 | 98 | 0.32 | 102 | 102 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): POLR2D (2 / 29), ASH2L (5 / 12), HSPA8 (7 / 11), CRCP (9 / 32), TIGIT (10 / 38)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): GTF3C1 (6 / 34), GTF2E2 (7 / 1098), ARMCX5 (8 / 17), POLR3H (9 / 16), NUDT21 (10 / 12)

## BARCS calls

Genes at FDR 0.05: 24; at FDR 0.10: 43. Top 15: FARSB, POLR2D, hsa-mir-302f, DARS, ASH2L, EIF2A, HSPA8, DAP3, CRCP, TIGIT, ETF1, NUDT21, RNPS1, YARS, RPP21
