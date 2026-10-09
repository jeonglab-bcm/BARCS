# BARCS versus published results

BARCS genes: `results/KPK_specific_dropout/genes.csv` (611 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Hdac1 | 7 | 611 | -0.307 | 2.2e-06 | 0.00015 |
| Hdac2 | 27 | 611 | -0.309 | 0.0014 | 0.018 |
| Hdac3 | 13 | 611 | -0.544 | 2.4e-05 | 0.00083 |

## Agreement with the published table

Published: `paper/mle_kpk_minus_kp.tsv` (score `KPK_minus_KP_beta`, lower is stronger); 612 genes, 611 shared with BARCS.

Spearman correlation of gene scores: **0.94**


Effect direction agreement: 87.4% of 611 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 6 | 0.43 | 4 | 4 |
| 25 | 17 | 0.52 | 8 | 8 |
| 50 | 38 | 0.61 | 12 | 12 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Setdb1 (3 / 23), Actr5 (4 / 13), Hdac1 (7 / 19), Gatad2a (8 / 21)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Hdac3 (4 / 13), Chd4 (6 / 29), Smarcd1 (7 / 21), Dot1l (8 / 30)

## BARCS calls

Genes at FDR 0.05: 66; at FDR 0.10: 84. Top 15: Kdm1a, Setd5, Setdb1, Actr5, H2afz, Sirt6, Hdac1, Gatad2a, Mtr, Brd2, Nat6, Smarcd2, Hdac3, Rnf40, Mta2
