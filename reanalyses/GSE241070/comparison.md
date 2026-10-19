# BARCS versus published results

BARCS genes: `results/MPA_vs_DMSO/genes.csv` (18833 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| NNMT | 50 | 18833 | -0.341 | 6.7e-05 | 0.024 |
| ABCC2 | 981 | 18833 | -0.244 | 0.028 | 0.53 |
| AMPD3 | 1127 | 18833 | -0.168 | 0.033 | 0.55 |
| PDE1A | 544 | 18833 | -0.239 | 0.012 | 0.41 |
| DTX3L | 709 | 18833 | -0.226 | 0.018 | 0.47 |
| SOX17 | 154 | 18833 | 0.415 | 0.0013 | 0.16 |
| KCNRG | 321 | 18833 | 0.330 | 0.0053 | 0.31 |
| RPL22L1 | 2976 | 18833 | 0.220 | 0.12 | 0.74 |
| ZIC2 | 49 | 18833 | 0.459 | 6.2e-05 | 0.024 |
| HHIPL1 | 293 | 18833 | 0.173 | 0.0044 | 0.28 |

## Agreement with the published table

Published: `paper/rra.tsv` (score `min_p`, lower is stronger); 18834 genes, 18822 shared with BARCS.

Spearman correlation of gene scores: **0.52**


Effect direction agreement: 81.1% of 18822 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 28 | 0.39 | 22 | 22 |
| 100 | 67 | 0.50 | 33 | 33 |
| 200 | 131 | 0.49 | 69 | 69 |
| 500 | 300 | 0.43 | 200 | 200 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): EMG1 (13 / 55), GINS3 (16 / 76), RPS5 (20 / 70), MCM2 (23 / 66), ATP6V1B2 (24 / 95), EXOSC7 (26 / 118), GNL2 (29 / 114), RPS28 (30 / 115), HES5 (32 / 57), ATP6AP1 (33 / 110), KAT8 (34 / 170), H2AFX (37 / 156), PMF1 (38 / 64), CENPK (39 / 83), DCTN5 (40 / 79), NOC2L (41 / 78), RCC1 (44 / 124), USP17L11 (45 / 119), COQ10B (47 / 418), SPDYE1 (48 / 61), ZIC2 (49 / 56), NNMT (50 / 618)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): MAD2L1 (1 / 330), MBD3L4 (5 / 520), ABT1 (9 / 69), POLR2J (11 / 52), ZNRD1 (12 / 111), HINFP (16 / 54), PSMD8 (19 / 64), SNAP23 (20 / 53), RFC5 (26 / 60), CDC123 (28 / 56), XRCC6 (32 / 83), G6PD (33 / 109), PCDHGA1 (35 / 112), GTF3C3 (36 / 79), UBAP2 (37 / 433), SMDT1 (40 / 70), KAT6A (41 / 98), UHRF1 (42 / 95), FAM86B2 (44 / 376), DDX51 (46 / 57), DDX10 (47 / 66), RPL9 (49 / 145)

## BARCS calls

Genes at FDR 0.05: 74; at FDR 0.10: 114. Top 15: ATP6V0C, SIN3A, SNRNP25, ATP6V1G1, DET1, ATP6V0D1, GINS1, FOXD4L2, BRF1, DTYMK, GPKOW, LOC100288332, EMG1, PRC1, UBE2M
