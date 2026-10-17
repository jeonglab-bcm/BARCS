# BARCS versus published results

BARCS genes: `results/maintenance_GFP_vs_unsorted/genes.csv` (1160 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Setdb1 | 35 | 1160 | 1.030 | 0.0011 | 0.016 |
| Suv39h1 | 200 | 1160 | 0.101 | 0.43 | 0.65 |
| Ehmt2 | 61 | 1160 | 0.281 | 0.02 | 0.12 |
| Dnmt1 | 5 | 1160 | 1.508 | 4e-14 | 9.3e-12 |
| Dnmt3a | 4 | 1160 | 1.191 | 1.3e-14 | 3.6e-12 |
| Dnmt3b | 15 | 1160 | 0.404 | 4.1e-06 | 0.00018 |
| Hdac1 | 1072 | 1160 | -0.428 | 0.0085 | 0.072 |
| Hdac2 | 981 | 1160 | -0.211 | 0.033 | 0.16 |
| Dhx9 | 143 | 1160 | 0.332 | 0.2 | 0.4 |

## Agreement with the published table

Published: `suppl/GSE212152_EpiChromo_Screen_maintenance_Gene_Summary.txt.gz` (score `pos|score`, lower is stronger); 1160 genes, 1160 shared with BARCS.

Spearman correlation of gene scores: **0.85**


Effect direction agreement: 80.4% of 1160 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 21 | 0.72 | 4 | 4 |
| 50 | 44 | 0.79 | 6 | 6 |
| 100 | 77 | 0.63 | 23 | 23 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Sfpq (20 / 32), Suz12 (21 / 27), Spop (23 / 26), Daxx (24 / 30)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Arid4a (18 / 29), Tial1 (22 / 26), Nono (23 / 28), Rybp (25 / 34)

## BARCS calls

Genes at FDR 0.05: 115; at FDR 0.10: 179. Top 15: Dnmt3l, Ctbp2, Uhrf1, Dnmt3a, Dnmt1, Ezh2, Dot1l, Pcgf2, Mrgbp, Atf7ip, Kdm1a, Eed, Sfmbt2, Zmym2, Dnmt3b
