# BARCS versus published results

BARCS genes: `results/intense_vs_pre/genes.csv` (19674 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Trp53 | 1 | 19674 | 0.680 | 4.9e-141 | 9.6e-137 |
| Eif4g2 | 8 | 19674 | 0.349 | 1.4e-14 | 1e-11 |
| Icam1 | 67 | 19674 | 0.235 | 0.00038 | 0.011 |

## Agreement with the published table

Published: `sample_suppl/GSM7987449_Alphamean_AICD_pre_vs_Act.gene_summary.rev.txt.gz` (score `pos|score`, lower is stronger); 19674 genes, 19674 shared with BARCS.

Spearman correlation of gene scores: **0.76**


Effect direction agreement: 43.3% of 19674 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 40 | 0.67 | 10 | 10 |
| 100 | 73 | 0.57 | 27 | 27 |
| 200 | 130 | 0.48 | 70 | 70 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): Zmat3 (23 / 54), Golph3 (30 / 51), Itgb2 (33 / 75), Sgpp1 (39 / 55), Olfr385 (40 / 154), Sharpin (42 / 155), Ptms (45 / 220), Plk3 (46 / 120), Ahdc1 (48 / 56), Abi3bp (50 / 72)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): Lemd3 (27 / 53), Naa10 (32 / 71), Cd68 (40 / 80), Iqcf3 (41 / 62), Chrnb1 (42 / 77), A830018L16Rik (43 / 135), Slc33a1 (44 / 55), Icam1 (46 / 67), Mbnl1 (47 / 125), F8a (49 / 52)

## BARCS calls

Genes at FDR 0.05: 965; at FDR 0.10: 1187. Top 15: Trp53, B3galt4, B4galnt1, Serf2, Myb, Tnfrsf4, Tnfrsf1b, Eif4g2, C330007P06Rik, Gpatch8, Cdkn2a, Larp1, Fas, Dnttip1, Fermt3
