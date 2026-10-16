# BARCS versus published results

BARCS genes: `results/cfpac1_tumor_vs_culture/genes.csv` (122 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| AP2A1 | 5 | 122 | 0.771 | 0.021 | 0.23 |
| AP2A2 | 65 | 122 | 0.302 | 0.4 | 0.65 |
| AP2B1 | 14 | 122 | 0.475 | 0.04 | 0.23 |
| AP2M1 | 13 | 122 | 0.407 | 0.038 | 0.23 |
| AP2S1 | 102 | 122 | 0.580 | 0.96 | 0.97 |
| PTEN | 89 | 122 | 0.207 | 0.64 | 0.76 |

## Agreement with the published table

Published: `paper/fig1b_CFPAC1.csv` (score `signed_log10p`, higher is stronger); 123 genes, 112 shared with BARCS.

Spearman correlation of gene scores: **0.52**


Effect direction agreement: 74.1% of 112 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 1 | 0.11 | 4 | 4 |
| 10 | 4 | 0.25 | 6 | 6 |
| 25 | 12 | 0.32 | 13 | 13 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): PIK3R3 (1 / 22), PLCB1 (2 / 48), SLC5A11 (3 / 70), PIK3C2G (4 / 53)

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): AP2M1 (2 / 13), PIP4K2B (3 / 34), PREX1 (4 / 7), MTMR12 (5 / 22)

## BARCS calls

Genes at FDR 0.05: 3; at FDR 0.10: 4. Top 15: PIK3R3, PLCB1, SLC5A11, PIK3C2G, AP2A1, PLCD1, PREX1, PITPNM1, PI4KB, PIK3R1, TPTE, SYNJ1, AP2M1, AP2B1, INPPL1
