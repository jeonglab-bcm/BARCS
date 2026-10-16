# BARCS versus published results

BARCS genes: `results/PDL1_GW_low_vs_high/genes.csv` (19674 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Cd274 | 2 | 19674 | 2.279 | 0.0007 | 1 |
| Cebpb | 32 | 19674 | 1.645 | 0.02 | 1 |

## Agreement with the published table

Published: `paper/pdl1_gw_mageck.tsv` (score `min_p`, lower is stronger); 19675 genes, 19674 shared with BARCS.

Spearman correlation of gene scores: **0.45**


Effect direction agreement: 91.0% of 19674 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 1 | 0.05 | 9 | 9 |
| 25 | 2 | 0.04 | 23 | 23 |
| 50 | 13 | 0.15 | 37 | 37 |
| 100 | 27 | 0.16 | 73 | 73 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Nfe2l2 (1 / 75), Yipf6 (3 / 31), Trp53 (4 / 53), Nlrp12 (5 / 48), Cdkn1a (6 / 592), Trabd (7 / 32), Clec5a (8 / 64), Rasa3 (9 / 39), Diap1 (10 / 13)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Akr1cl (2 / 4378), Sh2d7 (3 / 19133), Mbip (4 / 17602), Cebpb (5 / 32), Ly6c1 (6 / 6588), Prss45 (7 / 19185), Snap29 (8 / 16905), Man2b2 (9 / 12708), Lmf1 (10 / 18024)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: Nfe2l2, Cd274, Yipf6, Trp53, Nlrp12, Cdkn1a, Trabd, Clec5a, Rasa3, Diap1, Yeats4, Abca6, Git1, Syt6, Vmn2r67
