# BARCS versus published results

BARCS genes: `results/dld1_tumor_vs_day0/genes.csv` (177 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PCBP1 | 7 | 177 | -1.115 | 2.3e-07 | 5.8e-06 |
| ATP5SL | 14 | 177 | -0.680 | 0.00012 | 0.0015 |
| CDC42 | 21 | 177 | -0.525 | 0.0022 | 0.018 |
| CIRH1A | 24 | 177 | -0.802 | 0.007 | 0.05 |
| CNOT9 | 16 | 177 | -0.683 | 0.0003 | 0.0033 |

## Agreement with the published table

Published: `paper/SuppTable6_DLD1_Tumor.tsv` (score `neg|score`, lower is stronger); 177 genes, 177 shared with BARCS.

Spearman correlation of gene scores: **0.87**


Effect direction agreement: 82.5% of 177 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 7 | 0.54 | 3 | 3 |
| 25 | 23 | 0.85 | 2 | 2 |
| 50 | 40 | 0.67 | 10 | 10 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): TFRC (8 / 23), SNRNP27 (9 / 13), TUBG1 (10 / 24)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): AAMP (6 / 11), RPLP0 (8 / 15), COASY (10 / 17)

## BARCS calls

Genes at FDR 0.05: 25; at FDR 0.10: 26. Top 15: GAPDH, PGK1, NCAPD2, MRPL51, EXOSC5, TANGO6, PCBP1, TFRC, SNRNP27, TUBG1, AAMP, INCENP, RPS21, ATP5SL, RPLP0
