# BARCS versus published results

BARCS genes: `results/D4_CD200high_vs_low/genes.csv` (19674 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Cd200 | 4 | 19674 | -1.720 | 2.8e-21 | 1.4e-17 |
| Sufu | 1 | 19674 | 2.573 | 1.7e-42 | 3.4e-38 |
| Eed | 2 | 19674 | 1.869 | 1.6e-31 | 1.6e-27 |
| Ptch1 | 3 | 19674 | 1.394 | 8.2e-22 | 5.4e-18 |
| Ezh2 | 5 | 19674 | 1.246 | 4.4e-19 | 1.7e-15 |
| Dot1l | 7 | 19674 | 1.369 | 2.8e-18 | 7.8e-15 |
| Strap | 6 | 19674 | 0.982 | 1.3e-18 | 4.1e-15 |
| Arrb2 | 8 | 19674 | 0.813 | 7.1e-14 | 1.7e-10 |
| Gnas | 23 | 19674 | 0.743 | 2.5e-08 | 2.2e-05 |
| Runx2 | 31 | 19674 | -0.708 | 2.3e-07 | 0.00015 |
| Sox9 | 62 | 19674 | -0.554 | 1.4e-05 | 0.0044 |
| Prkar1a | 27 | 19674 | -0.836 | 7.6e-08 | 5.5e-05 |
| Ptpn11 | 140 | 19674 | -0.628 | 0.00024 | 0.034 |

## Agreement with the published table

Published: `paper/primary_d4.tsv` (score `avg_neglog10p`, higher is stronger); 22624 genes, 18642 shared with BARCS.

Spearman correlation of gene scores: **0.88**


Effect direction agreement: 88.2% of 18642 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 15 | 0.43 | 10 | 10 |
| 50 | 23 | 0.30 | 27 | 27 |
| 100 | 46 | 0.30 | 54 | 54 |
| 200 | 102 | 0.34 | 98 | 98 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Smad6 (14 / 77), Ralgapb (17 / 177), Cdyl (18 / 51), Trp53 (20 / 223), Rab7 (21 / 96), Pdcd10 (22 / 138), Gnas (23 / 83), Cic (24 / 145), Med26 (25 / 107), Kdm1a (26 / 82)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Gm4724 (11 / 5958), Gm4567 (18 / 100), Gm6902 (26 / 234), Gm14308 (32 / 395), Gm14434 (33 / 865), Gm15097 (37 / 539), Vmn1r126 (38 / 7531), Mup1 (42 / 315), Luzp4 (43 / 12788), Gm14305 (44 / 1836)

## BARCS calls

Genes at FDR 0.05: 214; at FDR 0.10: 359. Top 15: Sufu, Eed, Ptch1, Cd200, Ezh2, Strap, Dot1l, Arrb2, Suz12, Ptbp1, Brd2, Pias1, Urod, Smad6, 2210018M11Rik
