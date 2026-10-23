# BARCS versus published results

BARCS genes: `results/nanog_low_vs_unsorted/genes.csv` (130 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Dusp9 | 3 | 130 | 1.139 | 4.4e-71 | 1.9e-69 |
| Klhl13 | 1 | 130 | 1.465 | 1e-120 | 1.3e-118 |
| Zic3 | 4 | 130 | 0.897 | 8e-56 | 2.6e-54 |
| Stag2 | 15 | 130 | 0.541 | 5.9e-19 | 5.1e-18 |
| Fthl17 | 22 | 130 | 0.526 | 3.3e-13 | 2e-12 |

## Agreement with the published table

Published: `paper/screen_results.tsv` (score `FDR_Nanog_Screen`, lower is stronger); 140 genes, 127 shared with BARCS.

Spearman correlation of gene scores: **0.77**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 7 | 0.54 | 3 | 3 |
| 20 | 17 | 0.74 | 3 | 3 |
| 40 | 31 | 0.63 | 9 | 9 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Nr0b1 (8 / 15), Ptpn11 (9 / 23), Slc35a2 (10 / 21)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Stag2 (8 / 15), Grb2 (9 / 11), Fbxw7 (11 / 27)

## BARCS calls

Genes at FDR 0.05: 71; at FDR 0.10: 77. Top 15: Klhl13, Csk, Dusp9, Zic3, Ptpn2, Frs2, Mapk1, Nr0b1, Ptpn11, Slc35a2, Grb2, Acsl4, Pgk1, Mbtps2, Stag2
