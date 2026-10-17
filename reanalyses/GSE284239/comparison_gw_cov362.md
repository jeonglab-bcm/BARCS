# BARCS versus published results

BARCS genes: `results/gw_tng348_vs_dmso/genes.csv` (19096 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PARP1 | 6 | 19096 | -2.107 | 1.9e-06 | 0.001 |
| RAD18 | 19091 | 19096 | 1.993 | 3.5e-14 | 1.1e-10 |

## Agreement with the published table

Published: `paper/tableS9.csv` (score `signed_score`, lower is stronger); 19119 genes, 19094 shared with BARCS.

Spearman correlation of gene scores: **0.31**


Effect direction agreement: 64.2% of 19094 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 8 | 0.25 | 12 | 12 |
| 50 | 14 | 0.16 | 36 | 36 |
| 100 | 22 | 0.12 | 78 | 78 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): CREBBP (3 / 3497), PARP1 (6 / 84), PAGR1 (7 / 21), CHD1L (8 / 1298), PAXIP1 (9 / 69), BRCC3 (10 / 65), SLC25A19 (12 / 134), MBD3 (13 / 9870), PCNP (17 / 11532), EXO1 (18 / 216), TDP1 (19 / 37), CSNK2A1 (20 / 43)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): UBE2D2 (5 / 94), FAM175A (6 / 103), GTPBP10 (7 / 22), KIAA0101 (8 / 370), ALKBH1 (9 / 794), HNRNPA2B1 (10 / 188), ADCYAP1R1 (13 / 273), UBE3C (16 / 305), ATF7IP (17 / 706), KIAA0020 (18 / 4891), FAM167B (19 / 864), TMEM248 (20 / 241)

## BARCS calls

Genes at FDR 0.05: 80; at FDR 0.10: 102. Top 15: UROD, OGFR, CREBBP, UBE2D3, UIMC1, PARP1, PAGR1, CHD1L, PAXIP1, BRCC3, BRE, SLC25A19, MBD3, LIG1, KCTD5
