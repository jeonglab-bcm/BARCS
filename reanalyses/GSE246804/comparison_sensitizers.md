# BARCS versus published results

BARCS genes: `results/combo_vs_DMSO/genes.csv` (18907 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| FGFR1 | 4399 | 18907 | -0.290 | 0.036 | 0.084 |
| B4GALT7 | 1398 | 18907 | -0.668 | 0.0013 | 0.0085 |
| EXT2 | 1123 | 18907 | -0.603 | 0.00078 | 0.0059 |
| EXT1 | 694 | 18907 | -0.563 | 0.00027 | 0.0029 |
| EXTL3 | 235 | 18907 | -0.522 | 2.6e-05 | 0.00063 |
| ITGB1 | 303 | 18907 | -0.486 | 4.8e-05 | 0.00097 |

## Agreement with the published table

Published: `paper/rsa_NCI-H23.tsv` (score `rsa_sensitizer_logp`, lower is stronger); 19092 genes, 18907 shared with BARCS.

Spearman correlation of gene scores: **0.38**


Effect direction agreement: 63.5% of 18907 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 4 | 0.09 | 21 | 21 |
| 50 | 11 | 0.12 | 39 | 39 |
| 100 | 16 | 0.09 | 84 | 84 |
| 200 | 25 | 0.07 | 175 | 175 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): CREM (4 / 1806), MYO1D (5 / 509), UBR2 (6 / 354), IL6ST (7 / 228), DOCK1 (8 / 89), SSH2 (9 / 960), MOCS2 (10 / 730), TAPT1 (11 / 1090), METTL6 (12 / 2028), WDR93 (13 / 3141), RAP1GDS1 (14 / 403), SPTLC1 (15 / 149), NEDD9 (16 / 880), TARP (17 / 721), RBM41 (18 / 256), KRAS (19 / 33), MLLT10 (21 / 3099), C1orf86 (22 / 132), FAM122C (23 / 2566), DNAJB11 (24 / 495), UBE3C (25 / 241)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): MAPK1 (3 / 41), EEF1A1 (4 / 3717), EIF2S3 (5 / 2762), YAP1 (6 / 2652), IGF1R (7 / 2601), EXT2 (8 / 1123), CHD2 (9 / 3977), ITGB1 (10 / 303), MARCH5 (11 / 125), EP300 (12 / 1706), RAPH1 (13 / 45), PDCL (14 / 56), B4GALT7 (15 / 1398), SRSF2 (18 / 5578), GLCE (19 / 33), RPL4 (20 / 2826), VCL (21 / 4790), GRB2 (22 / 2982), CPSF3L (23 / 1875), HIST2H2BF (24 / 3200), MSTO1 (25 / 1827)

## BARCS calls

Genes at FDR 0.05: 6791; at FDR 0.10: 8606. Top 15: RAF1, SHOC2, OTUD6B, CREM, MYO1D, UBR2, IL6ST, DOCK1, SSH2, MOCS2, TAPT1, METTL6, WDR93, RAP1GDS1, SPTLC1
