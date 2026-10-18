# BARCS versus published results

BARCS genes: `results/jlat106_combo/genes.csv` (526 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CCNT1 | 1 | 526 | -0.923 | 1.3e-22 | 6.9e-20 |
| ELL | 4 | 526 | -0.954 | 7.9e-13 | 1e-10 |
| UBE2M | 3 | 526 | -0.548 | 7.7e-13 | 1e-10 |
| TBL1XR1 | 18 | 526 | -0.471 | 1.6e-06 | 4e-05 |
| HDAC3 | 13 | 526 | -0.399 | 9.1e-08 | 3.2e-06 |
| AMBRA1 | 25 | 526 | -0.250 | 5.6e-05 | 0.00095 |
| ALYREF | 31 | 526 | -0.593 | 0.00012 | 0.0016 |
| NFKB1 | 6 | 526 | -0.909 | 4.9e-12 | 3.7e-10 |
| MBNL1 | 10 | 526 | -0.465 | 3.3e-08 | 1.4e-06 |
| OGT | 5 | 526 | -0.578 | 1.3e-12 | 1.4e-10 |

## Agreement with the published table

Published: `paper/SuppFileS1_v1.xlsx` (score `neg|MAGeCK score`, lower is stronger); 1052 genes, 524 shared with BARCS.

Spearman correlation of gene scores: **0.83**


Effect direction agreement: 96.8% of 524 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 7 | 0.54 | 3 | 3 |
| 25 | 21 | 0.72 | 4 | 4 |
| 50 | 40 | 0.67 | 10 | 10 |
| 100 | 83 | 0.71 | 17 | 17 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): NCL (7 / 25), MED7 (8 / 12), CDK9 (9 / 11)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): TNPO1 (3 / 14), PUF60 (6 / 11), EIF1 (7 / 17)

## BARCS calls

Genes at FDR 0.05: 73; at FDR 0.10: 92. Top 15: CCNT1, SBDS, UBE2M, ELL, OGT, NFKB1, NCL, MED7, CDK9, MBNL1, PUF60, DYRK1A, HDAC3, TNPO1, RUVBL2
