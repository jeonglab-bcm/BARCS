# BARCS versus published results

BARCS genes: `results/poolC_FdU_vs_DMSO_E/genes.csv` (4984 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| EXO1 | not tested | | | | |
| MSH2 | not tested | | | | |
| LIG1 | not tested | | | | |

## Agreement with the published table

Published: `paper/supp1_poolC.csv` (score `lfc`, lower is stronger); 5129 genes, 4975 shared with BARCS.

Spearman correlation of gene scores: **0.95**


Effect direction agreement: 92.9% of 4975 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 15 | 0.43 | 10 | 10 |
| 50 | 36 | 0.56 | 14 | 14 |
| 100 | 67 | 0.50 | 33 | 33 |
| 200 | 136 | 0.52 | 64 | 64 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): RAD54L (7 / 38), RIF1 (9 / 30), FANCF (14 / 26), FANCL (15 / 32), EDF1 (17 / 44), FANCE (18 / 29), TM2D3 (21 / 52), EDC4 (22 / 89), TRIP12 (24 / 49), RHNO1 (25 / 51)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): WDHD1 (2 / 95), MED26 (3 / 26), SUPT4H1 (8 / 73), RPL7A (11 / 3066), CEP57 (16 / 68), GOLGA6L1 (18 / 121), RAD51D (21 / 40), VHL (22 / 55), XRCC3 (23 / 28), FEN1 (25 / 36)

## BARCS calls

Genes at FDR 0.05: 528; at FDR 0.10: 701. Top 15: MCM8, CNOT8, FANCD2, FANCG, REXO1, FANCI, RAD54L, RMI2, RIF1, ZC3H12A, RNASEH2C, ERCC1, IPO9, FANCF, FANCL
