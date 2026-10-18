# BARCS versus published results

BARCS genes: `results/miapaca2_tumor_vs_culture/genes.csv` (122 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| AP2A1 | 87 | 122 | -0.245 | 0.23 | 0.62 |
| AP2A2 | 42 | 122 | 0.492 | 0.78 | 0.85 |
| AP2B1 | 54 | 122 | -0.193 | 0.74 | 0.83 |
| AP2M1 | 9 | 122 | 3.639 | 0.25 | 0.64 |
| AP2S1 | 7 | 122 | 2.864 | 0.13 | 0.47 |
| PTEN | 6 | 122 | 1.954 | 0.1 | 0.4 |

## Agreement with the published table

Published: `paper/fig1b_MIAPACA2.csv` (score `signed_log10p`, higher is stronger); 123 genes, 112 shared with BARCS.

Spearman correlation of gene scores: **0.38**


Effect direction agreement: 53.6% of 112 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 1 | 0.11 | 4 | 4 |
| 10 | 5 | 0.33 | 5 | 5 |
| 25 | 12 | 0.32 | 13 | 13 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): MTMR14 (1 / 11), PLCG1 (2 / 21), PIK3R4 (3 / 8), FIG4 (5 / 41)

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): AP2M1 (1 / 9), AP2S1 (2 / 7), PIK3C3 (3 / 12), PTPMT1 (4 / 80)

## BARCS calls

Genes at FDR 0.05: 3; at FDR 0.10: 3. Top 15: MTMR14, PLCG1, PIK3R4, INPP5K, FIG4, PTEN, AP2S1, PLCH1, AP2M1, VAC14, SLC5A11, PIK3C3, PRKACA, BECN1, RAC3
