# BARCS versus published results

BARCS genes: `results/WT_vs_KO/genes.csv` (391 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TGGT1_205250 | 1 | 391 | -3.589 | 7.7e-33 | 3e-30 |

## Agreement with the published table

Published: `paper/wt_vs_ko.tsv` (score `p`, lower is stronger); 395 genes, 391 shared with BARCS.

Spearman correlation of gene scores: **0.28**


Effect direction agreement: 69.1% of 391 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 12 | 0.32 | 13 | 13 |
| 50 | 26 | 0.35 | 24 | 24 |
| 100 | 58 | 0.41 | 42 | 42 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): TGGT1_269010 (7 / 58), TGGT1_284050 (8 / 361), TGGT1_310050 (9 / 31), TGGT1_236560 (10 / 28), TGGT1_291600 (11 / 39), TGGT1_295650 (13 / 54), TGGT1_208400B (14 / 373), TGGT1_208400A (15 / 49), TGGT1_206320 (16 / 90), TGGT1_257340 (17 / 51), TGGT1_234220 (20 / 33), TGGT1_283710 (23 / 55), TGGT1_258770 (24 / 99)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): TGGT1_255370 (2 / 171), TGGT1_217480 (6 / 41), TGGT1_312570 (7 / 219), TGGT1_216020 (8 / 81), TGGT1_290160 (9 / 326), TGGT1_243250 (11 / 255), TGGT1_264020 (13 / 336), TGGT1_301440 (15 / 244), TGGT1_210408 (18 / 42), TGGT1_235470 (20 / 78), TGGT1_222360 (22 / 48), TGGT1_297880 (23 / 82), TGGT1_307810 (26 / 30)

## BARCS calls

Genes at FDR 0.05: 137; at FDR 0.10: 160. Top 15: TGGT1_205250, TGGT1_318720, TGGT1_306030, TGGT1_203160, TGGT1_254710, TGGT1_235660, TGGT1_269010, TGGT1_284050, TGGT1_310050, TGGT1_236560, TGGT1_291600, TGGT1_309800, TGGT1_295650, TGGT1_208400B, TGGT1_208400A
