# BARCS versus published results

BARCS genes: `results/palbo_vs_dmso/genes.csv` (17976 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| RB1 | 1187 | 17976 | 1.896 | 0.0059 | 0.089 |
| HNRNPU | 16 | 17976 | 2.791 | 1.3e-07 | 0.00013 |
| CEBPE | 3 | 17976 | 2.724 | 6.4e-09 | 2.5e-05 |
| BAX | 15187 | 17976 | 0.033 | 0.75 | 0.89 |
| IKZF1 | 109 | 17976 | 2.966 | 5.6e-05 | 0.0093 |

## Agreement with the published table

Published: `paper/mmc2.xls` (score `min_fdr`, lower is stronger); 2346 genes, 2346 shared with BARCS.

Spearman correlation of gene scores: **0.05**


Effect direction agreement: 71.4% of 2346 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 8 | 0.19 | 17 | 17 |
| 50 | 13 | 0.15 | 37 | 37 |
| 100 | 25 | 0.14 | 75 | 75 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): UBE2E1 (2 / 91), SIAH1 (4 / 44), PPP1R8 (6 / 69), PAGR1 (7 / 164), DCAF15 (11 / 542), SLC35A1 (12 / 81), NFATC2IP (13 / 919), NUP188 (17 / 90), RREB1 (18 / 284), TIAL1 (19 / 155), ASB3 (20 / 35), MLLT6 (21 / 384), HNRNPD (22 / 1127), CCNL1 (23 / 34), SAFB (25 / 73), YWHAQ (26 / 2024), AIP (27 / 571)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): RPS15A (1 / 7179), RIMBP3B (4 / 7482), AMBRA1 (5 / 40), PLSCR5 (7 / 1587), NPS (9 / 12811), BCOR (11 / 748), ORC2 (12 / 10025), MEOX1 (13 / 2679), DYRK1A (15 / 87), NFRKB (17 / 2824), TMEM167B (18 / 10124), PDCD10 (19 / 370), UBD (20 / 8772), ARL14EP (21 / 7370), RANBP1 (22 / 206), TIPRL (24 / 359), CSE1L (25 / 671)

## BARCS calls

Genes at FDR 0.05: 608; at FDR 0.10: 1350. Top 15: ZNF395, UBE2E1, CEBPE, SIAH1, HIF1A, PPP1R8, PAGR1, INO80D, ZNF217, RBL2, DCAF15, SLC35A1, NFATC2IP, AHR, UBE2A
