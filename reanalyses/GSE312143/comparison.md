# BARCS versus published results

BARCS genes: `results/GE_two_screens_lineage_vs_HSPC/genes.csv` (1713 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Tada2b | 55 | 1713 | -3.160 | 0.006 | 0.19 |
| Taf5l | 962 | 1713 | -0.846 | 0.28 | 0.5 |
| Taf6l | 1368 | 1713 | -1.766 | 0.63 | 0.79 |

## Agreement with the published table

Published: `paper/castle_gescreen.tsv` (score `score`, higher is stronger); 1898 genes, 1712 shared with BARCS.

Spearman correlation of gene scores: **0.03**


Effect direction agreement: 30.6% of 1712 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 3 | 0.06 | 22 | 22 |
| 50 | 6 | 0.06 | 44 | 44 |
| 100 | 15 | 0.08 | 85 | 85 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Hdac11 (1 / 426), Irx3 (4 / 345), Zfp11 (5 / 433), Piwil1 (6 / 1232), Hoxc5 (7 / 32), Creb5 (8 / 89), Aebp2 (9 / 96), Rbm20 (10 / 379), Arhgap22 (11 / 252), Dusp28 (12 / 415), Camta2 (13 / 1093), Foxc2 (14 / 287), Lhx8 (15 / 81), Tle6 (16 / 459), Rbak (17 / 272), Fgd2 (18 / 1479), Zbtb32 (20 / 1306), Tceal5 (21 / 696), Mxi1 (22 / 537), Mbd5 (23 / 1179), Hoxd8 (24 / 450), Rbm42 (25 / 137)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Tada2b (1 / 55), Taf5l (2 / 962), Taf6l (3 / 1368), Supt7l (5 / 1108), Elf2 (6 / 1049), Dhx34 (7 / 818), Osr2 (8 / 1340), Wdr83 (10 / 1481), Rrs1 (12 / 1541), B3galt1 (13 / 1448), Mprip (14 / 1194), Hist1h3c (15 / 43), Arid1b (17 / 1382), Pak1ip1 (19 / 277), Dvl3 (20 / 1450), Plek (21 / 539), Gatad2b (22 / 1600), Orc4 (23 / 1696), Zfp131 (24 / 1057), Vsx1 (25 / 1646), Exosc8 (26 / 1500), Zscan21 (28 / 1426)

## BARCS calls

Genes at FDR 0.05: 4; at FDR 0.10: 5. Top 15: Hdac11, Asap3, Etohi1, Irx3, Zfp11, Piwil1, Hoxc5, Creb5, Aebp2, Rbm20, Arhgap22, Dusp28, Camta2, Foxc2, Lhx8
