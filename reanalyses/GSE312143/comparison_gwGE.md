# BARCS versus published results

BARCS genes: `results/GW_GE_lineage_vs_HSPC/genes.csv` (1886 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Tada2b | 355 | 1886 | -0.332 | 0.87 | 1 |
| Taf5l | 353 | 1886 | 2.729 | 0.87 | 1 |
| Taf6l | 23 | 1886 | -1.555 | 0.47 | 1 |

## Agreement with the published table

Published: `paper/castle_gw.tsv` (score `score`, higher is stronger); 21821 genes, 1886 shared with BARCS.

Spearman correlation of gene scores: **-0.09**


Effect direction agreement: 34.4% of 1886 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 1 | 0.02 | 24 | 24 |
| 50 | 2 | 0.02 | 48 | 48 |
| 100 | 9 | 0.05 | 91 | 91 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Supt7l (1 / 1442), Pak1ip1 (2 / 7986), Drosha (3 / 3222), Hoxc9 (4 / 15574), Map6 (5 / 12678), Lrrc63 (6 / 12258), Nobox (7 / 8577), Helb (8 / 13428), Irx1 (9 / 1648), Fam83b (10 / 6863), Maml3 (11 / 2188), Btbd11 (12 / 13008), Otp (13 / 13661), Bcorl1 (14 / 9153), Taf3 (15 / 2485), Zfp689 (16 / 1232), Med19 (17 / 11052), Med13 (18 / 1408), Cenpt (19 / 11526), Hdac11 (20 / 6862), Srsf9 (21 / 4729), Gsx1 (22 / 7988), Bzw2 (24 / 6383), Epc1 (25 / 5291)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Rbm12 (2 / 1503), Zfp566 (3 / 1553), Rbm14 (5 / 1647), Ssxb2 (6 / 1774), Foxq1 (7 / 1865), Gm21975 (8 / 1675), Brf1 (17 / 1880), Rbm4 (20 / 1527), Tada2b (25 / 355), Arid3b (33 / 341), Psma5 (45 / 1800), Zfp595 (51 / 1504), Gm14305 (67 / 1067), Lztr1 (69 / 224), Rpl21 (77 / 1813), Sh2d1b1 (85 / 667), Taf5l (122 / 353), Eif2s2 (138 / 1883), Sarnp (150 / 1628), Deptor (164 / 656), Scand1 (180 / 1638), Hoxc4 (200 / 368), Gm13212 (204 / 1515), Gtf3c6 (220 / 1854)

## BARCS calls

Genes at FDR 0.05: 1; at FDR 0.10: 1. Top 15: Supt7l, Pak1ip1, Drosha, Hoxc9, Map6, Lrrc63, Nobox, Helb, Irx1, Fam83b, Maml3, Btbd11, Otp, Bcorl1, Taf3
