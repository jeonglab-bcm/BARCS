# BARCS versus published results

BARCS genes: `results/Cas9_vs_noCas9_T1/genes.csv` (105 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| IGF2BP2 | 9 | 105 | -1.566 | 1.7e-07 | 1.6e-06 |
| C19orf35 | 1 | 105 | -3.057 | 3.8e-21 | 4e-19 |
| ATP4A | 2 | 105 | -2.955 | 5.5e-14 | 2.9e-12 |
| FDPS | 5 | 105 | -0.875 | 4.1e-10 | 6.5e-09 |
| TLE2 | 11 | 105 | -0.861 | 0.00013 | 0.00083 |
| SASS6 | 12 | 105 | -1.027 | 0.00033 | 0.002 |
| TAF5L | 3 | 105 | -0.800 | 4.5e-12 | 1.6e-10 |
| DCTN3 | 4 | 105 | -0.800 | 6.9e-12 | 1.8e-10 |
| CALM2 | 6 | 105 | -0.620 | 4.4e-10 | 6.5e-09 |
| DENR | 8 | 105 | -0.684 | 1.8e-09 | 2.1e-08 |
| ACVR1B | 7 | 105 | -0.677 | 1.5e-09 | 2e-08 |
| CLK2 | 16 | 105 | -0.164 | 0.007 | 0.026 |
| TNFAIP8L1 | 21 | 105 | -0.143 | 0.035 | 0.097 |
| LPL | 56 | 105 | 0.000 | 0.95 | 0.98 |
| KIF5B | 58 | 105 | 0.017 | 0.81 | 0.92 |

## Agreement with the published table

Published: `paper/TableS7_in_vivo.tsv` (score `p_value`, lower is stronger); 15 genes, 15 shared with BARCS.

Spearman correlation of gene scores: **0.34**


Effect direction agreement: 86.7% of 15 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 3 | 0.43 | 2 | 2 |
| 10 | 7 | 0.54 | 3 | 3 |
| 15 | 15 | 1.00 | 0 | 0 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): TAF5L (3 / 11), DCTN3 (4 / 7)

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): DENR (2 / 8), CLK2 (5 / 16)

## BARCS calls

Genes at FDR 0.05: 33; at FDR 0.10: 38. Top 15: C19orf35, ATP4A, TAF5L, DCTN3, FDPS, CALM2, ACVR1B, DENR, IGF2BP2, ZBTB7A, TLE2, SASS6, RCE1, KRT6B, CDCA7
