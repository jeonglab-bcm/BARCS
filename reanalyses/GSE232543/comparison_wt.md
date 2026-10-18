# BARCS versus published results

BARCS genes: `results/WT_secondary_CD86low_vs_high/genes.csv` (661 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Cd86 | 1 | 661 | 1.551 | 1.5e-287 | 9.7e-285 |
| Nr4a3 | 40 | 661 | 0.071 | 0.093 | 0.7 |
| Stat2 | 16 | 661 | 0.108 | 0.011 | 0.15 |
| Mitf | 60 | 661 | 0.030 | 0.18 | 0.97 |

## Agreement with the published table

Published: `paper/WT_secondary_mageck.tsv` (score `pos|rank`, lower is stronger); 661 genes, 661 shared with BARCS.

Spearman correlation of gene scores: **0.82**


Effect direction agreement: 99.4% of 661 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 22 | 0.79 | 3 | 3 |
| 50 | 41 | 0.69 | 9 | 9 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): H2-Ab1 (6 / 18), Cdkn1a (8 / 11)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Hdac4 (8 / 11), Ezr (9 / 19)

## BARCS calls

Genes at FDR 0.05: 39; at FDR 0.10: 43. Top 15: Cd86, Lyz2, H2-Aa, Hnrnpll, Ncor2, H2-Ab1, P2ry14, Cdkn1a, Tet2, Txnrd1, Hdac4, Marcks, Ciita, Ncln, Itpr2
