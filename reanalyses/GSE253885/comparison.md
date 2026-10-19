# BARCS versus published results

BARCS genes: `results/in_vivo_vs_in_vitro/genes.csv` (295 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TGGT1_321310 | 2 | 295 | -5.601 | 1.7e-23 | 2.5e-21 |
| TGGT1_237280 | 6 | 295 | -3.725 | 5.9e-16 | 2.9e-14 |
| TGGT1_203380 | 10 | 295 | -3.619 | 9.2e-15 | 2.5e-13 |
| TGGT1_267710 | 17 | 295 | -2.649 | 5.2e-12 | 8.9e-11 |
| TGGT1_240660 | 37 | 295 | -2.016 | 5.5e-08 | 4.4e-07 |
| TGGT1_300220 | 4 | 295 | -4.153 | 4.3e-20 | 3.2e-18 |
| TGGT1_312840 | 1 | 295 | -3.677 | 4.8e-24 | 1.4e-21 |
| TGGT1_277870 | 3 | 295 | -4.521 | 5e-23 | 4.9e-21 |
| TGGT1_250790 | 11 | 295 | -2.614 | 9.5e-15 | 2.5e-13 |
| TGGT1_221640 | 22 | 295 | -3.385 | 7e-11 | 9.4e-10 |
| TGGT1_273905 | 46 | 295 | -2.074 | 3.9e-07 | 2.5e-06 |

## Agreement with the published table

Published: `suppl/GSE253885_unassigned_2_summary.xlsx` (score `adj.p.value (in vitro vs. in vivo)`, lower is stronger); 295 genes, 295 shared with BARCS.

Spearman correlation of gene scores: **0.36**


Effect direction agreement: 70.5% of 295 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 15 | 8 | 0.36 | 7 | 7 |
| 30 | 14 | 0.30 | 16 | 16 |
| 50 | 25 | 0.33 | 25 | 25 |

### In the BARCS top 15 but not the published top 15

Gene (BARCS rank / published rank): TGGT1_237280 (6 / 22), TGGT1_309190 (7 / 70), TGGT1_318760 (8 / 32), TGGT1_228150 (9 / 102), TGGT1_203380 (10 / 39), TGGT1_250790 (11 / 23), TGGT1_274050 (13 / 24)

### In the published top 15 but not the BARCS top 15

Gene (published rank / BARCS rank): TGGT1_312520 (4 / 32), TGGT1_319560 (5 / 98), TGGT1_255370 (6 / 108), TGGT1_293690 (10 / 70), TGGT1_312820 (11 / 83), TGGT1_320120 (13 / 131), TGGT1_309590 (15 / 122)

## BARCS calls

Genes at FDR 0.05: 146; at FDR 0.10: 157. Top 15: TGGT1_312840, TGGT1_321310, TGGT1_277870, TGGT1_300220, TGGT1_224600, TGGT1_237280, TGGT1_309190, TGGT1_318760, TGGT1_228150, TGGT1_203380, TGGT1_250790, TGGT1_297880, TGGT1_274050, TGGT1_205250, TGGT1_310170
