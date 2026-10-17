# BARCS versus published results

BARCS genes: `results/hpafii_tumor_vs_culture/genes.csv` (122 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| AP2A1 | 5 | 122 | 1.046 | 0.0094 | 0.094 |
| AP2A2 | 68 | 122 | 0.463 | 0.3 | 0.44 |
| AP2B1 | 44 | 122 | 0.536 | 0.13 | 0.29 |
| AP2M1 | 2 | 122 | 0.874 | 0.0004 | 0.0097 |
| AP2S1 | 1 | 122 | 1.180 | 0.00013 | 0.004 |
| PTEN | 9 | 122 | 0.661 | 0.011 | 0.094 |

## Agreement with the published table

Published: `paper/fig1b_HPAFII.csv` (score `signed_log10p`, higher is stronger); 123 genes, 112 shared with BARCS.

Spearman correlation of gene scores: **0.71**


Effect direction agreement: 84.8% of 112 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 3 | 0.43 | 2 | 2 |
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 18 | 0.56 | 7 | 7 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): PI4K2B (3 / 6), SBF1 (4 / 7)

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): DPM1 (2 / 12), PLCB3 (4 / 6)

## BARCS calls

Genes at FDR 0.05: 8; at FDR 0.10: 14. Top 15: AP2S1, AP2M1, PI4K2B, SBF1, AP2A1, PLCB3, PLCB4, PIK3R3, PTEN, PDE6D, PIK3CG, DPM1, MTMR14, ARL13B, SLC5A3
