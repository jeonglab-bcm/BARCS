# BARCS versus published results

BARCS genes: `results/SARS2_1st_vs_T0/genes.csv` (19114 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| EDC4 | 1 | 19114 | 0.652 | 7.5e-10 | 2.9e-06 |
| XRN1 | 27 | 19114 | 0.513 | 0.0019 | 0.072 |
| TMEM251 | 6 | 19114 | 0.538 | 1.3e-05 | 0.0019 |
| CDH2 | 7 | 19114 | 0.792 | 1.3e-05 | 0.0019 |
| CCZ1 | 18 | 19114 | 0.376 | 0.00045 | 0.026 |
| DNM2 | 5 | 19114 | 0.503 | 7.9e-06 | 0.0014 |
| WASL | 9 | 19114 | 0.530 | 2.1e-05 | 0.0027 |

## Agreement with the published table

Published: `paper/hek1_sars_mageck.tsv` (score `pos_score`, lower is stronger); 19112 genes, 19086 shared with BARCS.

Spearman correlation of gene scores: **0.77**


Effect direction agreement: 88.3% of 19086 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 15 | 0.60 | 5 | 5 |
| 50 | 33 | 0.49 | 17 | 17 |
| 100 | 56 | 0.39 | 44 | 44 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): CCZ1B (10 / 111), ALG5 (12 / 28), RCE1 (14 / 58), INTS12 (15 / 23), CTSL (20 / 29)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): SMCHD1 (9 / 21), DAZ3 (15 / 25), NPRL3 (17 / 71), KPTN (19 / 163), ZNF100 (20 / 1902)

## BARCS calls

Genes at FDR 0.05: 448; at FDR 0.10: 575. Top 15: EDC4, TP53, PIK3C3, SEC63, DNM2, TMEM251, CDH2, WDR7, WASL, CCZ1B, FBXW10, ALG5, BAX, RCE1, INTS12
