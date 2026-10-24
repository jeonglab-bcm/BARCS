# BARCS versus published results

BARCS genes: `results/all_infected_vs_uninfected/genes.csv` (19023 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ACE2 | 2 | 19023 | 1.557 | 0.00012 | 0.37 |
| GATA6 | 9 | 19023 | 0.762 | 0.0027 | 0.87 |
| CHMP2B | 15887 | 19023 | -0.252 | 0.25 | 1 |
| CUL5 | 3534 | 19023 | 0.079 | 0.49 | 1 |
| IRF6 | 1831 | 19023 | 0.373 | 0.29 | 1 |
| EP300 | 151 | 19023 | 0.574 | 0.042 | 0.97 |

## Agreement with the published table

Published: `paper/gene_results.tsv` (score `pos_score_all`, lower is stronger); 19114 genes, 19023 shared with BARCS.

Spearman correlation of gene scores: **0.34**


Effect direction agreement: 56.7% of 19023 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 2 | 0.05 | 18 | 18 |
| 50 | 3 | 0.03 | 47 | 47 |
| 100 | 7 | 0.04 | 93 | 93 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): MBNL1 (1 / 414), DCAF4 (3 / 5050), PBRM1 (4 / 1202), SIGLEC9 (5 / 882), KMT2C (6 / 36), ZNF43 (7 / 2235), TCL1B (8 / 6175), SZRD1 (10 / 2938), TMEM253 (11 / 4547), MTCL1 (12 / 4414), GRK7 (13 / 1740), PTCHD4 (14 / 7129), DAP3 (15 / 11012), MDGA1 (16 / 14089), TSPAN11 (17 / 7149), ZNF155 (18 / 7697), KCNE4 (19 / 1573), FHIT (20 / 439)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): CUL5 (3 / 3534), IRF6 (4 / 1831), PRORY (5 / 809), EXTL2 (6 / 316), AP1G1 (7 / 568), EP300 (8 / 151), CTDSPL2 (9 / 3236), RLN1 (10 / 1975), DUSP7 (11 / 1491), SLC35F4 (12 / 6206), ARIH2 (13 / 239), UBP1 (14 / 3940), PRR18 (15 / 69), GNG4 (16 / 89), EFHB (17 / 4270), ZNF330 (18 / 223), TAF4B (19 / 546), NFKB1 (20 / 2018)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: MBNL1, ACE2, DCAF4, PBRM1, SIGLEC9, KMT2C, ZNF43, TCL1B, GATA6, SZRD1, TMEM253, MTCL1, GRK7, PTCHD4, DAP3
