# BARCS versus published results

BARCS genes: `results/ptar1_vs_wt_gi/genes.csv` (18050 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| VAMP3 | 6 | 18050 | -0.575 | 2.4e-10 | 1.7e-07 |
| RAB1A | 9 | 18050 | -0.682 | 5.7e-09 | 2.9e-06 |
| SEC23IP | 15 | 18050 | -0.625 | 4.4e-08 | 1.7e-05 |
| GOSR1 | 368 | 18050 | -0.321 | 0.0027 | 0.065 |
| TRAPPC12 | 68 | 18050 | -0.553 | 3.6e-05 | 0.0039 |
| YKT6 | 9639 | 18050 | -0.014 | 0.89 | 0.97 |

## Agreement with the published table

Published: `paper/PTAR1_qGI.csv` (score `qGI_medium_mean`, lower is stronger); 17724 genes, 17722 shared with BARCS.

Spearman correlation of gene scores: **0.58**


Effect direction agreement: 68.6% of 17722 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 20 | 0.25 | 30 | 30 |
| 100 | 39 | 0.24 | 61 | 61 |
| 200 | 68 | 0.20 | 132 | 132 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): TSSC1 (7 / 155), SEC23IP (15 / 89), CCS (16 / 123), GLUL (17 / 78), STUB1 (22 / 140), RABL3 (23 / 53), ARL8B (24 / 543), ZNF711 (26 / 902), PEX14 (32 / 139), TNS3 (33 / 163), ANKRD11 (34 / 58), HIST1H1C (35 / 52), HNRNPH2 (36 / 299), TBC1D7 (37 / 3329), CHMP5 (39 / 435), SLC25A37 (41 / 57), DGUOK (43 / 133), SPIN4 (44 / 259), TMEM60 (45 / 115), DOK2 (46 / 261), TIPRL (47 / 638), PTBP1 (48 / 316), ZMYM3 (49 / 242), FOXK2 (50 / 1350), TRABD (51 / 670)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): EXOC8 (5 / 71), ARL1 (10 / 146), GOSR1 (11 / 368), TRAPPC12 (12 / 68), TRAPPC13 (13 / 636), RABIF (14 / 117), TM9SF2 (19 / 6138), SCFD1 (20 / 5141), BET1L (21 / 104), COL4A3BP (23 / 141), FAM120A (24 / 335), JTB (25 / 694), E2F6 (26 / 2249), ACBD3 (27 / 153), TFRC (28 / 80), ICMT (29 / 263), SEC24B (31 / 1194), RNF145 (33 / 560), KIAA1432 (34 / 272), VPS37A (35 / 539), VPS39 (39 / 964), SPTLC2 (40 / 191), EXOC2 (42 / 3560), OSGEPL1 (44 / 358), TBPL1 (45 / 288)

## BARCS calls

Genes at FDR 0.05: 629; at FDR 0.10: 1035. Top 15: VAMP2, PICALM, RAB14, VAC14, ZDHHC5, VAMP3, TSSC1, DBF4, RAB1A, FASN, WDFY1, WDR44, GCC1, C7orf55-LUC7L2, SEC23IP
