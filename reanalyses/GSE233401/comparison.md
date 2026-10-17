# BARCS versus published results

BARCS genes: `results/sgNeg_T1_vs_T0/genes.csv` (92 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PTEN | 1 | 92 | 0.405 | 2.2e-19 | 2.1e-17 |
| TSC1 | 2 | 92 | 0.388 | 1.1e-14 | 5e-13 |
| MAP3K4 | 3 | 92 | 0.248 | 2.1e-13 | 6.4e-12 |
| MAP2K4 | 10 | 92 | 0.196 | 1.1e-05 | 7.7e-05 |

## Agreement with the published table

Published: `paper/minipool_screen.tsv` (score `sgNeg_z`, higher is stronger); 92 genes, 92 shared with BARCS.

Spearman correlation of gene scores: **0.96**


Effect direction agreement: 45.7% of 92 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 46 | 0.85 | 4 | 4 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): BMPR2 (7 / 19), CACNA2D3 (8 / 11)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): TET2 (6 / 12), PPM1A (7 / 14)

## BARCS calls

Genes at FDR 0.05: 57; at FDR 0.10: 66. Top 15: PTEN, TSC1, MAP3K4, GAS1, EPB41L3, CDH13, BMPR2, CACNA2D3, BMP4, MAP2K4, BNIP3L, TET2, ADARB1, PPM1A, MXI1
