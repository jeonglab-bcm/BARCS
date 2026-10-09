# BARCS versus published results

BARCS genes: `results/infected_vs_mock/genes.csv` (18856 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| DAZAP2 | 1 | 18856 | -0.856 | 2.8e-21 | 2.6e-17 |
| VTA1 | 42 | 18856 | -0.038 | 9.8e-05 | 0.013 |
| KLF5 | 6 | 18856 | -0.342 | 1.2e-12 | 1.2e-09 |

## Agreement with the published table

Published: `suppl/GSE209750_COVID-19_CRISPR_210212_C_control.gene_summary.txt.gz` (score `neg|score`, lower is stronger); 18458 genes, 18458 shared with BARCS.

Spearman correlation of gene scores: **0.68**


Effect direction agreement: 64.2% of 18458 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 38 | 0.61 | 12 | 12 |
| 100 | 67 | 0.50 | 33 | 33 |
| 200 | 115 | 0.40 | 85 | 85 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): VPS36 (21 / 73), B4GALT7 (27 / 99), CGB7 (35 / 239), WAPAL (37 / 77), DICER1 (39 / 68), ZC3H18 (40 / 137), PLSCR1 (41 / 113), TRRAP (44 / 340), SDCBP (45 / 79), ATG14 (47 / 388), AIP (48 / 67), YWHAE (50 / 54)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): CCBE1 (31 / 614), XYLT2 (36 / 80), ZCCHC14 (37 / 77), ANKS3 (38 / 68), CYP7B1 (39 / 168), NT5DC3 (41 / 183), AHR (42 / 60), LILRB1 (43 / 200), KCTD1 (47 / 87), TRPM7 (48 / 70), DCAF4L2 (49 / 101), ARID3C (50 / 129)

## BARCS calls

Genes at FDR 0.05: 197; at FDR 0.10: 257. Top 15: DAZAP2, CAB39, LY6E, PAXIP1, VPS4A, KLF5, P4HB, RFWD2, VPS28, CCDC101, TADA2B, AP2B1, CHMP1B, PDCD6IP, ARNT
