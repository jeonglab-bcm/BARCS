# BARCS versus published results

BARCS genes: `results/A375_day21_vs_day0/genes.csv` (805 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| 15:99982353-99983277 | 3 | 805 | 0.469 | 0.00086 | 0.014 |
| 10:89986509-89987396 | 17 | 805 | 0.282 | 0.015 | 0.065 |
| 17:29645182-29645793 | 5 | 805 | 0.194 | 0.0022 | 0.023 |

## Agreement with the published table

Published: `paper/A375_day21_mageck_positive.tsv` (score `Score`, lower is stronger); 66 genes, 66 shared with BARCS.

Spearman correlation of gene scores: **0.29**


Effect direction agreement: 75.8% of 66 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 4 | 0.25 | 6 | 6 |
| 25 | 11 | 0.28 | 14 | 14 |
| 66 | 66 | 1.00 | 0 | 0 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): 13:26306137-26306861 (2 / 21), 17:29596554-29597122 (4 / 26), 17:1325981-1326684 (6 / 20), 17:27466969-27467964 (7 / 62), 7:56077329-56077993 (8 / 58), 19:47538458-47539506 (10 / 38)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): 10:89986509-89987396 (2 / 17), 21:43104479-43105245 (4 / 74), 3:10641684-10643470 (5 / 367), 2:239896254-239896930 (6 / 13), 2:238374165-238374684 (7 / 417), 16:10956165-10956839 (9 / 497)

## BARCS calls

Genes at FDR 0.05: 150; at FDR 0.10: 226. Top 15: 19:782013-782915, 13:26306137-26306861, 15:99982353-99983277, 17:29596554-29597122, 17:29645182-29645793, 17:1325981-1326684, 17:27466969-27467964, 7:56077329-56077993, 11:102123182-102123525, 19:47538458-47539506, 22:38636729-38637400, 10:89430361-89431809, 2:239896254-239896930, 7:55766472-55767180, 19:46084637-46085209
