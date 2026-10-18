# BARCS versus published results

BARCS genes: `results/tumor_vs_bone_marrow/genes.csv` (355 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Cd300ld | 1 | 355 | -0.570 | 1.7e-05 | 0.006 |

## Agreement with the published table

Published: `paper/cd300ld_screen.tsv` (score `pos_score`, lower is stronger); 355 genes, 355 shared with BARCS.

Spearman correlation of gene scores: **0.69**


Effect direction agreement: 85.9% of 355 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 3 | 0.18 | 7 | 7 |
| 25 | 10 | 0.25 | 15 | 15 |
| 50 | 25 | 0.33 | 25 | 25 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Itgam (3 / 13), Slc43a2 (4 / 53), M6pr (5 / 15), Gpnmb (6 / 17), Nptn (7 / 37), Stab1 (8 / 22), Slc3a2 (9 / 100)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Ext1 (2 / 246), Trem2 (3 / 13), Stom (6 / 22), Hfe (7 / 163), Tmbim1 (8 / 91), Scamp2 (9 / 172), Acvrl1 (10 / 190)

## BARCS calls

Genes at FDR 0.05: 1; at FDR 0.10: 1. Top 15: Cd300ld, Kit, Itgam, Slc43a2, M6pr, Gpnmb, Nptn, Stab1, Slc3a2, Nceh1, C3ar1, Stard3, Trem2, Cnih4, Ldlr
