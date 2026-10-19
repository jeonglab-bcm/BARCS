# BARCS versus published results

BARCS genes: `results/top10_vs_static_and_next25/genes.csv` (19102 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| SPTAN1 | 26 | 19102 | -6.219 | 6.9e-05 | 0.047 |
| RAF1 | not tested | | | | |
| STIM2 | 400 | 19102 | -2.111 | 0.0075 | 0.29 |
| MYL2 | 232 | 19102 | -6.245 | 0.0031 | 0.22 |
| ACTA1 | 4152 | 19102 | -2.941 | 0.35 | 0.85 |
| KRAS | 1002 | 19102 | -0.742 | 0.035 | 0.47 |

## Agreement with the published table

Published: `paper/mageck_mle.tsv` (score `wald_p`, lower is stronger); 19112 genes, 19074 shared with BARCS.

Spearman correlation of gene scores: **0.18**


Effect direction agreement: 76.3% of 19074 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 9 | 0.10 | 41 | 41 |
| 100 | 22 | 0.12 | 78 | 78 |
| 200 | 62 | 0.18 | 138 | 138 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): AADAC (3 / 201), C18orf65 (4 / 124), MSH3 (5 / 459), FBXO15 (6 / 70), TMEM5 (7 / 150), PLA1A (8 / 156), NRN1 (9 / 3029), EXOSC7 (10 / 361), LDLRAD4 (11 / 543), SLC2A12 (12 / 118), RHNO1 (14 / 1058), LOC113230 (15 / 131), CPXCR1 (16 / 169), SIAH3 (17 / 833), LY6G6F (18 / 110), HGFAC (19 / 509), TLL2 (20 / 139), IFIT5 (22 / 248), FBXO21 (24 / 6147), G0S2 (27 / 599), TAZ (28 / 79), UGT2B4 (29 / 382), IFIT2 (30 / 920), C8B (31 / 234), MFAP1 (32 / 16115)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): ERICH2 (2 / 1184), TMC8 (3 / 306), LENEP (5 / 851), BATF3 (6 / 109), EVX1 (8 / 242), SYPL2 (9 / 1855), ZNF737 (10 / 120), MGC57346-CRHR1 (13 / 350), BCL2 (14 / 787), ASMTL (16 / 82), PPEF2 (17 / 1076), FKBP9 (20 / 359), ADAM17 (21 / 2275), ZC3H12C (23 / 704), ROMO1 (24 / 189), HTR1B (25 / 615), KLF2 (27 / 2108), ZAP70 (30 / 61), AOC1 (34 / 110), COL4A6 (35 / 800), LRRC73 (37 / 67), ARL3 (39 / 2176), PDCD2 (40 / 250), LOC101928436 (41 / 5699), ADRA1B (42 / 1583)

## BARCS calls

Genes at FDR 0.05: 29; at FDR 0.10: 91. Top 15: APBA2, OR8H3, AADAC, C18orf65, MSH3, FBXO15, TMEM5, PLA1A, NRN1, EXOSC7, LDLRAD4, SLC2A12, PADI3, RHNO1, LOC113230
