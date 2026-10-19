# BARCS versus published results

BARCS genes: `results/OC43_vs_uninfected/genes.csv` (19040 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| AHR | 1 | 19040 | 1.475 | 0.0014 | 1 |
| EXT1 | 2 | 19040 | 3.128 | 0.009 | 1 |
| EXT2 | 6 | 19040 | 2.141 | 0.019 | 1 |
| SLC35B2 | 8 | 19040 | 2.553 | 0.037 | 1 |

## Agreement with the published table

Published: `paper/mageck_OC43.tsv` (score `pos_score`, lower is stronger); 19107 genes, 19014 shared with BARCS.

Spearman correlation of gene scores: **0.69**


Effect direction agreement: 96.6% of 19014 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 9 | 0.22 | 16 | 16 |
| 50 | 20 | 0.25 | 30 | 30 |
| 100 | 36 | 0.22 | 64 | 64 |
| 200 | 81 | 0.25 | 119 | 119 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): AHR (1 / 49), FNBP1 (4 / 377), RNF121 (9 / 305), IL25 (10 / 532), TADA2B (11 / 57), TADA1 (12 / 40), ERI1 (13 / 39), NINJ1 (14 / 42), UGDH (15 / 28), MDH1 (16 / 94), C9orf41 (17 / 538), KRT72 (18 / 139), MAGED4B (20 / 600), DNAJC5G (21 / 108), TRIP4 (22 / 59), INHBA (24 / 307)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): ADIPOQ (4 / 227), KAT2A (7 / 63), VPS41 (9 / 64), RAPGEF4 (10 / 12786), MECP2 (11 / 84), ASF1A (12 / 148), XKR3 (14 / 108), USP45 (15 / 78), CDC40 (18 / 132), COL7A1 (19 / 15242), SUPT20H (20 / 36), KLF16 (21 / 890), ZNF626 (22 / 1382), TTC33 (23 / 28), NR2F6 (24 / 6317), UBE2Q1 (25 / 221)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: AHR, EXT1, CYLC2, FNBP1, CCDC101, EXT2, EVPLL, SLC35B2, RNF121, IL25, TADA2B, TADA1, ERI1, NINJ1, UGDH
