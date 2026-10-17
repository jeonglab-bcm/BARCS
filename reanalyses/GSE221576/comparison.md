# BARCS versus published results

BARCS genes: `results/GSI_vs_DMSO/genes.csv` (20708 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PIK3R1 | 1 | 20708 | 1.379 | 4.9e-23 | 1e-18 |
| CDK6 | 8 | 20708 | -1.707 | 2.9e-10 | 7.4e-07 |
| NOTCH1 | 19 | 20708 | -1.236 | 7.2e-08 | 7.8e-05 |
| DCAF7 | 4 | 20708 | -1.579 | 2.1e-13 | 1.1e-09 |
| PCGF1 | 6 | 20708 | 1.860 | 7e-11 | 2.4e-07 |
| BCL11B | 7 | 20708 | 1.499 | 1.2e-10 | 3.4e-07 |
| PTEN | 1738 | 20708 | 0.505 | 0.036 | 0.42 |

## Agreement with the published table

Published: `paper/gsi_vs_dmso.tsv` (score `p`, lower is stronger); 18961 genes, 18937 shared with BARCS.

Spearman correlation of gene scores: **0.45**


Effect direction agreement: 79.1% of 18937 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 16 | 0.47 | 9 | 9 |
| 50 | 30 | 0.43 | 20 | 20 |
| 100 | 57 | 0.40 | 43 | 43 |
| 200 | 110 | 0.38 | 90 | 90 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): RAB10 (15 / 38), JAK1 (21 / 41), MED23 (22 / 311), ELP4 (26 / 42), HMBOX1 (28 / 37), DOT1L (31 / 117), TM9SF3 (33 / 55), RAB1B (41 / 34), DDI2 (44 / 65)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): CKS1B (13 / 179), hsa-mir-3929 (14 / 139), HSPA8 (16 / 55), CHD1 (17 / 124), DIDO1 (18 / 48), SYNCRIP (21 / 242), MME (22 / 112), RNF19B (23 / 202), OXNAD1 (25 / 358)

## BARCS calls

Genes at FDR 0.05: 208; at FDR 0.10: 313. Top 15: PIK3R1, EXTL3, SOCS1, DCAF7, ELP3, PCGF1, BCL11B, CDK6, EXT1, B4GALT7, CCNC, CDKN2C, DPY30, ELP5, RAB10
