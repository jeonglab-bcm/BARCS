# BARCS versus published results

BARCS genes: `results/palbo_vs_dmso/genes.csv` (17976 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| RB1 | 380 | 17976 | 1.896 | 0.00063 | 0.03 |
| HNRNPU | 4 | 17976 | 2.791 | 2.1e-09 | 9.5e-06 |
| CEBPE | 6 | 17976 | 2.724 | 6.4e-09 | 1.5e-05 |
| BAX | 15199 | 17976 | 0.033 | 0.75 | 0.89 |
| IKZF1 | 115 | 17976 | 2.966 | 5.6e-05 | 0.0088 |

## Agreement with the published table

Published: `paper/mmc2.xls` (score `min_fdr`, lower is stronger); 2346 genes, 2346 shared with BARCS.

Spearman correlation of gene scores: **0.10**


Effect direction agreement: 71.4% of 2346 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 9 | 0.22 | 16 | 16 |
| 50 | 14 | 0.16 | 36 | 36 |
| 100 | 26 | 0.15 | 74 | 74 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): UBE2E1 (3 / 91), STAG2 (5 / 61), SIAH1 (7 / 44), PPP1R8 (9 / 69), PAGR1 (10 / 164), DCAF15 (14 / 542), SLC35A1 (15 / 81), NFATC2IP (17 / 919), NUP188 (20 / 90), RREB1 (21 / 284), TIAL1 (22 / 155), ASB3 (23 / 35), MLLT6 (24 / 384), HNRNPD (25 / 1127), CCNL1 (26 / 34), SAFB (27 / 73)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): RPS15A (1 / 175), RIMBP3B (4 / 7529), PLSCR5 (7 / 1623), NPS (9 / 12845), BCOR (11 / 778), ORC2 (12 / 10068), MEOX1 (13 / 2724), DYRK1A (15 / 91), NFRKB (17 / 2868), TMEM167B (18 / 4175), PDCD10 (19 / 392), UBD (20 / 8822), ARL14EP (21 / 7416), RANBP1 (22 / 222), TIPRL (24 / 31), CSE1L (25 / 697)

## BARCS calls

Genes at FDR 0.05: 675; at FDR 0.10: 1437. Top 15: ZNF395, KMT2D, UBE2E1, HNRNPU, STAG2, CEBPE, SIAH1, HIF1A, PPP1R8, PAGR1, INO80D, ZNF217, RBL2, DCAF15, SLC35A1
