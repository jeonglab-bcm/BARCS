# BARCS versus published results

BARCS genes: `results/acute_vs_pre/genes.csv` (19674 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Trp53 | 1 | 19674 | 1.218 | 2e-224 | 3.9e-220 |
| Eif4g2 | 5 | 19674 | 0.732 | 2.3e-36 | 8.9e-33 |
| Icam1 | 27 | 19674 | 0.506 | 4.6e-13 | 1.8e-10 |

## Agreement with the published table

Published: `paper/acute_gene_summary.tsv` (score `pos|score`, lower is stronger); 19674 genes, 19674 shared with BARCS.

Spearman correlation of gene scores: **0.76**


Effect direction agreement: 42.2% of 19674 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 45 | 0.82 | 5 | 5 |
| 100 | 82 | 0.69 | 18 | 18 |
| 200 | 147 | 0.58 | 53 | 53 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): Nmt1 (36 / 54), Nsd1 (37 / 103), Zbtb7a (43 / 51), Lamtor4 (49 / 55), B4galt5 (50 / 61)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): Tfap4 (37 / 61), Rasa2 (44 / 67), Zbtb2 (46 / 66), Tln1 (47 / 60), Snrpb2 (50 / 69)

## BARCS calls

Genes at FDR 0.05: 1314; at FDR 0.10: 1643. Top 15: Trp53, B3galt4, Myb, B4galnt1, Eif4g2, Dnttip1, Serf2, Cdkn2a, Fermt3, Hdac1, Bhlhe40, Sharpin, Smad7, Gpatch8, Morf4l1
