# BARCS versus published results

BARCS genes: `results/FANCG_vs_NT/genes.csv` (19112 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| GINS2 | 82 | 19112 | 1.290 | 0.00098 | 0.21 |
| CDC6 | 342 | 19112 | 1.196 | 0.01 | 0.46 |
| SMC5 | 798 | 19112 | 1.069 | 0.042 | 0.69 |
| RRM1 | 929 | 19112 | 1.664 | 0.053 | 0.72 |
| TYMS | 23 | 19112 | 1.170 | 0.00012 | 0.098 |

## Agreement with the published table

Published: `paper/SD_M7.xlsx` (score `pos|score`, lower is stronger); 19113 genes, 19086 shared with BARCS.

Spearman correlation of gene scores: **0.68**


Effect direction agreement: 78.1% of 19086 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 6 | 0.14 | 19 | 19 |
| 50 | 16 | 0.19 | 34 | 34 |
| 100 | 40 | 0.25 | 60 | 60 |
| 200 | 92 | 0.30 | 108 | 108 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): CTAGE6 (1 / 13710), DNM1L (2 / 299), SF3B4 (3 / 100), SRP54 (4 / 234), LSM10 (5 / 27), PSMA2 (6 / 42), SARS (9 / 49), PHAX (10 / 57), EIF6 (11 / 133), SSB (12 / 259), RPL10 (13 / 138), CENPN (15 / 112), PSMA5 (16 / 245), DCTN6 (18 / 695), TRMT6 (20 / 163), ALDOA (21 / 79), NAA50 (22 / 50), PSMB5 (24 / 275), RPS16 (25 / 253)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): NOL11 (1 / 372), WASH1 (3 / 30), GINS2 (4 / 82), GINS4 (5 / 28), RPN1 (7 / 154), SNRPD2 (8 / 324), NXF1 (9 / 70), NPIPA1 (12 / 64), ATP6V0C (13 / 76), VDAC1 (14 / 386), PMF1-BGLAP (15 / 229), RBBP4 (16 / 918), TAF6 (17 / 3508), CNOT10 (18 / 9895), RACGAP1 (20 / 304), DDX54 (21 / 159), SNRNP35 (22 / 36), RPL17 (23 / 167), NUDT21 (25 / 84)

## BARCS calls

Genes at FDR 0.05: 3; at FDR 0.10: 27. Top 15: CTAGE6, DNM1L, SF3B4, SRP54, LSM10, PSMA2, LOC101060389, RPL27, SARS, PHAX, EIF6, SSB, RPL10, UBA3, CENPN
