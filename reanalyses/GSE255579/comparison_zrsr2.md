# BARCS versus published results

BARCS genes: `results/ZRSR2_vs_NT/genes.csv` (19112 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| GINS2 | 394 | 19112 | 0.573 | 0.02 | 0.59 |
| CDC6 | 845 | 19112 | 0.698 | 0.058 | 0.71 |
| SMC5 | 352 | 19112 | 0.848 | 0.017 | 0.56 |
| RRM1 | 490 | 19112 | 1.240 | 0.028 | 0.63 |
| TYMS | 397 | 19112 | 0.747 | 0.021 | 0.59 |

## Agreement with the published table

Published: `paper/SD_M8.xlsx` (score `pos|score`, lower is stronger); 19113 genes, 19086 shared with BARCS.

Spearman correlation of gene scores: **0.59**


Effect direction agreement: 76.7% of 19086 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 3 | 0.06 | 22 | 22 |
| 50 | 10 | 0.11 | 40 | 40 |
| 100 | 26 | 0.15 | 74 | 74 |
| 200 | 57 | 0.17 | 143 | 143 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): GPR75 (1 / 1468), POLR3H (2 / 36), EIF2B2 (3 / 3089), ZRSR2 (4 / 168), PUM2 (5 / 6711), POLD1 (6 / 292), DDX54 (7 / 51), PSMA7 (8 / 90), SNAPC2 (9 / 885), SLC44A5 (10 / 415), ZNF598 (13 / 287), POT1 (14 / 33), NPIPA3 (16 / 32), ALG2 (17 / 132), PPP4R4 (18 / 10605), SHQ1 (19 / 255), IRX1 (20 / 366), FBXL12 (21 / 2151), CCT5 (22 / 1266), RNASEK (23 / 283), GMPS (24 / 988), SPDYE6 (25 / 160)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): WASH1 (1 / 73), UBE2S (4 / 332), MRPL57 (5 / 1441), ELP6 (6 / 93), FANCC (7 / 3078), POLR2A (8 / 3094), HK2 (9 / 5878), NPIPA1 (10 / 50), RPS27A (11 / 11042), NR2C1 (12 / 33), HIF1AN (13 / 317), CDC6 (14 / 845), DAD1 (15 / 302), SPATA5L1 (16 / 897), SNAP29 (17 / 1008), C19orf52 (18 / 1204), GOLGA6L10 (19 / 229), AGAP4 (20 / 29), EXOSC1 (21 / 3252), RRM1 (22 / 490), ZNF879 (24 / 70), KIAA1524 (25 / 1030)

## BARCS calls

Genes at FDR 0.05: 9; at FDR 0.10: 18. Top 15: GPR75, POLR3H, EIF2B2, ZRSR2, PUM2, POLD1, DDX54, PSMA7, SNAPC2, SLC44A5, RPL7L1, EIF6, ZNF598, POT1, POLR3E
