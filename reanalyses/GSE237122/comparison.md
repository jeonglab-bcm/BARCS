# BARCS versus published results

BARCS genes: `results/SARS2_vs_uninfected/genes.csv` (19049 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ACE2 | 1 | 19049 | 4.197 | 4.9e-12 | 9.3e-08 |
| AHR | 2 | 19049 | 1.899 | 0.00057 | 1 |

## Agreement with the published table

Published: `paper/mageck_SARS2.tsv` (score `pos_score`, lower is stronger); 19107 genes, 19023 shared with BARCS.

Spearman correlation of gene scores: **0.71**


Effect direction agreement: 95.9% of 19023 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 7 | 0.16 | 18 | 18 |
| 50 | 11 | 0.12 | 39 | 39 |
| 100 | 28 | 0.16 | 72 | 72 |
| 200 | 67 | 0.20 | 133 | 133 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): SLC22A16 (3 / 75), FRMD6 (4 / 276), WDR60 (6 / 62), GATA4 (7 / 86), ALKBH6 (8 / 50), NMB (9 / 536), SERPINA9 (10 / 53), ABLIM3 (11 / 180), PRKAG3 (12 / 1615), ADAMTS16 (14 / 164), MIEF2 (15 / 108), MAST2 (16 / 333), EP300 (18 / 111), NMNAT3 (19 / 365), PRNP (21 / 413), NDUFB3 (22 / 52), FAM53A (24 / 148), COQ5 (25 / 65)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): CLEC18A (3 / 2650), TNNI1 (4 / 2200), TPRG1L (5 / 2495), ZNF579 (9 / 158), SMIM6 (10 / 239), MAGEB2 (11 / 138), MAML1 (12 / 104), KDM5C (13 / 1507), SH2B3 (15 / 113), AK2 (16 / 2779), CMTM6 (17 / 687), SEBOX (18 / 513), CHL1 (19 / 1086), LANCL3 (21 / 849), MPG (22 / 5399), RPUSD2 (23 / 436), TNFSF13 (24 / 246), TAF9 (25 / 1324)

## BARCS calls

Genes at FDR 0.05: 1; at FDR 0.10: 1. Top 15: ACE2, AHR, SLC22A16, FRMD6, RWDD1, WDR60, GATA4, ALKBH6, NMB, SERPINA9, ABLIM3, PRKAG3, FAM83F, ADAMTS16, MIEF2
