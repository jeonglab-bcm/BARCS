# BARCS versus published results

BARCS genes: `results/in_vivo_vs_in_vitro/genes.csv` (295 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TGGT1_211850 | 1 | 295 | -6.776 | 1.5e-38 | 4.4e-36 |
| TGGT1_224060 | 2 | 295 | -5.400 | 4.1e-37 | 6e-35 |
| TGGT1_282190 | 3 | 295 | -5.061 | 1.8e-35 | 1.6e-33 |
| TGGT1_221170 | 29 | 295 | -2.934 | 6.5e-13 | 6.6e-12 |
| TGGT1_266800 | 6 | 295 | -4.122 | 3.6e-30 | 1.8e-28 |
| TGGT1_304680 | 10 | 295 | -6.542 | 9.1e-24 | 2.7e-22 |
| TGGT1_277840 | 4 | 295 | -7.833 | 2.1e-35 | 1.6e-33 |
| TGGT1_239752 | 8 | 295 | -7.457 | 1.4e-27 | 5.2e-26 |
| TGGT1_310070 | 18 | 295 | -3.521 | 2.1e-17 | 3.4e-16 |
| TGGT1_221190 | 13 | 295 | -4.389 | 1.9e-19 | 4.4e-18 |

## Agreement with the published table

Published: `suppl/GSE253884_unassigned_1_summary.xlsx` (score `adj.p.value (in vitro vs. in vivo)`, lower is stronger); 295 genes, 295 shared with BARCS.

Spearman correlation of gene scores: **0.28**


Effect direction agreement: 78.6% of 295 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 15 | 8 | 0.36 | 7 | 7 |
| 30 | 14 | 0.30 | 16 | 16 |
| 50 | 21 | 0.27 | 29 | 29 |

### In the BARCS top 15 but not the published top 15

Gene (BARCS rank / published rank): TGGT1_277840 (4 / 24), TGGT1_208390 (5 / 27), TGGT1_206580 (11 / 28), TGGT1_236270 (12 / 116), TGGT1_221190 (13 / 38), TGGT1_243450 (14 / 77), TGGT1_217340 (15 / 63)

### In the published top 15 but not the BARCS top 15

Gene (published rank / BARCS rank): TGGT1_249390 (9 / 92), TGGT1_244280 (10 / 208), TGGT1_311470 (11 / 291), TGGT1_312570 (12 / 192), TGGT1_243250 (13 / 232), TGGT1_255370 (14 / 145), TGGT1_209030 (15 / 187)

## BARCS calls

Genes at FDR 0.05: 185; at FDR 0.10: 198. Top 15: TGGT1_211850, TGGT1_224060, TGGT1_282190, TGGT1_277840, TGGT1_208390, TGGT1_266800, TGGT1_205250, TGGT1_239752, TGGT1_297880, TGGT1_304680, TGGT1_206580, TGGT1_236270, TGGT1_221190, TGGT1_243450, TGGT1_217340
