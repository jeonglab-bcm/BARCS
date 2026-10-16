# BARCS versus published results

BARCS genes: `results/PDL1_secondary_low_vs_high/genes.csv` (2258 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Cd274 | 1 | 2258 | 2.143 | 1.4e-30 | 3.2e-27 |
| Cebpb | 2 | 2258 | 1.768 | 7.1e-19 | 8e-16 |

## Agreement with the published table

Published: `paper/pdl1_sec_mageck.tsv` (score `min_p`, lower is stronger); 2259 genes, 2258 shared with BARCS.

Spearman correlation of gene scores: **0.62**


Effect direction agreement: 85.9% of 2258 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 38 | 0.61 | 12 | 12 |
| 100 | 71 | 0.55 | 29 | 29 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Uba52 (13 / 27), Rpl9 (19 / 41), Rps13 (22 / 36), Eif3e (24 / 29), Setd5 (25 / 30)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Bptf (19 / 83), Cmtm6 (21 / 69), Polr2d (22 / 29), Pi4kb (23 / 28), Ep300 (25 / 51)

## BARCS calls

Genes at FDR 0.05: 65; at FDR 0.10: 81. Top 15: Cd274, Cebpb, Zeb2, Rpl5, Irf4, B4galt1, Rps15a, Ddx3x, Sptlc2, Irf2, Rpl35, Trp53, Uba52, Rpn1, Ankrd11
