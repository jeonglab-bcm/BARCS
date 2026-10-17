# BARCS versus published results

BARCS genes: `results/ptar1_vs_wt_gi/genes.csv` (18050 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ABHD16A | 26 | 18050 | 0.556 | 8.6e-10 | 4.9e-07 |
| ABHD17B | 2 | 18050 | 0.842 | 1.1e-29 | 9.5e-26 |

## Agreement with the published table

Published: `paper/PTAR1_qGI.csv` (score `qGI_medium_mean`, higher is stronger); 17724 genes, 17722 shared with BARCS.

Spearman correlation of gene scores: **0.58**


Effect direction agreement: 68.6% of 17722 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 17 | 0.20 | 33 | 33 |
| 100 | 32 | 0.19 | 68 | 68 |
| 200 | 65 | 0.19 | 135 | 135 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): CCNC (5 / 107), SUPT20H (9 / 57), TAF5L (13 / 231), BBC3 (14 / 83), CAB39 (18 / 9894), XPNPEP3 (19 / 183), RBM39 (20 / 94), PSMD2 (23 / 133), GMEB1 (24 / 145), OGT (28 / 415), UXT (30 / 349), PSMC4 (31 / 1075), MRPL41 (32 / 575), WTAP (34 / 96), CDK4 (35 / 4676), DAZAP1 (36 / 138), VPS72 (38 / 4973), ZNF740 (39 / 225), YLPM1 (40 / 141), TAMM41 (41 / 1793), HRK (42 / 65), AHSA1 (43 / 204), ASH2L (44 / 6025), OTUD6B (46 / 336), TSC22D2 (47 / 723)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): SLC39A9 (4 / 71), PTAR1 (8 / 77), CTNNA1 (10 / 1080), UQCC1 (13 / 251), ANLN (14 / 577), AGO2 (15 / 695), PPOX (16 / 297), TACO1 (18 / 121), RAB5C (19 / 1172), ARID4A (20 / 176), UBE3D (22 / 85), SURF1 (23 / 356), VPS8 (24 / 379), C12orf23 (25 / 143), ZCCHC14 (28 / 1042), CLPB (29 / 302), PBRM1 (31 / 248), USP7 (33 / 1301), SH3GL1 (34 / 624), KDM2A (35 / 149), FAM122A (36 / 70), PTP4A2 (37 / 3037), UBFD1 (38 / 619), ALAD (39 / 367), TMEM161B (40 / 731)

## BARCS calls

Genes at FDR 0.05: 629; at FDR 0.10: 1035. Top 15: TADA1, ABHD17B, ARF1, REXO2, CCNC, BAX, NF2, PMAIP1, SUPT20H, ADIPOR2, TADA2B, BPTF, TAF5L, BBC3, METTL3
