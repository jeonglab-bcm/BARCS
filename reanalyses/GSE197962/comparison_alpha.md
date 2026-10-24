# BARCS versus published results

BARCS genes: `results/Alpha_vs_uninfected/genes.csv` (19007 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ACE2 | 1 | 19007 | 1.288 | 4.5e-05 | 0.86 |
| GATA6 | 100 | 19007 | 0.562 | 0.015 | 1 |
| KREMEN2 | 156 | 19007 | 0.656 | 0.024 | 1 |
| SETDB1 | 454 | 19007 | 0.715 | 0.063 | 1 |

## Agreement with the published table

Published: `paper/gene_results.tsv` (score `pos_score_alpha`, lower is stronger); 19114 genes, 19007 shared with BARCS.

Spearman correlation of gene scores: **0.36**


Effect direction agreement: 64.8% of 19007 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 2 | 0.05 | 18 | 18 |
| 50 | 4 | 0.04 | 46 | 46 |
| 100 | 9 | 0.05 | 91 | 91 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): B3GALT5 (2 / 27), PTCHD4 (3 / 1371), OVOL1 (4 / 13527), MICU2 (5 / 3344), LONRF1 (6 / 10318), CREBBP (7 / 319), C4orf26 (8 / 2647), MIA2 (9 / 1797), ASCL5 (10 / 8808), DCAF4 (11 / 7931), LOC101928841 (12 / 3661), GUF1 (13 / 2881), LAPTM4B (14 / 98), EID2 (15 / 540), OR2F1 (17 / 978), IQSEC2 (18 / 2722), GCC2 (19 / 1077), KIR2DL4 (20 / 958)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): AP1G1 (3 / 469), GATA6 (4 / 100), EFHB (5 / 2224), PTMS (6 / 295), CNIH1 (7 / 4842), ROCK2 (8 / 53), IRF6 (9 / 1328), MGA (10 / 102), WBP11 (11 / 16290), CYSLTR1 (12 / 60), C4orf33 (13 / 2587), GLYATL2 (14 / 2177), ALDOB (15 / 13600), CRIM1 (16 / 849), ACOT13 (17 / 8964), DYNLT3 (18 / 344), SEL1L3 (19 / 1332), AMN1 (20 / 171)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: ACE2, B3GALT5, PTCHD4, OVOL1, MICU2, LONRF1, CREBBP, C4orf26, MIA2, ASCL5, DCAF4, LOC101928841, GUF1, LAPTM4B, EID2
