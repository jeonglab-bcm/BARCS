# BARCS versus published results

BARCS genes: `results/bxpc3_tumor_vs_culture/genes.csv` (122 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| AP2A1 | 2 | 122 | 1.291 | 0.0043 | 0.14 |
| AP2A2 | 38 | 122 | 0.907 | 0.13 | 0.36 |
| AP2B1 | 8 | 122 | 0.869 | 0.011 | 0.14 |
| AP2M1 | 1 | 122 | 2.187 | 0.0009 | 0.11 |
| AP2S1 | 5 | 122 | 2.220 | 0.0085 | 0.14 |
| PTEN | 9 | 122 | 3.358 | 0.014 | 0.15 |

## Agreement with the published table

Published: `paper/fig1b_BXPC3.csv` (score `signed_log10p`, higher is stronger); 123 genes, 112 shared with BARCS.

Spearman correlation of gene scores: **0.64**


Effect direction agreement: 78.6% of 112 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 3 | 0.43 | 2 | 2 |
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 15 | 0.43 | 10 | 10 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): INPPL1 (3 / 6), PIP4P1 (4 / 20)

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): PTEN (2 / 9), AP2B1 (5 / 8)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: AP2M1, AP2A1, INPPL1, PIP4P1, AP2S1, PIK3R1, ATG14, AP2B1, PTEN, INPP5K, PIK3R3, SYNJ1, SLC2A13, RAC1, PRKACA
