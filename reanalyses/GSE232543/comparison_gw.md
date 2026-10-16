# BARCS versus published results

BARCS genes: `results/CebpbKO_GW_CD86low_vs_high/genes.csv` (19675 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Cd86 | 1 | 19675 | 2.165 | 1.1e-15 | 2.2e-11 |
| Nr4a3 | 372 | 19675 | 0.688 | 0.097 | 1 |
| Stat2 | not tested | | | | |
| Mitf | 5714 | 19675 | 0.041 | 0.78 | 1 |

## Agreement with the published table

Published: `paper/CebpbKO_GW_mageck.tsv` (score `pos|rank`, lower is stronger); 19674 genes, 19674 shared with BARCS.

Spearman correlation of gene scores: **0.80**


Effect direction agreement: 91.3% of 19674 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 2 | 0.11 | 8 | 8 |
| 25 | 10 | 0.25 | 15 | 15 |
| 50 | 18 | 0.22 | 32 | 32 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Cd101 (2 / 84), Eps15 (4 / 70), Rassf3 (5 / 69), Junb (6 / 13), Vmn1r33 (7 / 104), Hax1 (8 / 44), Prmt2 (9 / 33), Klf6 (10 / 22)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Ptgr1 (3 / 7472), Pgk2 (4 / 14), Gse1 (5 / 17597), Esam (6 / 20), Arid1a (7 / 25), Esr1 (8 / 24), Hist2h3c1 (9 / 4239), 1700028P14Rik (10 / 7178)

## BARCS calls

Genes at FDR 0.05: 1; at FDR 0.10: 1. Top 15: Cd86, Cd101, Matn1, Eps15, Rassf3, Junb, Vmn1r33, Hax1, Prmt2, Klf6, Vmn2r13, Vipr2, Stag2, Pgk2, Fam19a5
