# BARCS versus published results

BARCS genes: `results/xist_high_vs_negative/genes.csv` (911 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Xist_p1 | 1 | 911 | -1.644 | 3.1e-55 | 2.9e-52 |
| Zic3_p1 | 4 | 911 | -0.691 | 3.3e-24 | 7.4e-22 |
| Rlim_p1 | 5 | 911 | -0.557 | 4e-24 | 7.4e-22 |
| Tsix_p2 | 2 | 911 | 1.170 | 5.6e-47 | 2.5e-44 |

## Agreement with the published table

Published: `paper/GSE273070_TFi_mle_HighvsNeg.txt.gz` (score `High|wald-p-value`, lower is stronger); 912 genes, 911 shared with BARCS.

Spearman correlation of gene scores: **0.95**


Effect direction agreement: 84.3% of 911 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 20 | 0.67 | 5 | 5 |
| 50 | 42 | 0.72 | 8 | 8 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): Tsix_p2 (2 / 29), Grhl2_p1 (9 / 14)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): Nfe2l2_p1 (6 / 11), Rbpj_p2 (9 / 14)

## BARCS calls

Genes at FDR 0.05: 84; at FDR 0.10: 101. Top 15: Xist_p1, Tsix_p2, Pou5f1_p1, Zic3_p1, Rlim_p1, Nfrkb_p1, Otx2_p2, Rif1_p1, Grhl2_p1, Zfp518b_p1, Nfe2l2_p1, Tox4_p2, Adnp_p1, Rbpj_p2, Zfp280c_p1
