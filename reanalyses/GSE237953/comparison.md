# BARCS versus published results

BARCS genes: `results/FKBP5low_vs_high/genes.csv` (19029 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| NR3C1 | 2 | 19029 | 5.721 | 2.3e-10 | 2.2e-06 |
| STAG2 | 13 | 19029 | 4.671 | 1.7e-07 | 0.00012 |
| PAXIP1 | 12 | 19029 | 5.055 | 1.2e-07 | 8.9e-05 |
| FKBP5 | 8 | 19029 | 5.098 | 4.8e-08 | 5.4e-05 |
| MAU2 | 113 | 19029 | 3.504 | 1.6e-05 | 0.0017 |

## Agreement with the published table

Published: `paper/mageck_data.tsv` (score `pos|score`, lower is stronger); 19113 genes, 19025 shared with BARCS.

Spearman correlation of gene scores: **0.69**


Effect direction agreement: 85.9% of 19025 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 3 | 0.18 | 7 | 7 |
| 25 | 8 | 0.19 | 17 | 17 |
| 50 | 11 | 0.12 | 39 | 39 |
| 100 | 22 | 0.12 | 78 | 78 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): EXOC4 (1 / 12), LBHD1 (3 / 498), WDR12 (4 / 715), ZPR1 (5 / 305), MEN1 (6 / 718), TNKS1BP1 (7 / 18), CGB2 (9 / 507)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): STAG2 (2 / 13), PAXIP1 (3 / 12), MAU2 (6 / 113), EHMT2 (7 / 295), TAF6L (8 / 183), PTGES3 (9 / 48), CTDP1 (10 / 23)

## BARCS calls

Genes at FDR 0.05: 1223; at FDR 0.10: 1861. Top 15: EXOC4, NR3C1, LBHD1, WDR12, ZPR1, MEN1, TNKS1BP1, FKBP5, CGB2, VAC14, SPATA31A3, PAXIP1, STAG2, CLN5, SRF
