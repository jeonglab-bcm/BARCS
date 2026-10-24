# BARCS versus published results

BARCS genes: `results/OC43_1st_vs_T0/genes.csv` (19415 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TMEM41B | 3 | 19415 | 4.489 | 0.00091 | 0.0011 |
| SLC35B2 | 12 | 19415 | 5.810 | 0.037 | 0.039 |
| EXT1 | 19 | 19415 | 5.463 | 0.074 | 0.076 |
| multiKO_ENSCSAG00000011099_ENSCSAG00000011104 | 1 | 19415 | 7.899 | 0.00013 | 0.00016 |

## Agreement with the published table

Published: `paper/vero_oc43_mageck.tsv` (score `pos_score`, lower is stronger); 19415 genes, 19413 shared with BARCS.

Spearman correlation of gene scores: **0.66**


Effect direction agreement: 56.6% of 19413 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 10 | 0.33 | 10 | 10 |
| 50 | 21 | 0.27 | 29 | 29 |
| 100 | 38 | 0.23 | 62 | 62 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): PTP4A2 (5 / 23), C8orf34 (6 / 24), ENSCSAG00000005695 (7 / 50), multiKO_ENSCSAG00000004230_ENSCSAG00000004233 (9 / 183), ENSCSAG00000006191 (10 / 409), TPD52L1 (11 / 21), multiKO_ENSCSAG00000000076_ENSCSAG00000013661 (13 / 1421), ENSCSAG00000005692 (15 / 5309), ENSCSAG00000018909 (16 / 1221), N6AMT1 (18 / 450)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): C16orf74 (6 / 44), RAB25 (9 / 50), ENSCSAG00000000090 (11 / 111), USP27X (14 / 272), DLG2 (15 / 77), RNF122 (16 / 49), TMSB15A (17 / 37), GALM (18 / 853), BTBD6 (19 / 182), OPN5 (20 / 157)

## BARCS calls

Genes at FDR 0.05: 18642; at FDR 0.10: 18845. Top 15: multiKO_ENSCSAG00000011099_ENSCSAG00000011104, CDK4, TMEM41B, PLN, PTP4A2, C8orf34, ENSCSAG00000005695, SYS1, multiKO_ENSCSAG00000004230_ENSCSAG00000004233, ENSCSAG00000006191, TPD52L1, SLC35B2, multiKO_ENSCSAG00000000076_ENSCSAG00000013661, C3orf80, ENSCSAG00000005692
