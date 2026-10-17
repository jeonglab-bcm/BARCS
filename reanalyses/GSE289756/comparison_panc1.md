# BARCS versus published results

BARCS genes: `results/panc1_tumor_vs_culture/genes.csv` (122 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| AP2A1 | 40 | 122 | 0.330 | 0.24 | 0.61 |
| AP2A2 | 37 | 122 | 0.383 | 0.23 | 0.61 |
| AP2B1 | 1 | 122 | 1.086 | 0.003 | 0.23 |
| AP2M1 | 4 | 122 | 2.258 | 0.011 | 0.23 |
| AP2S1 | 3 | 122 | 3.001 | 0.0097 | 0.23 |
| PTEN | 2 | 122 | 4.985 | 0.0065 | 0.23 |

## Agreement with the published table

Published: `paper/fig1b_PANC1.csv` (score `signed_log10p`, higher is stronger); 123 genes, 112 shared with BARCS.

Spearman correlation of gene scores: **0.62**


Effect direction agreement: 60.7% of 112 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 4 | 0.67 | 1 | 1 |
| 10 | 6 | 0.43 | 4 | 4 |
| 25 | 15 | 0.43 | 10 | 10 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): INPPL1 (5 / 7)

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): PTPMT1 (5 / 97)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: AP2B1, PTEN, AP2S1, AP2M1, INPPL1, PIK3R5, SBF2, SYNJ1, PLCD4, MTMR9, BECN1, SBF1, PLCZ1, PLCD1, PIK3C3
