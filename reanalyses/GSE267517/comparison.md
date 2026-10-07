# BARCS versus published results

BARCS genes: `results/tcell_et1_vs_ctrl/genes.csv` (18399 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Mettl5 | 926 | 18399 | -0.171 | 0.012 | 0.23 |
| B2m | 1 | 18399 | 0.816 | 1.1e-48 | 2.1e-44 |
| Jak1 | 4 | 18399 | 0.521 | 1.2e-26 | 5.6e-23 |
| Rnf31 | 6 | 18399 | -0.704 | 2.5e-22 | 7.5e-19 |

## Agreement with the published table

Published: `paper/mageck_et1_ctrl.tsv` (score `p_min`, lower is stronger); 18403 genes, 18374 shared with BARCS.

Spearman correlation of gene scores: **0.50**


Effect direction agreement: 67.2% of 18374 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 34 | 0.52 | 16 | 16 |
| 100 | 68 | 0.52 | 32 | 32 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Ikbkg (17 / 71), Slc39a1 (20 / 26), Cdyl (23 / 33), Tmem259 (24 / 40), Icam1 (25 / 102)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Phf10 (19 / 33), Ube2m (21 / 99), Llgl2 (22 / 90), Cux1 (23 / 162), Ist1 (25 / 81)

## BARCS calls

Genes at FDR 0.05: 169; at FDR 0.10: 343. Top 15: B2m, H2-D1, Jak2, Jak1, Cflar, Rnf31, Tap1, Tap2, Ifngr2, Irgm1, Ifngr1, Tnfrsf1a, Traf2, Tradd, Tapbp
