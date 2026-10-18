# BARCS versus published results

BARCS genes: `results/sgUHRF1_T1_vs_T0/genes.csv` (92 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TSC1 | 1 | 92 | 0.155 | 3.8e-07 | 3.5e-05 |
| PTEN | 5 | 92 | 0.126 | 0.0069 | 0.11 |

## Agreement with the published table

Published: `paper/minipool_screen.tsv` (score `sgUHRF1_z`, higher is stronger); 92 genes, 92 shared with BARCS.

Spearman correlation of gene scores: **0.90**


Effect direction agreement: 69.6% of 92 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 44 | 0.79 | 6 | 6 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): ZDHHC2 (8 / 20), CBL (9 / 12)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): CD44 (5 / 11), CSRNP1 (9 / 13)

## BARCS calls

Genes at FDR 0.05: 5; at FDR 0.10: 5. Top 15: TSC1, PLK1, SYVN1, AURKB, PTEN, ZNF185, CDK12, ZDHHC2, CBL, NR4A1, CD44, TMEM127, CSRNP1, PRKCB, CHST10
