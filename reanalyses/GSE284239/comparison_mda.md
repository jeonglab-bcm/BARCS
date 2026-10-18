# BARCS versus published results

BARCS genes: `results/mda_tng348_vs_dmso/genes.csv` (1181 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| RAD18 | 2 | 1181 | 1.660 | 1.7e-09 | 1e-06 |
| UBE2K | 3 | 1181 | 1.698 | 1.1e-07 | 4.4e-05 |
| UBE2A | 1 | 1181 | 2.454 | 1.7e-13 | 2e-10 |
| RFWD3 | 16 | 1181 | 0.996 | 0.0098 | 0.58 |
| PARP1 | 1038 | 1181 | -1.064 | 0.17 | 0.83 |

## Agreement with the published table

Published: `paper/tableS6.csv` (score `signed_score`, higher is stronger); 1182 genes, 1181 shared with BARCS.

Spearman correlation of gene scores: **0.68**


Effect direction agreement: 75.7% of 1181 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 15 | 0.60 | 5 | 5 |
| 50 | 27 | 0.37 | 23 | 23 |
| 100 | 62 | 0.45 | 38 | 38 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): RNF138 (10 / 24), RFWD3 (16 / 21), CCNC (17 / 49), PRH2 (19 / 91), LGI3 (20 / 63)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): CLASP2 (11 / 22), RNF168 (12 / 21), SMARCD1 (13 / 78), MPLKIP (15 / 25), CELF1 (16 / 83)

## BARCS calls

Genes at FDR 0.05: 9; at FDR 0.10: 10. Top 15: UBE2A, RAD18, UBE2K, E2F7, BEND3, USP9X, GTF2F1, PPM1G, KPNA2, RNF138, TADA2B, CKAP2, TRIP12, RAD54B, TM2D2
