# BARCS versus published results

BARCS genes: `results/CD86_secondary_low_vs_high/genes.csv` (2280 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Cd86 | 5 | 2280 | 0.965 | 5.3e-23 | 2.4e-20 |
| March1. | 1 | 2280 | -1.763 | 5.2e-115 | 1.2e-111 |
| Cebpb | 96 | 2280 | -0.346 | 0.0015 | 0.036 |
| Med12 | 10 | 2280 | -0.954 | 5.1e-17 | 1.2e-14 |

## Agreement with the published table

Published: `paper/cd86_sec_mageck.tsv` (score `min_p`, lower is stronger); 2281 genes, 2280 shared with BARCS.

Spearman correlation of gene scores: **0.71**


Effect direction agreement: 98.5% of 2280 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 46 | 0.85 | 4 | 4 |
| 100 | 87 | 0.77 | 13 | 13 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Eif2s3x (17 / 26), Med10 (20 / 32), Med14 (21 / 33), Slmo2 (22 / 35), Cars (25 / 43)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Hcfc1 (16 / 37), Polr2j (17 / 32), Eif3g (20 / 30), Eif2b4 (21 / 39), Spcs3 (22 / 27)

## BARCS calls

Genes at FDR 0.05: 105; at FDR 0.10: 120. Top 15: March1., Chd4, Hspa5, Prkar1a, Cd86, Egr2, Eif5, Ubl3, Paf1, Med12, Med30, Supt5, Ctr9, Stat5b, Polr2a
