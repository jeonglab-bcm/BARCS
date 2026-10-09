# BARCS versus published results

BARCS genes: `results/CRISPRa_CCR7_high_vs_low/genes.csv` (120 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| BATF3 | 57 | 120 | 0.025 | 0.32 | 0.67 |
| BATF | 90 | 120 | 0.050 | 0.59 | 0.78 |
| EOMES | 34 | 120 | 0.135 | 0.11 | 0.37 |
| BHLHE40 | 107 | 120 | 0.150 | 0.81 | 0.91 |
| JUN | 71 | 120 | -0.025 | 0.43 | 0.72 |
| ZFP1 | 59 | 120 | 0.113 | 0.33 | 0.68 |

## Agreement with the published table

Published: `paper/T2F_gene_level_CRISPRa.tsv` (score `gene_p`, lower is stronger); 125 genes, 120 shared with BARCS.

Spearman correlation of gene scores: **-0.01**


Effect direction agreement: 76.7% of 120 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 0 | 0.00 | 5 | 5 |
| 10 | 1 | 0.05 | 9 | 9 |
| 14 | 1 | 0.04 | 13 | 13 |
| 25 | 2 | 0.04 | 23 | 23 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): BHLHE41 (1 / 32), HIC1 (2 / 31), BACH1 (3 / 37), CREB1 (4 / 39), LEF1 (5 / 74)

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): BATF (1 / 90), BATF3 (2 / 57), EOMES (3 / 34), BHLHE40 (4 / 107), ZFP1 (5 / 59)

## BARCS calls

Genes at FDR 0.05: 2; at FDR 0.10: 2. Top 15: BHLHE41, HIC1, BACH1, CREB1, LEF1, DNMT3B, FLI1, KLF9, STAT5B, NR4A1, MEF2A, NFKB2, NFE2L2, STAT6, IRF2
