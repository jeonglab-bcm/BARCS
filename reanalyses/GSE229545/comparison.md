# BARCS versus published results

BARCS genes: `results/WT_vs_KO/genes.csv` (368 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TGGT1_308090 | 3 | 368 | -3.440 | 1.6e-15 | 1.9e-13 |
| TGGT1_205250 | 2 | 368 | -3.603 | 5.9e-18 | 1.1e-15 |
| TGGT1_288650 | 1 | 368 | -2.681 | 2.6e-18 | 9.4e-16 |
| TGGT1_316250 | 4 | 368 | -2.135 | 8.7e-13 | 8e-11 |

## Agreement with the published table

Published: `paper/wt_vs_ko.tsv` (score `p`, lower is stronger); 376 genes, 368 shared with BARCS.

Spearman correlation of gene scores: **-0.09**


Effect direction agreement: 60.9% of 368 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 8 | 0.19 | 17 | 17 |
| 50 | 13 | 0.15 | 37 | 37 |
| 100 | 24 | 0.14 | 76 | 76 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): TGGT1_203310 (6 / 73), TGGT1_258870A (9 / 41), TGGT1_279100 (10 / 165), TGGT1_309590 (11 / 26), TGGT1_281450 (12 / 254), TGGT1_310010 (13 / 28), TGGT1_252500 (14 / 281), TGGT1_258580 (15 / 366), TGGT1_240390 (16 / 264), TGGT1_211290 (18 / 147), TGGT1_315490 (19 / 149), TGGT1_203600 (20 / 46), TGGT1_269950 (21 / 317), TGGT1_260030 (22 / 74), TGGT1_304740 (23 / 204), TGGT1_254470 (24 / 225), TGGT1_276130 (25 / 129)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): TGGT1_310160 (6 / 351), TGGT1_280670 (7 / 231), TGGT1_304955 (8 / 206), TGGT1_208830 (11 / 356), TGGT1_207610 (12 / 249), TGGT1_203990 (13 / 157), TGGT1_310660 (14 / 359), TGGT1_252360 (15 / 321), TGGT1_231960 (16 / 355), TGGT1_239440 (17 / 211), TGGT1_230705 (18 / 269), TGGT1_202610 (19 / 201), TGGT1_239010 (20 / 212), TGGT1_315760 (21 / 234), TGGT1_259830 (22 / 179), TGGT1_315940 (23 / 146), TGGT1_244530 (25 / 334)

## BARCS calls

Genes at FDR 0.05: 55; at FDR 0.10: 71. Top 15: TGGT1_288650, TGGT1_205250, TGGT1_308090, TGGT1_316250, TGGT1_258870B, TGGT1_203310, TGGT1_237880, TGGT1_312420, TGGT1_258870A, TGGT1_279100, TGGT1_309590, TGGT1_281450, TGGT1_310010, TGGT1_252500, TGGT1_258580
