# BARCS versus published results

BARCS genes: `results/WT_vs_KO/genes.csv` (356 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TGGT1_205250 | 1 | 356 | -2.807 | 1.7e-11 | 6e-09 |

## Agreement with the published table

Published: `paper/wt_vs_ko.tsv` (score `p`, lower is stronger); 361 genes, 356 shared with BARCS.

Spearman correlation of gene scores: **0.64**


Effect direction agreement: 59.0% of 356 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 17 | 0.52 | 8 | 8 |
| 50 | 32 | 0.47 | 18 | 18 |
| 100 | 64 | 0.47 | 36 | 36 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): TGGT1_265360 (10 / 45), TGGT1_216810 (11 / 54), TGGT1_320015 (12 / 28), TGGT1_255400 (13 / 49), TGGT1_311110 (18 / 27), TGGT1_273640 (19 / 133), TGGT1_260450 (22 / 163), TGGT1_226400 (25 / 167)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): TGGT1_211695 (14 / 26), TGGT1_218200 (15 / 57), TGGT1_295340 (16 / 27), TGGT1_211250 (18 / 29), TGGT1_319570 (19 / 39), TGGT1_229650 (21 / 86), TGGT1_304660 (23 / 31), TGGT1_224990 (25 / 51)

## BARCS calls

Genes at FDR 0.05: 10; at FDR 0.10: 14. Top 15: TGGT1_205250, TGGT1_309590, TGGT1_215890, TGGT1_247590, TGGT1_297880, TGGT1_235490, TGGT1_204350, TGGT1_247760, TGGT1_282090, TGGT1_265360, TGGT1_216810, TGGT1_320015, TGGT1_255400, TGGT1_229000, TGGT1_263750
