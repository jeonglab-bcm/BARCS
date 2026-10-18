# BARCS versus published results

BARCS genes: `results/d14_low_vs_high/genes.csv` (20915 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| EIF2A | 1 | 20915 | 0.424 | 5.3e-15 | 3.7e-11 |

## Agreement with the published table

Published: `paper/mmc2.xlsx` (score `pos|score`, lower is stronger); 21915 genes, 20890 shared with BARCS.

Spearman correlation of gene scores: **0.64**


Effect direction agreement: 96.8% of 20890 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 4 | 0.25 | 6 | 6 |
| 25 | 11 | 0.28 | 14 | 14 |
| 50 | 27 | 0.37 | 23 | 23 |
| 100 | 54 | 0.37 | 46 | 46 |
| 200 | 105 | 0.36 | 95 | 95 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): TPT1 (3 / 12), ACHE (4 / 30), TCEB2 (5 / 15), IPO9 (6 / 17), SLTM (7 / 26), POLR2M (8 / 23)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): hsa-mir-663b (2 / 113), hsa-mir-7851 (4 / 15), PARP1 (7 / 97), COQ6 (8 / 45), PSMB4 (9 / 422), hsa-mir-8086 (10 / 635)

## BARCS calls

Genes at FDR 0.05: 20; at FDR 0.10: 35. Top 15: EIF2A, NRD1, TPT1, ACHE, TCEB2, IPO9, SLTM, POLR2M, KIF7, DPH7, EEF1A1, C1orf123, NDUFB10, HNRNPK, hsa-mir-7851
