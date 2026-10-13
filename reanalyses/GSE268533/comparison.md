# BARCS versus published results

BARCS genes: `results/sgCD274_vs_sgControl/genes.csv` (18421 genes, direction: depleted)

## Agreement with the published table

Published: `suppl/GSE268533_sgCD274_vs_sgControl.gene_summary.txt.gz` (score `neg|score`, lower is stronger); 18823 genes, 18420 shared with BARCS.

Spearman correlation of gene scores: **0.68**


Effect direction agreement: 95.3% of 18420 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 1 | 0.01 | 49 | 49 |
| 100 | 1 | 0.01 | 99 | 99 |
| 200 | 2 | 0.01 | 198 | 198 |
| 500 | 34 | 0.04 | 466 | 466 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): SPATC1 (1 / 880), MAGEC1 (3 / 883), DNAJB14 (4 / 1259), CLC (5 / 1013), MAP1B (6 / 343), C10orf82 (7 / 2781), DNMT3L (8 / 6499), PYCRL (9 / 3733), FAM111B (10 / 1543), NOTUM (11 / 1192), DENND5B (12 / 493), ERI3 (13 / 1885), DBNDD2 (14 / 2209), ALCAM (15 / 613), ODF3L2 (16 / 234), OR2V2 (17 / 7813), CRB3 (18 / 354), OR6N2 (19 / 1126), GAL3ST4 (20 / 4642), FAM47B (21 / 3116), MUC4 (22 / 2322), MICB (23 / 1920), POU6F1 (24 / 3040), HPRT1 (25 / 1513), COLGALT2 (26 / 3557)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): SAR1A (2 / 2684), TNFRSF25 (3 / 1581), F8A2 (4 / 3229), HSPB2 (5 / 5553), TRPC1 (6 / 2488), KLHL38 (7 / 1924), SLC35A3 (8 / 2589), P2RX7 (9 / 2041), CNTNAP3B (10 / 2295), KRTAP4-6 (11 / 5244), DYNC1LI2 (12 / 864), HDAC7 (13 / 5723), APOL3 (14 / 3492), TNFRSF1A (15 / 2430), NUTM2F (16 / 2713), TAF3 (17 / 2087), CHRM3 (18 / 3990), NDUFS3 (19 / 5222), LIN28B (20 / 8404), LILRB2 (21 / 4613), LRRC3C (22 / 1749), PPCS (23 / 4390), PRPSAP1 (24 / 7774), MSANTD3-TMEFF1 (25 / 4958), ACSM3 (26 / 5694)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: SPATC1, KCTD18, MAGEC1, DNAJB14, CLC, MAP1B, C10orf82, DNMT3L, PYCRL, FAM111B, NOTUM, DENND5B, ERI3, DBNDD2, ALCAM
