# BARCS versus published results

BARCS genes: `results/P4_vs_WT/genes.csv` (360 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TGGT1_205250 | 7 | 360 | -2.261 | 1.9e-16 | 9.5e-15 |

## Agreement with the published table

Published: `paper/p4_vs_wt.tsv` (score `p`, lower is stronger); 361 genes, 360 shared with BARCS.

Spearman correlation of gene scores: **0.32**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 13 | 0.35 | 12 | 12 |
| 50 | 27 | 0.37 | 23 | 23 |
| 100 | 52 | 0.35 | 48 | 48 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): TGGT1_258380 (1 / 31), TGGT1_318310 (11 / 57), TGGT1_257490 (12 / 78), TGGT1_270310 (14 / 35), TGGT1_225990 (15 / 329), TGGT1_227970 (17 / 187), TGGT1_255400 (18 / 327), TGGT1_315110 (19 / 67), TGGT1_247670 (21 / 66), TGGT1_221490 (23 / 33), TGGT1_259660 (24 / 40), TGGT1_289210 (25 / 59)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): TGGT1_238070 (7 / 33), TGGT1_312570 (8 / 40), TGGT1_309590 (9 / 141), TGGT1_231940 (12 / 70), TGGT1_213830 (13 / 35), TGGT1_240980 (14 / 182), TGGT1_219520 (18 / 55), TGGT1_247760 (19 / 54), TGGT1_293590 (21 / 154), TGGT1_232660 (22 / 241), TGGT1_319570 (24 / 48), TGGT1_243250 (25 / 90)

## BARCS calls

Genes at FDR 0.05: 162; at FDR 0.10: 193. Top 15: TGGT1_258380, TGGT1_204350, TGGT1_297880, TGGT1_237140, TGGT1_305800, TGGT1_218200, TGGT1_205250, TGGT1_281490, TGGT1_281430, TGGT1_295340, TGGT1_318310, TGGT1_257490, TGGT1_311090, TGGT1_270310, TGGT1_225990
