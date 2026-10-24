# BARCS versus published results

BARCS genes: `results/DELnoIL3_vs_EVIL3/genes.csv` (19610 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Dpm2 | 1 | 19610 | -4.995 | 1.1e-13 | 2.2e-09 |
| Calr | 19 | 19610 | -3.046 | 0.00019 | 0.13 |
| Dpm1 | 6 | 19610 | -3.292 | 1e-06 | 0.0025 |
| Dpm3 | 2 | 19610 | -2.003 | 2.2e-09 | 2.1e-05 |
| Mpdu1 | 20 | 19610 | -3.714 | 0.00022 | 0.14 |

## Agreement with the published table

Published: `paper/bloodBLD2022015629-suppl3.xlsx` (score `neg.score`, lower is stronger); 19674 genes, 19610 shared with BARCS.

Spearman correlation of gene scores: **0.71**


Effect direction agreement: 90.8% of 19610 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 9 | 0.82 | 1 | 1 |
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 33 | 0.49 | 17 | 17 |
| 100 | 51 | 0.34 | 49 | 49 |
| 200 | 91 | 0.29 | 109 | 109 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Uggt1 (9 / 13)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Mpdu1 (7 / 20)

## BARCS calls

Genes at FDR 0.05: 18; at FDR 0.10: 24. Top 15: Dpm2, Dpm3, Prdm4, Mpi, Dpy19l1, Dpm1, Csnk1a1, Pmm2, Uggt1, Srd5a3, Tsta3, Supt20, Tmed2, Hmbs, Sdf4
