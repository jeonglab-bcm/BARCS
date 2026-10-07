# BARCS versus published results

BARCS genes: `results/tfe3_on_vs_off/genes.csv` (19044 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CCNC | 137 | 19044 | 5.703 | 3.3e-05 | 0.0046 |
| CDK8 | not tested | | | | |
| MED12 | 420 | 19044 | 1.382 | 0.00064 | 0.029 |
| MED13 | 10166 | 19044 | 0.793 | 0.43 | 0.81 |
| CDKN1A | 340 | 19044 | 1.394 | 0.00035 | 0.019 |
| TP53 | 1785 | 19044 | 0.668 | 0.017 | 0.19 |

## Agreement with the published table

Published: `paper/mageck.tsv` (score `p_min`, lower is stronger); 19062 genes, 19044 shared with BARCS.

Spearman correlation of gene scores: **0.51**


Effect direction agreement: 87.0% of 19044 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 6 | 0.14 | 19 | 19 |
| 50 | 19 | 0.23 | 31 | 31 |
| 100 | 37 | 0.23 | 63 | 63 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): GOLGA6L1 (3 / 171), CKAP2 (4 / 935), NOP10 (5 / 912), TIMELESS (6 / 55), PHB (7 / 280), TP53TG3D (10 / 429), RNF149 (11 / 37), NEDD1 (12 / 36), DNAJC2 (13 / 42), SNF8 (14 / 1955), C19orf53 (15 / 39), SCG5 (16 / 562), KIF4A (17 / 49), NOP2 (18 / 64), SMU1 (19 / 31), SEC13 (21 / 468), EIF3A (22 / 493), KAT5 (23 / 28), BRD4 (24 / 363)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): MYL1 (2 / 549), TMEM185B (3 / 1054), PCDHB4 (6 / 1522), DDX42 (7 / 1497), ANP32E (9 / 79), SYVN1 (10 / 44), ZNF827 (11 / 2300), FAM103A1 (12 / 28), FBRSL1 (13 / 1535), UBE3B (14 / 1029), SPDYE2B (15 / 41), WBSCR16 (18 / 346), RBM4 (19 / 2600), CCNC (20 / 137), NUP107 (21 / 131), ATP6V0D1 (22 / 30), SH3TC1 (23 / 3028), C17orf67 (24 / 78), ZNF236 (25 / 580)

## BARCS calls

Genes at FDR 0.05: 612; at FDR 0.10: 1151. Top 15: EIF6, MYC, GOLGA6L1, CKAP2, NOP10, TIMELESS, PHB, BCL2L1, COPE, TP53TG3D, RNF149, NEDD1, DNAJC2, SNF8, C19orf53
