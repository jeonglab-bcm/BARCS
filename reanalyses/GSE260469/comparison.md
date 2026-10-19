# BARCS versus published results

BARCS genes: `results/csf1r_vs_IgG/genes.csv` (1212 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Tnfrsf11b | 10 | 1212 | 3.241 | 0.095 | 1 |

## Agreement with the published table

Published: `paper/mmc5.xlsx` (score `pos|score`, lower is stronger); 1219 genes, 1212 shared with BARCS.

Spearman correlation of gene scores: **0.73**


Effect direction agreement: 96.0% of 1212 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 7 | 0.21 | 13 | 13 |
| 50 | 24 | 0.32 | 26 | 26 |
| 100 | 52 | 0.35 | 48 | 48 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): Gabrg2 (1 / 416), Axl (2 / 48), Pla2g4b (4 / 22), Plg (5 / 91), Htr4 (6 / 47), Chrna2 (11 / 139), Dpp4 (12 / 103), Mmp7 (14 / 26), Drd3 (16 / 31), Lpl (17 / 258), Uchl3 (18 / 130), Cpb2 (19 / 76), Chrna7 (20 / 157)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): Dck (2 / 324), Fgf4 (5 / 1103), Cd47 (6 / 44), Abcc2 (7 / 38), Adora2b (9 / 59), Cpt1a (10 / 280), Calcr (11 / 29), Hsd3b3 (12 / 325), Galk1 (13 / 32), Wnk3 (16 / 119), Cdc25c (17 / 129), Flt1 (20 / 142), Dclk2 (21 / 67)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: Gabrg2, Axl, Tubb1, Pla2g4b, Plg, Htr4, Pld2, Pck1, Tnfrsf1a, Tnfrsf11b, Chrna2, Dpp4, Prkacb, Mmp7, Glra4
