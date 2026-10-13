# BARCS versus published results

BARCS genes: `results/late_vs_early/genes.csv` (18360 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Nanog | 178 | 18360 | -1.776 | 0.047 | 1 |
| Il6st | 185 | 18360 | -0.811 | 0.051 | 1 |
| Dazl | 1020 | 18360 | -0.095 | 0.4 | 1 |
| Hes6 | 290 | 18360 | -0.704 | 0.096 | 1 |
| Hes7 | 1193 | 18360 | -0.421 | 0.45 | 1 |
| Stat1 | 2464 | 18360 | -0.257 | 0.74 | 1 |
| Jak1 | 1180 | 18360 | -0.324 | 0.45 | 1 |
| Spi1 | 596 | 18360 | -0.203 | 0.23 | 1 |
| Irf2 | 5712 | 18360 | 0.196 | 0.87 | 1 |
| Ifngr2 | 2356 | 18360 | -0.064 | 0.72 | 1 |

## Agreement with the published table

Published: `paper/tableS1.xlsx` (score `neg|score`, lower is stronger); 18376 genes, 18360 shared with BARCS.

Spearman correlation of gene scores: **0.69**


Effect direction agreement: 72.4% of 18360 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 2 | 0.02 | 48 | 48 |
| 100 | 11 | 0.06 | 89 | 89 |
| 250 | 34 | 0.07 | 216 | 216 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): Trp53 (1 / 126), Gm7714 (2 / 692), Pex7 (3 / 1604), Gm684 (4 / 853), Oxnad1 (5 / 97), Mt3 (6 / 5594), Lrrc6 (7 / 563), Phc1 (8 / 646), Acsl4 (9 / 691), Slit1 (10 / 743), AI848285 (11 / 303), Clpb (12 / 1699), Crebbp (13 / 98), Trim32 (14 / 80), Casz1 (15 / 2013), P2ry10 (17 / 1388), Ipo9 (18 / 86), Phf2 (19 / 1649), Foxc2 (20 / 3747), Pde6c (21 / 1892), Thoc6 (22 / 687), Myog (23 / 95), Rnf150 (24 / 295), Hbb-bh2 (25 / 585), Ugt1a7c (26 / 988)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): Adnp (1 / 404), Adat2 (2 / 3538), Vmn2r117 (3 / 2065), Alg11 (4 / 2673), Prss53 (5 / 153), Prpf19 (6 / 474), Efcab3 (7 / 111), Sec22a (8 / 913), Nanog (9 / 178), Ddx6 (10 / 1558), Fabp1 (11 / 2135), Trem2 (12 / 10689), Mob2 (13 / 449), Mier1 (14 / 1186), Got2 (15 / 3171), Mtfr1 (16 / 3721), Ypel5 (17 / 2329), Tbc1d2 (18 / 1503), Ifitm6 (19 / 3279), Mtap7d3 (20 / 12343), Suv39h2 (21 / 469), Cd302 (22 / 821), Ceacam1 (23 / 9259), Tpi1 (24 / 698), Hhat (26 / 12999)

## BARCS calls

Genes at FDR 0.05: 17; at FDR 0.10: 22. Top 15: Trp53, Gm7714, Pex7, Gm684, Oxnad1, Mt3, Lrrc6, Phc1, Acsl4, Slit1, AI848285, Clpb, Crebbp, Trim32, Casz1
