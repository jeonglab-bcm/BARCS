# BARCS versus published results

BARCS genes: `results/activator_GFPlow_vs_unsorted/genes.csv` (93 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| USP43 | 4 | 93 | 0.349 | 0.0086 | 0.16 |
| USP52 | 1 | 93 | 0.612 | 8.5e-05 | 0.008 |
| JOSD1 | 2 | 93 | 0.301 | 0.0019 | 0.088 |

## Agreement with the published table

Published: `paper/EV1_GFP_low.tsv` (score `pos|p-value`, lower is stronger); 93 genes, 93 shared with BARCS.

Spearman correlation of gene scores: **0.77**


Effect direction agreement: 91.4% of 93 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 5 | 1.00 | 0 | 0 |
| 10 | 7 | 0.54 | 3 | 3 |
| 20 | 13 | 0.48 | 7 | 7 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): none

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): none

## BARCS calls

Genes at FDR 0.05: 1; at FDR 0.10: 2. Top 15: USP52, JOSD1, USP15, USP43, USP33, UCHL5, USP31, STAMBP, USP25, USP18, CYLD, USP16, USP51, USP40, ZRANB1
