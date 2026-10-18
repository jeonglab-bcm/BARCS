# BARCS versus published results

BARCS genes: `results/bile_vs_tyg/genes.csv` (166 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| BTnc167 | 2 | 166 | 0.375 | 3.3e-06 | 0.00027 |
| BTnc353 | 1 | 166 | -0.505 | 5.3e-07 | 8.9e-05 |

## Agreement with the published table

Published: `paper/per_sRNA_matched.tsv` (score `pvalue`, lower is stronger); 164 genes, 160 shared with BARCS.

Spearman correlation of gene scores: **0.39**


Effect direction agreement: 80.6% of 160 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 5 | 2 | 0.25 | 3 | 3 |
| 10 | 5 | 0.33 | 5 | 5 |
| 20 | 11 | 0.38 | 9 | 9 |

### In the BARCS top 5 but not the published top 5

Gene (BARCS rank / published rank): BTnc242 (3 / 27), BTnc279 (4 / 42), BTnc231 (5 / 10)

### In the published top 5 but not the BARCS top 5

Gene (published rank / BARCS rank): BTnc019 (4 / 10), BTnc100 (5 / 21), BTnc060 (6 / 62)

## BARCS calls

Genes at FDR 0.05: 2; at FDR 0.10: 3. Top 15: BTnc353, BTnc167, BTnc242, BTnc279, BTnc231, BTnc005, BTnc331|BTnc341, BTnc119, BTnc350, BTnc019, BTnc113, BTnc237, BTnc292, BTnc342, BTnc173
