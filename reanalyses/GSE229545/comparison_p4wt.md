# BARCS versus published results

BARCS genes: `results/P4_vs_WT/genes.csv` (376 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TGGT1_308090 | 1 | 376 | -4.733 | 2.7e-36 | 1e-33 |
| TGGT1_205250 | 3 | 376 | -3.206 | 3.9e-27 | 4.9e-25 |
| TGGT1_288650 | 2 | 376 | -3.036 | 5.7e-28 | 1.1e-25 |
| TGGT1_316250 | 7 | 376 | -3.112 | 4.3e-22 | 2.3e-20 |

## Agreement with the published table

Published: `paper/p4_vs_wt.tsv` (score `p`, lower is stronger); 376 genes, 376 shared with BARCS.

Spearman correlation of gene scores: **-0.02**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 13 | 0.35 | 12 | 12 |
| 50 | 23 | 0.30 | 27 | 27 |
| 100 | 36 | 0.22 | 64 | 64 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): TGGT1_321650 (4 / 123), TGGT1_230350 (13 / 28), TGGT1_306060 (15 / 194), TGGT1_228170 (17 / 345), TGGT1_213069 (18 / 336), TGGT1_310010 (19 / 50), TGGT1_235130 (20 / 74), TGGT1_462965 (21 / 359), TGGT1_272460 (22 / 49), TGGT1_236110 (23 / 374), TGGT1_233905 (24 / 326), TGGT1_220400 (25 / 41)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): TGGT1_250770 (7 / 52), TGGT1_237880 (8 / 38), TGGT1_236870 (10 / 231), TGGT1_225150 (12 / 155), TGGT1_309590 (13 / 139), TGGT1_215160 (14 / 103), TGGT1_203310 (15 / 94), TGGT1_251780 (17 / 44), TGGT1_237230 (18 / 273), TGGT1_258870A (20 / 49), TGGT1_208360 (23 / 108), TGGT1_312420 (24 / 302)

## BARCS calls

Genes at FDR 0.05: 131; at FDR 0.10: 140. Top 15: TGGT1_308090, TGGT1_288650, TGGT1_205250, TGGT1_321650, TGGT1_297880, TGGT1_205380, TGGT1_316250, TGGT1_243730, TGGT1_204130, TGGT1_203600, TGGT1_222170, TGGT1_260030, TGGT1_230350, TGGT1_233460, TGGT1_306060
