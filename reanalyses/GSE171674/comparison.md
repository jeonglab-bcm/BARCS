# BARCS versus published results

BARCS genes: `results/CD25_high_vs_low/genes.csv` (1350 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| IL2RA | 6 | 1350 | -1.704 | 7.4e-26 | 1.7e-23 |
| JAK3 | 26 | 1350 | -0.848 | 3.5e-10 | 1.8e-08 |
| STAT5A | 19 | 1350 | -0.727 | 1.1e-12 | 7.6e-11 |
| STAT5B | 5 | 1350 | -1.690 | 4.7e-27 | 1.3e-24 |
| MED12 | 1 | 1350 | 2.222 | 7.6e-37 | 1e-33 |
| CBFB | 2 | 1350 | 2.006 | 1.3e-30 | 9e-28 |
| TNFAIP3 | 12 | 1350 | 0.732 | 3.3e-18 | 3.7e-16 |
| KLF2 | 7 | 1350 | 1.527 | 1.1e-24 | 2.1e-22 |
| ZNF217 | 11 | 1350 | 0.949 | 6.3e-19 | 7.7e-17 |
| FOXK1 | 9 | 1350 | 0.939 | 1.2e-20 | 1.9e-18 |
| HIVEP2 | 3 | 1350 | 1.469 | 3.9e-29 | 1.8e-26 |
| IRF4 | 64 | 1350 | -0.382 | 0.00012 | 0.0025 |
| ATXN7L3 | 68 | 1350 | 0.227 | 0.00018 | 0.0036 |

## Agreement with the published table

Published: `paper/il2ra_screen.tsv` (score `min_p`, lower is stronger); 1350 genes, 1350 shared with BARCS.

Spearman correlation of gene scores: **0.61**


Effect direction agreement: 82.2% of 1350 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 23 | 0.85 | 2 | 2 |
| 50 | 43 | 0.75 | 7 | 7 |
| 100 | 75 | 0.60 | 25 | 25 |
| 200 | 142 | 0.55 | 58 | 58 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): PRDM1 (21 / 28), ZNF148 (25 / 26)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): FOXO1 (21 / 29), RBPJ (23 / 27)

## BARCS calls

Genes at FDR 0.05: 103; at FDR 0.10: 126. Top 15: MED12, CBFB, HIVEP2, FOXP1, STAT5B, IL2RA, KLF2, MYB, FOXK1, PTEN, ZNF217, TNFAIP3, GATA3, IRF2, SMARCB1
