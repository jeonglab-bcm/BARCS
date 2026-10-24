# BARCS versus published results

BARCS genes: `results/DELnoIL3_vs_EVIL3/genes.csv` (245 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| MPL | 8 | 245 | -3.265 | 4.9e-21 | 1.1e-19 |
| CALR | 9 | 245 | -2.005 | 5e-20 | 1e-18 |
| Jak2 | 28 | 245 | -2.215 | 1.3e-05 | 9.4e-05 |
| Stat5b | 17 | 245 | -1.472 | 2.7e-15 | 3.1e-14 |
| Dpm1 | 7 | 245 | -2.341 | 1.5e-23 | 4.7e-22 |
| Dpm2 | 3 | 245 | -2.139 | 2.5e-29 | 1.5e-27 |
| Dpm3 | 1 | 245 | -1.818 | 4.6e-31 | 5.6e-29 |
| Mpdu1 | 10 | 245 | -1.782 | 1.2e-19 | 2.3e-18 |

## Agreement with the published table

Published: `paper/pooled_DELminus_vs_EVplus.tsv` (score `neg.score`, lower is stronger); 243 genes, 243 shared with BARCS.

Spearman correlation of gene scores: **0.89**


Effect direction agreement: 74.9% of 243 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 22 | 0.79 | 3 | 3 |
| 50 | 44 | 0.79 | 6 | 6 |
| 64 | 62 | 0.94 | 2 | 2 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Mpdu1 (10 / 12), Tmed2 (11 / 11)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Aifm1 (5 / 12), Mogs (7 / 13)

## BARCS calls

Genes at FDR 0.05: 69; at FDR 0.10: 81. Top 15: Dpm3, Uggt1, Dpm2, Pmm2, Dpy19l1, Mpi, Dpm1, MPL, CALR, Mpdu1, Tmed2, Aifm1, Mogs, Tmed10, Prdm4
