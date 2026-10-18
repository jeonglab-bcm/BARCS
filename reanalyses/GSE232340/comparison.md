# BARCS versus published results

BARCS genes: `results/GW_parenchyma_vs_blood/genes.csv` (21773 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Itga4 | 1 | 21773 | -1.318 | 2.7e-05 | 0.59 |
| Cxcr3 | 30 | 21773 | -0.513 | 0.0086 | 0.83 |
| Fermt3 | 12 | 21773 | -0.799 | 0.0024 | 0.83 |
| Grk2 | 8 | 21773 | -1.239 | 0.0017 | 0.83 |
| Cbfb | 654 | 21773 | -0.323 | 0.2 | 0.83 |

## Agreement with the published table

Published: `paper/gw_PvsB_mageck.tsv` (score `neg_score`, lower is stronger); 21567 genes, 21541 shared with BARCS.

Spearman correlation of gene scores: **0.40**


Effect direction agreement: 55.3% of 21541 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 2 | 0.11 | 8 | 8 |
| 25 | 4 | 0.09 | 21 | 21 |
| 50 | 5 | 0.05 | 45 | 45 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Ostc (2 / 10623), Ulk2 (3 / 8657), Dguok (4 / 11780), Ssr2 (5 / 3640), Gpr45 (6 / 19960), Mir431 (7 / 273), Kcnj9 (9 / 2663), Atg7 (10 / 252)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Fermt3 (3 / 12), Cxcr3 (4 / 30), Cbfb (5 / 654), Prdm1 (6 / 3011), Tln1 (7 / 80), Tnfaip3 (8 / 148), S100b (9 / 2711), E2f8 (10 / 1838)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: Itga4, Ostc, Ulk2, Dguok, Ssr2, Gpr45, Mir431, Grk2, Kcnj9, Atg7, Gne, Fermt3, Rab40c, Brd2, Nkain3
