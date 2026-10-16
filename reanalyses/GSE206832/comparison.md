# BARCS versus published results

BARCS genes: `results/CD86_GW_low_vs_high/genes.csv` (19674 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Cd86 | 2 | 19674 | 1.349 | 6.2e-07 | 0.005 |
| March1. | 3 | 19674 | -2.252 | 7.6e-07 | 0.005 |
| Cebpb | 1035 | 19674 | -0.517 | 0.064 | 1 |
| Med12 | 17 | 19674 | -0.994 | 0.00081 | 0.87 |

## Agreement with the published table

Published: `paper/cd86_gw_mageck.tsv` (score `min_p`, lower is stronger); 19675 genes, 19674 shared with BARCS.

Spearman correlation of gene scores: **0.66**


Effect direction agreement: 97.7% of 19674 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 7 | 0.54 | 3 | 3 |
| 25 | 11 | 0.28 | 14 | 14 |
| 50 | 23 | 0.30 | 27 | 27 |
| 100 | 43 | 0.27 | 57 | 57 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Srp72 (8 / 77), Prkar1a (9 / 28), Spi1 (10 / 66)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): 1810013L24Rik (4 / 31), Pcdhb2 (8 / 58), Eif2s2 (9 / 33)

## BARCS calls

Genes at FDR 0.05: 6; at FDR 0.10: 6. Top 15: Hspa5, Cd86, March1., Ubl3, Chd4, Eif3g, Polr2a, Srp72, Prkar1a, Spi1, Plagl2, Mgat4d, Med14, Qrich1, Ran
