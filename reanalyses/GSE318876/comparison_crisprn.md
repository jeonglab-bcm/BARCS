# BARCS versus published results

BARCS genes: `results/crisprn_GFPneg_vs_GFPpos/genes.csv` (19114 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CXCR4 | 1 | 19114 | 0.957 | 8.8e-50 | 1.7e-45 |
| CD4 | 2 | 19114 | 0.760 | 3.7e-31 | 2.4e-27 |

## Agreement with the published table

Published: `suppl/GSE318876_All_screens_MAGeCK_gene_summaries.xlsx` (score `neg|score`, lower is stronger); 19364 genes, 19114 shared with BARCS.

Spearman correlation of gene scores: **0.74**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 43 | 0.75 | 7 | 7 |
| 100 | 83 | 0.71 | 17 | 17 |
| 200 | 153 | 0.62 | 47 | 47 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): CD2 (43 / 53), ZC3H7A (44 / 51), ARHGEF1 (45 / 83), ACTB (46 / 70), RQCD1 (48 / 52), RIC8A (49 / 89), SASH3 (50 / 55)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): PSIP1 (19 / 56), FNTA (27 / 66), LCP2 (31 / 51), FBXW7 (35 / 67), ICMT (46 / 57), KMT2A (49 / 73), TLK2 (50 / 75)

## BARCS calls

Genes at FDR 0.05: 264; at FDR 0.10: 342. Top 15: CXCR4, CD4, PDCL, ITGAL, GNA13, TLN1, BCL11B, PTK2B, NFKB1, ITGB2, RAC2, RAPGEF1, LCK, CRKL, SLC35B2
