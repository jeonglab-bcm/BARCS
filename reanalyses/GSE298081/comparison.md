# BARCS versus published results

BARCS genes: `results/ptar1_vs_wt_gi/genes.csv` (18049 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| VAMP3 | 2 | 18049 | -0.619 | 4.6e-11 | 6.9e-08 |
| RAB1A | 306 | 18049 | -0.256 | 0.0059 | 0.13 |
| SEC23IP | 37 | 18049 | -0.449 | 9.5e-06 | 0.0016 |
| GOSR1 | 183 | 18049 | -0.296 | 0.0017 | 0.062 |
| TRAPPC12 | 374 | 18049 | -0.360 | 0.0085 | 0.16 |
| YKT6 | 11576 | 18049 | 0.052 | 0.68 | 0.92 |

## Agreement with the published table

Published: `paper/PTAR1_qGI.csv` (score `qGI_medium_mean`, lower is stronger); 17724 genes, 17722 shared with BARCS.

Spearman correlation of gene scores: **0.53**


Effect direction agreement: 67.7% of 17722 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 22 | 0.28 | 28 | 28 |
| 100 | 44 | 0.28 | 56 | 56 |
| 200 | 77 | 0.24 | 123 | 123 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): SLC25A1 (9 / 79), SS18 (10 / 192), C10orf76 (11 / 93), SGTA (17 / 59), SFT2D2 (18 / 88), SLC25A37 (19 / 157), RCOR2 (24 / 215), UBALD1 (25 / 348), MEAF6 (26 / 684), NSD1 (28 / 195), RPP25L (29 / 11942), GOLPH3 (30 / 182), CREBZF (31 / 222), SUV39H1 (32 / 4189), TXNDC17 (34 / 4454), FCHO2 (35 / 100), JKAMP (36 / 116), SPOP (39 / 6436), NFE2L1 (41 / 489), TMEM203 (43 / 53), GCC1 (46 / 56), TMEM60 (48 / 107), P2RY4 (49 / 817), RNH1 (50 / 129), MECR (51 / 13745)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): TSSC1 (5 / 73), MTMR9 (13 / 57), ARL1 (15 / 90), TRAPPC12 (16 / 374), RABIF (18 / 244), RAB1A (20 / 306), ZDHHC5 (22 / 83), RAB18 (24 / 1140), SECISBP2L (25 / 154), TAPT1 (26 / 1335), NGLY1 (27 / 129), VPS54 (29 / 79), ACO2 (30 / 4859), ACBD3 (31 / 95), ARFGAP2 (33 / 91), TECR (34 / 5008), PSME3 (35 / 1157), HEATR5B (36 / 85), LAMTOR5 (38 / 986), SPTLC2 (40 / 252), AP1G1 (41 / 100), PIH1D1 (42 / 381), MEF2BNB (43 / 148), GOSR1 (44 / 183), SLC35A1 (45 / 68)

## BARCS calls

Genes at FDR 0.05: 473; at FDR 0.10: 700. Top 15: GOLGA7, VAMP3, RCE1, PICALM, RAB14, WDFY1, VAMP2, INO80D, SLC25A1, SS18, C10orf76, KMT2A, CNIH1, HDAC3, RABL3
