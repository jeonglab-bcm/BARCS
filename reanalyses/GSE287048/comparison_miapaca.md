# BARCS versus published results

BARCS genes: `results/miapaca_inx315_vs_control/genes.csv` (18047 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CDK2 | 3 | 18047 | 3.133 | 8.3e-09 | 5e-05 |

## Agreement with the published table

Published: `paper/SupplementaryData2.xlsx` (score `normZ`, higher is stronger); 18049 genes, 18021 shared with BARCS.

Spearman correlation of gene scores: **0.93**


Effect direction agreement: 84.5% of 18021 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 11 | 0.38 | 9 | 9 |
| 50 | 32 | 0.47 | 18 | 18 |
| 100 | 60 | 0.43 | 40 | 40 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): KRTAP19-4 (7 / 24), FBXW7 (9 / 31), PDS5B (10 / 26), CKS2 (11 / 34), WDR1 (12 / 21), CPB2 (14 / 48), SLMAP (16 / 27), CSDE1 (17 / 82), TRIM5 (18 / 30)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): UBN1 (8 / 33), PNN (10 / 26), THOC6 (11 / 138), C19orf43 (12 / 36), CD200R1L (14 / 23), WARS2 (15 / 212), CENPO (18 / 21), SCAF4 (19 / 35), PPP2CA (20 / 38)

## BARCS calls

Genes at FDR 0.05: 6; at FDR 0.10: 6. Top 15: LCMT1, CELF1, CDK2, AMBRA1, PPP2R2A, KIDINS220, KRTAP19-4, TTC23, FBXW7, PDS5B, CKS2, WDR1, DYRK1A, CPB2, CEP85
