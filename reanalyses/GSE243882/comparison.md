# BARCS versus published results

BARCS genes: `results/MCF7_3D_vs_2D/genes.csv` (20703 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| hsa-mir-4787 | 2814 | 20703 | -0.895 | 0.21 | 1 |
| ARHGAP17 | 1153 | 20703 | 0.421 | 0.11 | 1 |
| FOXO3 | 2236 | 20703 | -0.941 | 0.18 | 1 |
| PDCD4 | 7790 | 20703 | 0.054 | 0.46 | 1 |

## Agreement with the published table

Published: `paper/supp1_MCF7.tsv` (score `abs_diff`, higher is stronger); 20708 genes, 20702 shared with BARCS.

Spearman correlation of gene scores: **0.49**


Effect direction agreement: 70.1% of 20702 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 2 | 0.02 | 48 | 48 |
| 100 | 13 | 0.07 | 87 | 87 |
| 200 | 40 | 0.11 | 160 | 160 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): B3GNT5 (1 / 3622), SLC30A8 (3 / 217), PHF6 (4 / 1273), TMEFF1 (5 / 263), OMP (6 / 2185), ZNF544 (7 / 1830), SLC25A5 (8 / 1573), MAPK7 (9 / 722), C1QTNF2 (10 / 1045), NMU (11 / 2861), SLC44A5 (12 / 79), LRRC37B (14 / 80), SPERT (15 / 962), hsa-mir-873 (16 / 199), USP17L11 (17 / 2343), TIAM2 (18 / 9398), GPR75-ASB3 (19 / 963), C16orf45 (20 / 9170), ASB10 (21 / 4334), REXO1 (22 / 669), SELT (23 / 397), AP1G2 (24 / 125), CLUL1 (25 / 2865), PTPRCAP (26 / 189), NPTX1 (27 / 364)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): hsa-mir-1185-2 (2 / 159), hsa-mir-7978 (3 / 118), hsa-mir-3669 (4 / 156), hsa-mir-1206 (6 / 14267), RPL17-C18orf32 (7 / 14346), hsa-mir-1255b-1 (8 / 691), hsa-mir-3925 (9 / 4155), hsa-mir-371b (10 / 4033), hsa-mir-3673 (11 / 8378), HIST2H2AA4 (14 / 10225), hsa-mir-8088 (15 / 228), hsa-mir-1322 (16 / 14495), hsa-mir-6766 (17 / 1527), hsa-mir-517c (18 / 4150), LIMS3L (19 / 4340), AGAP5 (20 / 766), hsa-mir-4442 (21 / 535), hsa-mir-423 (22 / 4187), hsa-mir-548ak (23 / 7773), hsa-mir-3672 (24 / 3037), hsa-mir-486-2 (25 / 9562), PPIAL4C (26 / 948), hsa-mir-548ah (27 / 4634), hsa-mir-3118-1 (28 / 1095), hsa-mir-1972-2 (29 / 5194)

## BARCS calls

Genes at FDR 0.05: 10; at FDR 0.10: 14. Top 15: B3GNT5, PTGES3L-AARSD1, SLC30A8, PHF6, TMEFF1, OMP, ZNF544, SLC25A5, MAPK7, C1QTNF2, NMU, SLC44A5, ATP8B1, LRRC37B, SPERT
