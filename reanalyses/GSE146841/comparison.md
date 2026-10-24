# BARCS versus published results

BARCS genes: `results/Tm_GFPhigh_vs_low/genes.csv` (19106 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| QRICH1 | 126 | 19106 | -0.891 | 0.0015 | 0.17 |
| XBP1 | 17 | 19106 | -2.080 | 9.4e-06 | 0.0095 |
| ERN1 | 15 | 19106 | -1.657 | 8.4e-06 | 0.0094 |

## Agreement with the published table

Published: `paper/tm_mle.tsv` (score `wald_p`, lower is stronger); 19113 genes, 18603 shared with BARCS.

Spearman correlation of gene scores: **0.14**


Effect direction agreement: 84.7% of 18603 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 5 | 0.14 | 15 | 15 |
| 50 | 21 | 0.27 | 29 | 29 |
| 100 | 56 | 0.39 | 44 | 44 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): EIF3B (2 / 711), ITPK1 (4 / 6202), TRIAP1 (5 / 140), DDX20 (6 / 122), SRP14 (7 / 110), EXO1 (8 / 10874), PIK3C3 (10 / 103), WRB (11 / 29), DDX1 (12 / 77), ATG3 (13 / 5133), TRAPPC11 (14 / 53), SERINC4 (16 / 2238), GTF3C5 (18 / 48), EIF6 (19 / 42), GARS (20 / 680)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): VARS (2 / 260), YARS (4 / 52), SMARCB1 (5 / 50), COG3 (7 / 37), DDOST (9 / 25), HARS (10 / 75), IARS (11 / 84), MARS (13 / 78), RTCB (14 / 42), POLR1E (15 / 60), GTF3C3 (16 / 115), VPS52 (17 / 39), PNISR (19 / 19095), OR10W1 (20 / 19090), RPL7L1 (21 / 116)

## BARCS calls

Genes at FDR 0.05: 74; at FDR 0.10: 91. Top 15: MFSD2A, EIF3B, GTF3C4, ITPK1, TRIAP1, DDX20, SRP14, EXO1, PRMT1, PIK3C3, WRB, DDX1, ATG3, TRAPPC11, ERN1
