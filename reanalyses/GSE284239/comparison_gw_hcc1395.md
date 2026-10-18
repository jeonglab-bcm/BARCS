# BARCS versus published results

BARCS genes: `results/gw_tng348_vs_dmso/genes.csv` (19096 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PARP1 | 6 | 19096 | -2.107 | 1.9e-06 | 0.001 |
| RAD18 | 19091 | 19096 | 1.993 | 3.5e-14 | 1.1e-10 |

## Agreement with the published table

Published: `paper/tableS10.csv` (score `signed_score`, lower is stronger); 19114 genes, 19093 shared with BARCS.

Spearman correlation of gene scores: **0.27**


Effect direction agreement: 60.6% of 19093 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 20 | 2 | 0.05 | 18 | 18 |
| 50 | 2 | 0.02 | 48 | 48 |
| 100 | 4 | 0.02 | 96 | 96 |

### In the BARCS top 20 but not the published top 20

Gene (BARCS rank / published rank): UROD (1 / 8043), CREBBP (3 / 4556), UBE2D3 (4 / 4416), PARP1 (6 / 53), PAGR1 (7 / 15571), CHD1L (8 / 800), PAXIP1 (9 / 12309), BRCC3 (10 / 833), BRE (11 / 126), SLC25A19 (12 / 16089), MBD3 (13 / 1279), LIG1 (14 / 4770), KCTD5 (15 / 7600), SMG9 (16 / 18444), PCNP (17 / 6154), EXO1 (18 / 281), TDP1 (19 / 682), CSNK2A1 (20 / 426)

### In the published top 20 but not the BARCS top 20

Gene (published rank / BARCS rank): P3H1 (1 / 5204), DPP6 (2 / 3282), CCDC132 (4 / 566), SIVA1 (5 / 347), FAM151A (6 / 267), CSF1 (7 / 10178), IntroCuttingControl_6 (9 / 726), PRRT4 (10 / 1027), ILKAP (11 / 15991), CACFD1 (12 / 16328), ITGB3 (13 / 7548), ZP1 (14 / 5687), ZNF658 (15 / 8007), CNOT4 (16 / 226), ART4 (17 / 2891), ANKH (18 / 8339), CTDSP1 (19 / 14396), IMPG1 (20 / 271)

## BARCS calls

Genes at FDR 0.05: 80; at FDR 0.10: 102. Top 15: UROD, OGFR, CREBBP, UBE2D3, UIMC1, PARP1, PAGR1, CHD1L, PAXIP1, BRCC3, BRE, SLC25A19, MBD3, LIG1, KCTD5
