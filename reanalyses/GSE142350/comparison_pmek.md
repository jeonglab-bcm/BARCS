# BARCS versus published results

BARCS genes: `results/pmek_low_vs_unsorted/genes.csv` (130 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Dusp9 | 1 | 130 | 0.833 | 8.9e-17 | 1.2e-14 |
| Klhl13 | 13 | 130 | 0.220 | 1.2e-06 | 1.2e-05 |
| Zic3 | 56 | 130 | 0.118 | 0.01 | 0.023 |
| Stag2 | 9 | 130 | 0.327 | 4.9e-09 | 7.1e-08 |
| Fthl17 | 5 | 130 | 0.557 | 1.3e-10 | 3.5e-09 |

## Agreement with the published table

Published: `paper/screen_results.tsv` (score `FDR_pMek_Screen`, lower is stronger); 140 genes, 127 shared with BARCS.

Spearman correlation of gene scores: **0.78**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 9 | 0.82 | 1 | 1 |
| 20 | 16 | 0.67 | 4 | 4 |
| 40 | 30 | 0.60 | 10 | 10 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Zfx (11 / 15)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Klf8 (12 / 17)

## BARCS calls

Genes at FDR 0.05: 72; at FDR 0.10: 80. Top 15: Dusp9, Gm5635, Esrrb, Pgk1, Fthl17, Mapk1, Kdm6a, Stat3, Stag2, Ptpn2, Zfx, Tfcp2l1, Klhl13, Slc35a2, Mycs
