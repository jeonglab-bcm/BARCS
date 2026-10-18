# BARCS versus published results

BARCS genes: `results/KO_withBATF3_IL7R_high_vs_low/genes.csv` (1613 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| IL7R | 1 | 1613 | -2.592 | 5.5e-10 | 5.1e-07 |
| BATF3 | 12 | 1613 | -1.463 | 7.4e-05 | 0.0079 |
| JUNB | 111 | 1613 | -0.703 | 0.031 | 0.35 |
| IRF4 | 40 | 1613 | -0.735 | 0.0047 | 0.15 |
| FOXO1 | 2 | 1613 | -1.679 | 6.3e-10 | 5.1e-07 |
| DNMT1 | 10 | 1613 | -1.573 | 3.1e-05 | 0.0039 |
| ZNF217 | 1611 | 1613 | 1.017 | 4.2e-07 | 0.00013 |
| GATA3 | 1612 | 1613 | 0.932 | 3.6e-07 | 0.00013 |
| AHR | 1613 | 1613 | 1.068 | 4.7e-09 | 2.5e-06 |

## Agreement with the published table

Published: `paper/T6D_mageck_ko_withBATF3.tsv` (score `neg|score`, lower is stronger); 1613 genes, 1613 shared with BARCS.

Spearman correlation of gene scores: **0.74**


Effect direction agreement: 86.8% of 1613 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 36 | 0.56 | 14 | 14 |
| 100 | 72 | 0.56 | 28 | 28 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): KAT7 (15 / 26), DR1 (19 / 47), FOXD4L6 (20 / 58), FOXD4L1 (22 / 38), ZNF236 (25 / 30)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): NANOGNB (19 / 1285), SOX9 (21 / 47), ZNF506 (23 / 1289), MYT1 (24 / 27), MYC (25 / 31)

## BARCS calls

Genes at FDR 0.05: 26; at FDR 0.10: 38. Top 15: IL7R, FOXO1, MBD2, MYBL2, DRAP1, DUX4, GTF2B, HIC1, ZNF626, DNMT1, ZBTB17, BATF3, FOXD4L3, HINFP, KAT7
