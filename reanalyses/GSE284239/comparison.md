# BARCS versus published results

BARCS genes: `results/uwb_tng348_vs_dmso/genes.csv` (1180 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| RAD18 | 2 | 1180 | 1.478 | 2.2e-06 | 0.0013 |
| UBE2K | 96 | 1180 | 0.454 | 0.38 | 1 |
| UBE2A | 26 | 1180 | 0.881 | 0.09 | 1 |
| RFWD3 | 52 | 1180 | 2.071 | 0.23 | 1 |
| USP1 | 7 | 1180 | 2.615 | 0.0036 | 0.43 |
| PARP1 | 1116 | 1180 | -1.261 | 0.24 | 1 |

## Agreement with the published table

Published: `paper/tableS5.csv` (score `signed_score`, higher is stronger); 1181 genes, 1180 shared with BARCS.

Spearman correlation of gene scores: **0.64**


Effect direction agreement: 72.8% of 1180 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 12 | 0.43 | 8 | 8 |
| 50 | 23 | 0.30 | 27 | 27 |
| 100 | 55 | 0.38 | 45 | 45 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): OTUB1 (9 / 45), SMARCD1 (12 / 270), CTC-534A2.2 (13 / 39), USP14 (16 / 101), SMARCAD1 (17 / 29), HAUS3 (18 / 98), LATS2 (19 / 52), WDR20 (20 / 27)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): UBE2K (8 / 96), CRY2 (11 / 1139), RNF168 (12 / 92), MEMO1 (13 / 140), UBE2A (14 / 26), HINFP (15 / 116), ZBTB17 (17 / 322), ARID2 (20 / 47)

## BARCS calls

Genes at FDR 0.05: 2; at FDR 0.10: 3. Top 15: RB1, RAD18, E2F7, TP53BP1, CDKN2A, WDR48, USP1, CCDC130, OTUB1, TYMS, CWC27, SMARCD1, CTC-534A2.2, FAM35A, RALGAPB
