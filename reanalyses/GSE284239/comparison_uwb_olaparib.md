# BARCS versus published results

BARCS genes: `results/uwb_olaparib_vs_dmso/genes.csv` (1178 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PARP1 | 21 | 1178 | 1.416 | 0.07 | 1 |

## Agreement with the published table

Published: `paper/tableS7.csv` (score `signed_score`, higher is stronger); 1179 genes, 1178 shared with BARCS.

Spearman correlation of gene scores: **0.65**


Effect direction agreement: 77.2% of 1178 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 13 | 0.48 | 7 | 7 |
| 50 | 37 | 0.59 | 13 | 13 |
| 100 | 71 | 0.55 | 29 | 29 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): PARG (5 / 24), MPG (8 / 21), BRE (11 / 53), PPP1CC (14 / 22), MAP7D1 (15 / 48), PARP2 (18 / 78), RALGAPB (19 / 23)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): TYMS (11 / 43), THUMPD2 (12 / 31), FUT1 (13 / 38), ZNF428 (16 / 22), CDKN2A (18 / 29), FAM35A (19 / 45), PIAS1 (20 / 32)

## BARCS calls

Genes at FDR 0.05: 3; at FDR 0.10: 3. Top 15: E2F7, RB1, CTC-534A2.2, GET4, PARG, TP53BP1, SERF2, MPG, TMEM208, UIMC1, BRE, SMARCD1, C20orf196, PPP1CC, MAP7D1
