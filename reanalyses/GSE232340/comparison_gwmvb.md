# BARCS versus published results

BARCS genes: `results/GW_meninges_vs_blood/genes.csv` (21766 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Itga4 | 1 | 21766 | -1.217 | 0.00012 | 0.91 |
| Cxcr3 | 4 | 21766 | -0.846 | 0.00045 | 0.91 |
| Fermt3 | 6 | 21766 | -0.999 | 0.00068 | 0.91 |
| Grk2 | 8 | 21766 | -1.339 | 0.0009 | 0.91 |
| Cbfb | 296 | 21766 | -0.733 | 0.087 | 0.91 |

## Agreement with the published table

Published: `paper/gw_MvsB_mageck.tsv` (score `neg_score`, lower is stronger); 21605 genes, 21578 shared with BARCS.

Spearman correlation of gene scores: **0.37**


Effect direction agreement: 56.1% of 21578 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 4 | 0.25 | 6 | 6 |
| 25 | 4 | 0.09 | 21 | 21 |
| 50 | 6 | 0.06 | 44 | 44 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Rab40c (2 / 2341), Gpr45 (3 / 19188), Dguok (5 / 15940), Ulk2 (7 / 2670), Olr20 (9 / 1584), Pard6b (10 / 6709)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Cbfb (4 / 296), Mgat4a (6 / 15952), Tln1 (7 / 26), LOC691030 (8 / 2816), LOC102547047 (9 / 4279), Rai1 (10 / 10385)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: Itga4, Rab40c, Gpr45, Cxcr3, Dguok, Fermt3, Ulk2, Grk2, Olr20, Pard6b, Nkain3, Mir431, Edem1, Chaf1b, Ankrd2
