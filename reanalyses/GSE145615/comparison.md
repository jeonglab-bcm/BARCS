# BARCS versus published results

BARCS genes: `results/blast_vs_unselected/genes.csv` (18797 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Mettl3 | 11 | 18797 | 3.331 | 0.00014 | 0.00027 |
| Mettl14 | 21 | 18797 | 1.136 | 0.018 | 0.021 |
| Wtap | 323 | 18797 | -0.362 | 0.84 | 0.84 |
| Zc3h13 | 848 | 18797 | -0.634 | 0.24 | 0.24 |

## Agreement with the published table

Published: `paper/screenII_late_mageck.tsv` (score `pos|score`, lower is stronger); 18815 genes, 18754 shared with BARCS.

Spearman correlation of gene scores: **0.39**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 5 | 0.14 | 15 | 15 |
| 50 | 8 | 0.09 | 42 | 42 |
| 100 | 15 | 0.08 | 85 | 85 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): Trp53 (4 / 95), Casp3 (5 / 204), Urod (6 / 1217), Daxx (8 / 1124), Uros (9 / 3559), Hmbs (10 / 657), Tsc2 (12 / 23), Fech (13 / 5515), Ppox (14 / 7322), Rpl29 (15 / 137), Tada1 (16 / 1868), Rpl10 (17 / 562), Stat3 (18 / 1969), Psmd2 (19 / 937), Mrps27 (20 / 21)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): AI846148 (4 / 153), 2810474O19Rik (5 / 61), Grb2 (7 / 1855), Pias2 (8 / 538), Gm14431 (9 / 340), Morc3 (10 / 350), Tra2b (11 / 67), Fbxw7 (13 / 495), Znrf1 (14 / 62), Magi2 (15 / 8563), Elavl1 (16 / 59), Hspa12a (17 / 754), Glrx2 (18 / 315), Ly6g5c (19 / 109), Nck1 (20 / 1727)

## BARCS calls

Genes at FDR 0.05: 16834; at FDR 0.10: 17426. Top 15: Hccs, Apaf1, Casp9, Trp53, Casp3, Urod, Spin1, Daxx, Uros, Hmbs, Mettl3, Tsc2, Fech, Ppox, Rpl29
