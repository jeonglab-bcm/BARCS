# BARCS versus published results

BARCS genes: `results/YFPlow_vs_unsorted/genes.csv` (19113 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| EIF5A | 20 | 19113 | 1.849 | 0.011 | 0.24 |
| BOLA3 | 594 | 19113 | 0.847 | 0.15 | 0.62 |
| COMMD10 | 580 | 19113 | 1.017 | 0.15 | 0.62 |

## Agreement with the published table

Published: `paper/SD1_YFPlow_combined.tsv` (score `combined_p`, lower is stronger); 19364 genes, 19097 shared with BARCS.

Spearman correlation of gene scores: **0.65**


Effect direction agreement: 80.2% of 19097 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 14 | 0.16 | 36 | 36 |
| 100 | 25 | 0.14 | 75 | 75 |
| 200 | 65 | 0.19 | 135 | 135 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): NDUFA10 (2 / 53), C4orf27 (3 / 54), PCDHB7 (6 / 4289), CNOT10 (7 / 1082), ENOX2 (8 / 198), ZBTB38 (9 / 490), ZNF740 (10 / 138), GYG1 (11 / 554), GBAS (12 / 72), GPATCH4 (14 / 565), KAT7 (15 / 364), GLTPD2 (17 / 211), ASB12 (19 / 135), RBM12B (21 / 124), DPH5 (23 / 130), ZNF382 (24 / 653), DPH6 (25 / 113), OR6N2 (27 / 59), C12orf74 (28 / 107), MRPL39 (29 / 570), CD8A (30 / 1511), RBMY1F (33 / 6678), GJD4 (34 / 141), PCNXL4 (35 / 464), SLC23A3 (36 / 591)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): C9orf139 (1 / 9619), CELF6 (2 / 287), NIM1K (5 / 167), WNT5A (6 / 16422), DCP1B (10 / 4183), CASP2 (12 / 8174), PRTFDC1 (13 / 702), SERPINB7 (14 / 329), PCDHAC1 (16 / 1096), SLC11A2 (17 / 134), EFCAB13 (19 / 4300), CC2D2B (23 / 172), CYB5RL (24 / 1598), FNBP4 (25 / 1457), CMTM2 (27 / 206), PAQR6 (29 / 558), NDUFAF3 (30 / 103), TLX1 (31 / 149), TFB1M (32 / 163), DNAJC24 (33 / 1054), SLC52A3 (35 / 343), CCNB1IP1 (36 / 76), TNFRSF10C (37 / 143), SLX1B (38 / 757), ABHD13 (39 / 994)

## BARCS calls

Genes at FDR 0.05: 167; at FDR 0.10: 321. Top 15: GORAB, NDUFA10, C4orf27, MGC50722, HIST1H2AL, PCDHB7, CNOT10, ENOX2, ZBTB38, ZNF740, GYG1, GBAS, EZH2, GPATCH4, KAT7
