# BARCS versus published results

BARCS genes: `results/day12_vs_plasmid/genes.csv` (1682 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ZBTB11 | 26 | 1682 | -2.652 | 3e-05 | 0.0012 |
| ZFP131 | 71 | 1682 | -1.619 | 0.00014 | 0.0026 |

## Agreement with the published table

Published: `paper/TableS2_mageck.tsv` (score `Mageck_pvalue`, lower is stronger); 302 genes, 302 shared with BARCS.

Spearman correlation of gene scores: **0.70**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 32 | 0.47 | 18 | 18 |
| 100 | 74 | 0.59 | 26 | 26 |
| 200 | 170 | 0.74 | 30 | 30 |
| 300 | 298 | 0.99 | 2 | 2 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): POLR2E (2 / 82), GTF3C3 (7 / 68), ZZZ3 (9 / 83), COPS5 (19 / 69), CHD4 (20 / 56), ANKRD49 (22 / 81), SAP18 (24 / 302), HMGB2 (29 / 127), AATF (31 / 269), SFPQ (32 / 89), MED14 (34 / 300), ALYREF (35 / 52), ERCC2 (36 / 63), HTATSF1 (40 / 80), GTF2H4 (44 / 142), POLR2C (45 / 198), TIMELESS (46 / 64), POLR1A (49 / 288)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): TTF2 (2 / 118), RAD51 (8 / 70), KMT2B (9 / 66), SRSF3 (10 / 102), KAT7 (12 / 84), HNRNPK (21 / 202), PHF5A (22 / 78), PDCD11 (23 / 127), PREB (26 / 86), RBM39 (27 / 62), DDX5 (36 / 55), GM14391 (37 / 64), POLR3H (38 / 73), SUB1 (40 / 85), SUPT3 (42 / 112), SREBF2 (46 / 179), ZIC3 (47 / 80), TCEB1 (49 / 61)

## BARCS calls

Genes at FDR 0.05: 277; at FDR 0.10: 313. Top 15: TRIM28, POLR2E, CNOT3, SNAPC1, SRSF1, ABT1, GTF3C3, CXXC1, ZZZ3, PNN, POLR2I, POLR1B, NDNL2, DDB1, PHF23
