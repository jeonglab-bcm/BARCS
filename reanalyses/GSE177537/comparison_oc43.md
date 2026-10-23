# BARCS versus published results

BARCS genes: `results/OC43_1st_vs_T0/genes.csv` (19114 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TMEM41B | 10 | 19114 | 7.274 | 0.017 | 0.11 |
| VMP1 | 1 | 19114 | 7.175 | 0.0013 | 0.048 |
| CCZ1B | 5 | 19114 | 6.861 | 0.01 | 0.091 |
| CCZ1 | 94 | 19114 | 6.704 | 0.19 | 0.36 |
| SLC35B2 | 4 | 19114 | 5.903 | 0.0083 | 0.084 |
| WDR81 | 19 | 19114 | 5.345 | 0.05 | 0.18 |

## Agreement with the published table

Published: `paper/hek1_oc43_mageck.tsv` (score `pos_score`, lower is stronger); 19112 genes, 19086 shared with BARCS.

Spearman correlation of gene scores: **0.13**


Effect direction agreement: 77.8% of 19086 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 18 | 0.82 | 2 | 2 |
| 50 | 24 | 0.32 | 26 | 26 |
| 100 | 31 | 0.18 | 69 | 69 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): DHFRL1 (17 / 9667), UBR4 (20 / 4852)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): CCZ1 (13 / 94), SUCO (18 / 21)

## BARCS calls

Genes at FDR 0.05: 607; at FDR 0.10: 2424. Top 15: VMP1, SMARCB1, SLC35D1, SLC35B2, CCZ1B, ADNP, CASD1, TMED10, TXN, TMEM41B, C1GALT1, TAPT1, SMARCA4, MDH1, NXPE3
