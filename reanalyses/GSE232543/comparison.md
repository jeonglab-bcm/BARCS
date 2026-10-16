# BARCS versus published results

BARCS genes: `results/CebpbKO_secondary_CD86low_vs_high/genes.csv` (661 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Cd86 | 1 | 661 | 1.494 | 3.8e-301 | 2.5e-298 |
| Nr4a3 | 5 | 661 | 0.400 | 1.1e-12 | 1e-10 |
| Stat2 | 34 | 661 | 0.056 | 0.11 | 0.81 |
| Mitf | 28 | 661 | 0.144 | 0.061 | 0.61 |

## Agreement with the published table

Published: `paper/CebpbKO_secondary_mageck.tsv` (score `pos|rank`, lower is stronger); 661 genes, 661 shared with BARCS.

Spearman correlation of gene scores: **0.82**


Effect direction agreement: 93.2% of 661 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 10 | 1.00 | 0 | 0 |
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 38 | 0.61 | 12 | 12 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): none

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): none

## BARCS calls

Genes at FDR 0.05: 28; at FDR 0.10: 39. Top 15: Cd86, Tnfrsf1b, Cdkn1a, Adnp, Nr4a3, H2-Aa, Rel, Etv3, Cd74, Blnk, Arfgef1, Nrip1, Ciita, Smurf1, P2ry14
