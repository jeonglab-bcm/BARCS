# BARCS versus published results

BARCS genes: `results/VAL_parenchyma_vs_blood/genes.csv` (1961 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Itga4 | 1 | 1961 | -1.420 | 1.8e-12 | 3.6e-09 |
| Cxcr3 | 3 | 1961 | -0.994 | 9.1e-11 | 5.9e-08 |
| Fermt3 | 4 | 1961 | -1.370 | 1.3e-10 | 6.6e-08 |
| Grk2 | 7 | 1961 | -0.635 | 4.7e-06 | 0.0012 |
| Cbfb | 12 | 1961 | -1.493 | 7.1e-05 | 0.0099 |

## Agreement with the published table

Published: `paper/val_PvsB_mageck.tsv` (score `neg_score`, lower is stronger); 1961 genes, 1961 shared with BARCS.

Spearman correlation of gene scores: **0.47**


Effect direction agreement: 71.3% of 1961 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 15 | 0.43 | 10 | 10 |
| 50 | 22 | 0.28 | 28 | 28 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Gnai2 (6 / 12), Stt3a (8 / 32)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Cbfb (3 / 12), Psenen (10 / 18)

## BARCS calls

Genes at FDR 0.05: 17; at FDR 0.10: 22. Top 15: Itga4, Hsp90b1, Cxcr3, Fermt3, Prdm1, Gnai2, Grk2, Stt3a, Tnfaip3, Foxo1, Cic, Cbfb, Smg7, Tln1, Itgb1
