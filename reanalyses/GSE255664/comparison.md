# BARCS versus published results

BARCS genes: `results/EXO1KO_vs_WT_D16/genes.csv` (19114 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ZRSR2 | 16 | 19114 | -0.493 | 0.00036 | 0.16 |
| FAM175A | 3 | 19114 | -0.829 | 7.5e-08 | 0.00048 |
| BRCC3 | 25 | 19114 | -0.616 | 0.00091 | 0.24 |
| BABAM1 | 6639 | 19114 | -0.074 | 0.61 | 0.93 |
| FANCG | 2349 | 19114 | -0.643 | 0.18 | 0.76 |
| FANCM | 9646 | 19114 | -0.042 | 0.96 | 0.99 |
| C19orf40 | 53 | 19114 | -0.755 | 0.0024 | 0.33 |
| APITD1 | 11 | 19114 | -0.828 | 0.00014 | 0.13 |
| STRA13 | 2 | 19114 | -0.824 | 5.1e-08 | 0.00048 |
| FANCB | 1534 | 19114 | -0.262 | 0.11 | 0.72 |
| FANCC | 434 | 19114 | -0.544 | 0.025 | 0.52 |
| FANCE | 423 | 19114 | -0.453 | 0.024 | 0.51 |
| FANCF | 827 | 19114 | -0.648 | 0.056 | 0.63 |
| FANCL | 3716 | 19114 | -0.447 | 0.31 | 0.83 |
| FANCD2 | 4122 | 19114 | -0.163 | 0.35 | 0.85 |
| CDK11B | 346 | 19114 | -0.472 | 0.019 | 0.49 |

## Agreement with the published table

Published: `paper/SD2_day16_ko_depleted.tsv` (score `ko_depleted_score`, lower is stronger); 19113 genes, 19086 shared with BARCS.

Spearman correlation of gene scores: **0.67**


Effect direction agreement: 81.5% of 19086 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 10 | 0.25 | 15 | 15 |
| 50 | 14 | 0.16 | 36 | 36 |
| 100 | 33 | 0.20 | 67 | 67 |
| 200 | 71 | 0.22 | 129 | 129 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): PPM1B (5 / 103), SLC5A11 (6 / 44), C12orf76 (7 / 2674), SRSF5 (8 / 248), RAD18 (10 / 54), PRDX1 (12 / 98), ZCCHC14 (13 / 206), RAD51AP1 (14 / 62), RNF213 (17 / 444), HMCES (19 / 174), DCLRE1A (20 / 333), SRGAP2 (21 / 56), TFPT (22 / 392), C1orf86 (24 / 416), TIAF1 (26 / 40)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): DCAF4L2 (6 / 12831), AOC3 (7 / 323), TTN (9 / 1275), ZBTB7A (10 / 34), NPBWR2 (11 / 204), SCUBE3 (13 / 1921), GPAM (14 / 855), CLCF1 (16 / 326), ERCC8 (17 / 70), BTG1 (18 / 61), IVNS1ABP (19 / 501), HGC6.3 (20 / 2586), POLR1C (22 / 16516), MSR1 (23 / 490), N4BP2 (25 / 304)

## BARCS calls

Genes at FDR 0.05: 5; at FDR 0.10: 10. Top 15: RMI2, STRA13, FAM175A, ACAD10, PPM1B, SLC5A11, C12orf76, SRSF5, SEPT8, RAD18, APITD1, PRDX1, ZCCHC14, RAD51AP1, MND1
