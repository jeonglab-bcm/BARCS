# BARCS versus published results

BARCS genes: `results/esrrb_low_vs_unsorted/genes.csv` (130 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Dusp9 | 14 | 130 | 0.395 | 1.1e-12 | 9.8e-12 |
| Klhl13 | 4 | 130 | 0.644 | 4.4e-34 | 1.4e-32 |
| Zic3 | 10 | 130 | 0.539 | 7.8e-24 | 1e-22 |
| Stag2 | 30 | 130 | 0.217 | 0.00062 | 0.0027 |
| Fthl17 | 19 | 130 | 0.487 | 1.3e-10 | 8.7e-10 |

## Agreement with the published table

Published: `paper/screen_results.tsv` (score `FDR_Esrrb_Screen`, lower is stronger); 140 genes, 127 shared with BARCS.

Spearman correlation of gene scores: **0.68**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 9 | 0.82 | 1 | 1 |
| 20 | 19 | 0.90 | 1 | 1 |
| 40 | 32 | 0.67 | 8 | 8 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Slc35a2 (7 / 15)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Dusp9 (10 / 14)

## BARCS calls

Genes at FDR 0.05: 35; at FDR 0.10: 42. Top 15: Mapk1, Flcn, Frs2, Klhl13, Hccs, Grb2, Slc35a2, Ptpn2, Csk, Zic3, Ptpn11, Hsd17b10, Gpc4, Dusp9, Nr0b1
