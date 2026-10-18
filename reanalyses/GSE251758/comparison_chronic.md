# BARCS versus published results

BARCS genes: `results/chronic_vs_resting/genes.csv` (19667 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Eif4g2 | 5 | 19667 | 1.043 | 1.5e-09 | 3e-06 |
| Ctbp1 | 48 | 19667 | 1.449 | 0.0031 | 0.47 |
| Trp53 | 1 | 19667 | 0.571 | 1.6e-15 | 1.6e-11 |

## Agreement with the published table

Published: `sample_suppl/GSM7987450_Alphamean_Chronic_Rest_vs_Act.gene_summary.rev.txt.gz` (score `pos|score`, lower is stronger); 19674 genes, 19667 shared with BARCS.

Spearman correlation of gene scores: **0.79**


Effect direction agreement: 65.6% of 19667 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 18 | 0.22 | 32 | 32 |
| 100 | 51 | 0.34 | 49 | 49 |
| 200 | 104 | 0.35 | 96 | 96 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): Akr1c12 (9 / 312), Sema4d (12 / 100), Mios (14 / 83), Lpar3 (16 / 142), Nefm (17 / 366), Lrrc47 (18 / 98), Otx1 (19 / 54), Dynll1 (20 / 82), Pdlim1 (21 / 88), Fbxo38 (23 / 70), Ces2h (24 / 185), Lamtor3 (25 / 108), Rnf7 (27 / 128), Icam1 (28 / 123), Cers5 (29 / 5954), Becn1 (30 / 66), Gipc3 (31 / 164), Rragc (32 / 96), Akr1a1 (33 / 160), Ube2d1 (34 / 143), Dok4 (35 / 126), Samd9l (36 / 87), Iffo1 (38 / 357), Olfr155 (39 / 213), Ccbe1 (40 / 91)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): Tmem229b (9 / 19656), Kcnd3 (11 / 194), Ankrd45 (12 / 170), Erich1 (13 / 59), Rnf121 (16 / 62), Srsf9 (17 / 70), Cd69 (18 / 19564), Gnb3 (20 / 173), Dner (23 / 167), Olfr1133 (24 / 165), Arl13a (25 / 95), C1qtnf6 (26 / 110), Pgam2 (27 / 184), Zeb2 (28 / 196), Sphk2 (29 / 317), Mpzl3 (32 / 135), Dock7 (33 / 56), Rgs9 (34 / 109), Runx1 (35 / 378), Idnk (36 / 142), Sh2d3c (37 / 69), Chga (38 / 90), Lrrc63 (39 / 17079), Heca (40 / 113), Rrp1b (41 / 134)

## BARCS calls

Genes at FDR 0.05: 34; at FDR 0.10: 45. Top 15: Trp53, Lamtor4, Ccnc, Zc3h12a, Eif4g2, Ets1, Flcn, Rraga, Akr1c12, Cul5, Itgb2, Sema4d, Rbm6, Mios, Traf6
