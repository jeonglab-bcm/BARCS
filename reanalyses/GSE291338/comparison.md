# BARCS versus published results

BARCS genes: `results/palbo_vs_dmso/genes.csv` (17982 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| RB1 | 387 | 17982 | 1.896 | 0.00059 | 0.027 |
| HNRNPU | 4 | 17982 | 2.791 | 1.9e-09 | 8.6e-06 |
| CEBPE | 6 | 17982 | 2.724 | 5.2e-09 | 1.4e-05 |
| BAX | 15218 | 17982 | 0.033 | 0.75 | 0.89 |
| IKZF1 | 117 | 17982 | 2.966 | 5e-05 | 0.0077 |

## Agreement with the published table

Published: `paper/mmc2.xls` (score `min_fdr`, lower is stronger); 2346 genes, 2346 shared with BARCS.

Spearman correlation of gene scores: **0.12**


Effect direction agreement: 71.7% of 2346 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 9 | 0.22 | 16 | 16 |
| 50 | 14 | 0.16 | 36 | 36 |
| 100 | 26 | 0.15 | 74 | 74 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): UBE2E1 (3 / 91), STAG2 (5 / 61), SIAH1 (8 / 44), PAGR1 (9 / 164), DCAF15 (13 / 542), MDM4 (14 / 218), SLC35A1 (15 / 81), NFATC2IP (17 / 919), PPP1R8 (20 / 69), NUP188 (21 / 90), RREB1 (22 / 284), TIAL1 (23 / 155), ASB3 (24 / 35), MLLT6 (25 / 384), HNRNPD (26 / 1127), CCNL1 (27 / 34)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): RPS15A (1 / 190), RIMBP3B (4 / 7563), PLSCR5 (7 / 1649), NPS (9 / 12939), BCOR (11 / 804), ORC2 (12 / 8047), MEOX1 (13 / 2671), DYRK1A (15 / 96), NFRKB (17 / 2936), TMEM167B (18 / 4247), PDCD10 (19 / 404), UBD (20 / 8855), ARL14EP (21 / 7503), RANBP1 (22 / 233), TIPRL (24 / 32), CSE1L (25 / 709)

## BARCS calls

Genes at FDR 0.05: 745; at FDR 0.10: 1525. Top 15: ZNF395, KMT2D, UBE2E1, HNRNPU, STAG2, CEBPE, HIF1A, SIAH1, PAGR1, INO80D, ZNF217, RBL2, DCAF15, MDM4, SLC35A1
