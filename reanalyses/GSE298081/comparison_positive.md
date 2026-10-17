# BARCS versus published results

BARCS genes: `results/ptar1_vs_wt_gi/genes.csv` (18049 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ABHD16A | 10 | 18049 | 0.445 | 2.4e-11 | 3.9e-08 |
| ABHD17B | 2 | 18049 | 0.589 | 1e-16 | 9.2e-13 |

## Agreement with the published table

Published: `paper/PTAR1_qGI.csv` (score `qGI_medium_mean`, higher is stronger); 17724 genes, 17722 shared with BARCS.

Spearman correlation of gene scores: **0.53**


Effect direction agreement: 67.7% of 17722 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 22 | 0.28 | 28 | 28 |
| 100 | 36 | 0.22 | 64 | 64 |
| 200 | 67 | 0.20 | 133 | 133 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): TAF3 (1 / 138), CNOT4 (6 / 114), TAF4 (7 / 343), CAB39 (11 / 270), EIF2B2 (15 / 339), DTYMK (17 / 531), TIMM23 (19 / 321), ATP6V1B2 (21 / 1231), CIAPIN1 (26 / 297), CHMP6 (27 / 605), CREBBP (28 / 85), RPS21 (29 / 2390), PSMD13 (30 / 68), HSCB (32 / 3710), PPP2CA (34 / 3541), ZC3H18 (36 / 431), CDC45 (38 / 160), CDAN1 (39 / 129), EMC2 (40 / 83), PHB (41 / 5579), SCRIB (42 / 127), TGIF2 (44 / 64), CLP1 (45 / 823), GBF1 (46 / 494), COPS2 (47 / 5326)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): NUP188 (10 / 201), RABGEF1 (12 / 1555), RAB5C (16 / 621), COMMD3 (18 / 838), TGFBRAP1 (19 / 60), INTS6 (21 / 264), VPS8 (23 / 114), CTNNA1 (25 / 3514), PRPF40A (27 / 802), EIF4E2 (28 / 1366), KAT2A (29 / 570), TMED10 (30 / 83), LOXL1 (33 / 4452), OAZ1 (34 / 13747), SFSWAP (35 / 405), PFDN1 (37 / 111), TFAP4 (39 / 480), BRPF1 (40 / 243), SMS (41 / 2034), SURF4 (42 / 85), KPNA2 (43 / 314), KHDRBS1 (44 / 963), EMC6 (45 / 745), KIF23 (46 / 53), GOLGA5 (47 / 598)

## BARCS calls

Genes at FDR 0.05: 473; at FDR 0.10: 700. Top 15: TAF3, ABHD17B, ARF1, ADIPOR2, PSMD6, CNOT4, TAF4, TMED2, SLC39A9, ABHD16A, CAB39, SH3GL1, C12orf23, TMED9, EIF2B2
