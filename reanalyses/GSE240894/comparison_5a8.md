# BARCS versus published results

BARCS genes: `results/jlat5a8_combo/genes.csv` (526 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CCNT1 | 1 | 526 | -0.863 | 5.2e-10 | 2.7e-07 |
| ELL | 2 | 526 | -1.060 | 5.2e-07 | 0.00014 |
| OTUD5 | 4 | 526 | -0.807 | 1.6e-05 | 0.0022 |
| MED7 | 5 | 526 | -0.792 | 2.5e-05 | 0.0026 |
| UBE2M | 16 | 526 | -0.465 | 0.00063 | 0.019 |
| TBL1XR1 | 6 | 526 | -0.570 | 9.7e-05 | 0.0085 |
| NFKB1 | 7 | 526 | -0.837 | 0.00015 | 0.012 |
| HDAC3 | 8 | 526 | -0.671 | 0.00024 | 0.014 |
| AMBRA1 | 12 | 526 | -0.580 | 0.00037 | 0.015 |

## Agreement with the published table

Published: `paper/SuppFileS1_v1.xlsx` (score `neg|MAGeCK score`, lower is stronger); 1052 genes, 524 shared with BARCS.

Spearman correlation of gene scores: **0.77**


Effect direction agreement: 76.5% of 524 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 6 | 0.43 | 4 | 4 |
| 25 | 16 | 0.47 | 9 | 9 |
| 50 | 32 | 0.47 | 18 | 18 |
| 100 | 67 | 0.50 | 33 | 33 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): GTF2H1 (3 / 19), HDAC3 (8 / 17), MZF1 (9 / 38), TEX10 (10 / 15)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): UBE2M (5 / 16), IRAK1 (6 / 21), NUP205 (9 / 25), KRTAP23-1 (10 / 17)

## BARCS calls

Genes at FDR 0.05: 30; at FDR 0.10: 49. Top 15: CCNT1, ELL, GTF2H1, OTUD5, MED7, TBL1XR1, NFKB1, HDAC3, MZF1, TEX10, PPP1R10, AMBRA1, GATA3, MED26, MED15
