# BARCS versus published results

BARCS genes: `results/tfe3_on_vs_off/genes.csv` (18559 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| CCNC | 1521 | 18559 | 2.947 | 0.21 | 1 |
| CDK8 | not tested | | | | |
| MED12 | 8 | 18559 | 1.189 | 0.0018 | 1 |
| MED13 | 6774 | 18559 | 0.793 | 0.5 | 1 |
| CDKN1A | 2 | 18559 | 1.394 | 7.8e-05 | 0.73 |
| TP53 | 4179 | 18559 | 0.494 | 0.37 | 1 |

## Agreement with the published table

Published: `paper/mageck.tsv` (score `p_min`, lower is stronger); 19062 genes, 18559 shared with BARCS.

Spearman correlation of gene scores: **0.35**


Effect direction agreement: 78.4% of 18559 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 0 | 0.00 | 25 | 25 |
| 50 | 3 | 0.03 | 47 | 47 |
| 100 | 6 | 0.03 | 94 | 94 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): GBF1 (1 / 995), CDKN1A (2 / 312), SUPT20H (3 / 845), PTER (4 / 557), CDKN2A (5 / 6137), ZCCHC14 (6 / 224), ELOF1 (7 / 4281), MED12 (8 / 473), R3HDM4 (9 / 2798), CPLX1 (10 / 1561), RASSF2 (11 / 3141), JCHAIN (12 / 3986), MID1IP1 (13 / 954), YPEL5 (14 / 56), CXCL2 (15 / 241), NUTF2 (16 / 77), RPL10L (17 / 2474), PPARG (18 / 191), PPP2R2A (19 / 2131), C5orf22 (20 / 439), ZFP82 (21 / 1197), ZNF645 (22 / 553), PTPDC1 (23 / 106), NPFFR2 (24 / 10016), PAPD7 (25 / 2139)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): MYL1 (2 / 9260), TMEM185B (3 / 18241), DDX42 (7 / 9676), ANP32E (9 / 170), SYVN1 (10 / 2005), ZNF827 (11 / 655), FBRSL1 (13 / 7334), UBE3B (14 / 15049), WBSCR16 (18 / 8193), RBM4 (19 / 2355), CCNC (20 / 1521), SH3TC1 (23 / 13277), C17orf67 (24 / 7626), ZNF236 (25 / 5928), MMP10 (26 / 13626), PPP1R8 (27 / 4297), ARGFX (30 / 29), SPDYC (32 / 8345), GPR137 (34 / 12188), FKBP3 (35 / 18020), CASP8 (40 / 11670), FBXO9 (41 / 2023), CDC20B (44 / 17438), SCNM1 (45 / 1769), ELK1 (46 / 2720)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: GBF1, CDKN1A, SUPT20H, PTER, CDKN2A, ZCCHC14, ELOF1, MED12, R3HDM4, CPLX1, RASSF2, JCHAIN, MID1IP1, YPEL5, CXCL2
