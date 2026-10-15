# BARCS versus published results

BARCS genes: `results/inx315_vs_dmso/genes.csv` (18006 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CDK2 | 1 | 18006 | 1.730 | 5.4e-06 | 0.048 |

## Agreement with the published table

Published: `paper/SupplementaryData2.xlsx` (score `normZ`, higher is stronger); 18049 genes, 17980 shared with BARCS.

Spearman correlation of gene scores: **0.94**


Effect direction agreement: 82.1% of 17980 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 14 | 0.54 | 6 | 6 |
| 50 | 30 | 0.43 | 20 | 20 |
| 100 | 58 | 0.41 | 42 | 42 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): PPP1CA (10 / 27), MGEA5 (12 / 130), RASGRF2 (14 / 33), AMD1 (16 / 25), NSL1 (17 / 30), KLF6 (18 / 44)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): PDHB (8 / 51), TET1 (13 / 55), PPP2R2A (15 / 21), KATNAL2 (16 / 125), FCGR2A (18 / 474), FCRL6 (21 / 128)

## BARCS calls

Genes at FDR 0.05: 2; at FDR 0.10: 3. Top 15: CDK2, DYRK1A, HEXIM1, CELF1, SERGEF, FBXW7, PPP2R3C, INO80, LIN7C, PPP1CA, TTL, MGEA5, ATF7IP, RASGRF2, ANKRD32
