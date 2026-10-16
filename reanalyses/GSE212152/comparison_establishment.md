# BARCS versus published results

BARCS genes: `results/establishment_GFP_vs_unsorted/genes.csv` (1160 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Setdb1 | 7 | 1160 | 2.003 | 6.2e-07 | 0.0001 |
| Suv39h1 | 48 | 1160 | 1.276 | 0.014 | 0.13 |
| Ehmt2 | 13 | 1160 | 1.556 | 1.8e-05 | 0.0016 |
| Dnmt1 | 2 | 1160 | 1.986 | 1.1e-08 | 6.5e-06 |
| Dnmt3a | 39 | 1160 | 1.411 | 0.004 | 0.07 |
| Dnmt3b | 35 | 1160 | 1.301 | 0.0024 | 0.058 |
| Hdac1 | 1160 | 1160 | -0.849 | 5.5e-05 | 0.004 |
| Hdac2 | 168 | 1160 | 0.121 | 0.53 | 0.72 |
| Dhx9 | 1128 | 1160 | -1.315 | 0.0049 | 0.078 |

## Agreement with the published table

Published: `suppl/GSE212152_EpiChromo_Screen_establishment_Gene_Summary.txt.gz` (score `pos|score`, lower is stronger); 1160 genes, 1160 shared with BARCS.

Spearman correlation of gene scores: **0.88**


Effect direction agreement: 72.7% of 1160 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 46 | 0.85 | 4 | 4 |
| 100 | 87 | 0.77 | 13 | 13 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Sin3b (16 / 35), Gatad1 (21 / 32), L3mbtl2 (22 / 31), Phf12 (24 / 30), Arid1a (25 / 26)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Uhrf2 (12 / 27), Dnmt3b (15 / 35), Dnmt3a (17 / 39), Rcor2 (23 / 30), Setd2 (24 / 33)

## BARCS calls

Genes at FDR 0.05: 43; at FDR 0.10: 94. Top 15: Atf7ip, Dnmt1, Cbx1, Kdm1a, Atrx, Rbm14, Setdb1, Cbx5, Daxx, Smarcad1, Morc3, Dnmt3l, Ehmt2, Ctbp2, Trim28
