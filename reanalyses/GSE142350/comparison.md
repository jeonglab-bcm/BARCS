# BARCS versus published results

BARCS genes: `results/sre_elk_sorted_vs_unsorted/genes.csv` (1148 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Dusp9 | 1 | 1148 | 0.969 | 1.2e-68 | 1.3e-65 |
| Klhl13 | 3 | 1148 | 0.576 | 1.2e-26 | 4.7e-24 |
| Zic3 | 5 | 1148 | 0.601 | 7.2e-20 | 1.7e-17 |
| Stag2 | 38 | 1148 | 0.232 | 6.4e-06 | 0.00019 |
| Fthl17 | 17 | 1148 | 0.249 | 4.2e-10 | 2.8e-08 |

## Agreement with the published table

Published: `paper/screen_results.tsv` (score `FDR_SRE_Elk`, lower is stronger); 1248 genes, 1145 shared with BARCS.

Spearman correlation of gene scores: **0.53**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 9 | 0.82 | 1 | 1 |
| 20 | 13 | 0.48 | 7 | 7 |
| 40 | 33 | 0.70 | 7 | 7 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Nr0b1 (11 / 15)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Prmt5 (9 / 13)

## BARCS calls

Genes at FDR 0.05: 95; at FDR 0.10: 110. Top 15: Dusp9, Csk, Klhl13, Mapk1, Zic3, Klf8, 1700012L04Rik, Grb2, Eras, Frs2, Nr0b1, Ptpn11, Prmt5, Kdm6a, Rbm10
