# BARCS versus published results

BARCS genes: `results/proinsulin_hi_vs_lo/genes.csv` (21713 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Pcsk1 | 1 | 21713 | 3.095 | 1.2e-32 | 2.6e-28 |
| Cpe | 2 | 21713 | 1.355 | 4e-26 | 4.3e-22 |
| Pdia6 | 13 | 21713 | -1.824 | 1.2e-09 | 2e-06 |
| Furin | 3 | 21713 | 1.506 | 2.7e-13 | 1.6e-09 |
| Madd | 21 | 21713 | 0.748 | 1.1e-08 | 1.1e-05 |
| Yipf5 | 8 | 21713 | -1.619 | 1.9e-11 | 5.1e-08 |
| Hid1 | 17 | 21713 | 0.776 | 3.1e-09 | 3.9e-06 |

## Agreement with the published table

Published: `paper/significant_genes.tsv` (score `abs_log2fc`, higher is stronger); 84 genes, 84 shared with BARCS.

Spearman correlation of gene scores: **0.27**


Effect direction agreement: 95.2% of 84 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 9 | 0.22 | 16 | 16 |
| 50 | 30 | 0.43 | 20 | 20 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Slc38a10 (5 / 28), Paxip1 (6 / 37), Dpagt1 (7 / 36), Heatr3 (9 / 42), Depdc5 (10 / 57), Dkc1 (11 / 68), Sec24c (12 / 48), Sec22b (14 / 38), Hid1 (17 / 59), Nrbp1 (19 / 33), BC005624 (20 / 52), Ppp1r8 (22 / 47), Commd7 (23 / 58), Prkar1a (24 / 55), Pdcd10 (28 / 72), Mdn1 (29 / 64)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Rpl7 (7 / 630), Rer1 (8 / 190), Tram1 (9 / 47), Ssbp3 (11 / 70), Tmem161b (12 / 127), Vps29 (13 / 62), Nop56 (14 / 34), AA987161 (16 / 1123), Tsku (18 / 59), Irf2bp2 (19 / 657), Olfr1475 (20 / 378), Taf1c (21 / 138), Ftsj3 (22 / 42), Ccdc101 (23 / 318), Slc39a7 (24 / 40), Ube2cbp (25 / 1864)

## BARCS calls

Genes at FDR 0.05: 206; at FDR 0.10: 356. Top 15: Pcsk1, Cpe, Furin, Rbm18, Slc38a10, Paxip1, Dpagt1, Yipf5, Heatr3, Depdc5, Dkc1, Sec24c, Pdia6, Sec22b, Smc3
