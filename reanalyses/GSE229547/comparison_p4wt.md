# BARCS versus published results

BARCS genes: `results/P4_vs_WT/genes.csv` (395 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TGGT1_205250 | 8 | 395 | -3.640 | 3.8e-40 | 1.9e-38 |

## Agreement with the published table

Published: `paper/p4_vs_wt.tsv` (score `p`, lower is stronger); 395 genes, 395 shared with BARCS.

Spearman correlation of gene scores: **0.43**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 15 | 0.43 | 10 | 10 |
| 50 | 27 | 0.37 | 23 | 23 |
| 100 | 55 | 0.38 | 45 | 45 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): TGGT1_258240 (10 / 165), TGGT1_268580 (14 / 113), TGGT1_203160 (15 / 32), TGGT1_254710 (17 / 70), TGGT1_263710 (19 / 359), TGGT1_269010 (21 / 122), TGGT1_309800 (22 / 37), TGGT1_242720 (23 / 240), TGGT1_288250 (24 / 76), TGGT1_282220 (25 / 90)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): TGGT1_209030 (5 / 54), TGGT1_232730 (7 / 43), TGGT1_255310 (12 / 297), TGGT1_293690 (14 / 179), TGGT1_245470 (16 / 172), TGGT1_318460 (17 / 41), TGGT1_263320 (20 / 80), TGGT1_309590 (23 / 214), TGGT1_216020 (24 / 32), TGGT1_226430 (25 / 290)

## BARCS calls

Genes at FDR 0.05: 210; at FDR 0.10: 229. Top 15: TGGT1_210408, TGGT1_257510, TGGT1_257340, TGGT1_227790, TGGT1_279390, TGGT1_270865, TGGT1_306030, TGGT1_205250, TGGT1_310050, TGGT1_258240, TGGT1_297880, TGGT1_205750, TGGT1_242080, TGGT1_268580, TGGT1_203160
