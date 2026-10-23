# BARCS versus published results

BARCS genes: `results/SARS2_1st_vs_D10_uninfected/genes.csv` (19114 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ACE2 | 17 | 19114 | 2.182 | 1.3e-05 | 0.011 |
| CTSL | 2 | 19114 | 1.910 | 1.3e-12 | 1.2e-08 |
| CCZ1 | 4 | 19114 | 1.576 | 2.7e-09 | 1e-05 |
| CCZ1B | 3 | 19114 | 1.863 | 2.6e-09 | 1e-05 |
| TMEM251 | 1 | 19114 | 1.749 | 3.5e-13 | 6.6e-09 |
| C18orf8 | 25 | 19114 | 0.883 | 8.8e-05 | 0.053 |
| CDH2 | 8 | 19114 | 1.241 | 2.2e-07 | 0.00042 |

## Agreement with the published table

Published: `paper/hek2_sars_mageck.tsv` (score `pos_score`, lower is stronger); 19112 genes, 19086 shared with BARCS.

Spearman correlation of gene scores: **0.62**


Effect direction agreement: 83.2% of 19086 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 16 | 0.67 | 4 | 4 |
| 50 | 30 | 0.43 | 20 | 20 |
| 100 | 57 | 0.40 | 43 | 43 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): GNPTG (11 / 32), RNH1 (13 / 21), ACSL4 (18 / 51), STRADA (19 / 24)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): CTBP2 (10 / 30), C18orf8 (16 / 25), ACSL3 (18 / 27), ARPC5L (20 / 136)

## BARCS calls

Genes at FDR 0.05: 31; at FDR 0.10: 41. Top 15: TMEM251, CTSL, CCZ1B, CCZ1, SLC39A1, WDR81, SLC12A9, CDH2, GNPTAB, SNX27, GNPTG, PEX10, RNH1, GDI2, RAB7A
