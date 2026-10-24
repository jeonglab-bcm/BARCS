# BARCS versus published results

BARCS genes: `results/GFPhigh_vs_GFPlow/genes.csv` (20694 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| SAYSD1 | 23 | 20694 | 0.634 | 0.00077 | 0.079 |
| UFM1 | 182 | 20694 | 0.809 | 0.021 | 0.26 |
| UBA5 | 581 | 20694 | 0.816 | 0.08 | 0.43 |
| DDRGK1 | 6 | 20694 | 1.098 | 2.9e-05 | 0.027 |
| CDK5RAP3 | 26 | 20694 | 1.390 | 0.00098 | 0.085 |
| UFSP2 | 634 | 20694 | 0.244 | 0.088 | 0.44 |

## Agreement with the published table

Published: `suppl/GSE222104_ER_K20_GFP_high.gene_summary.xlsx` (score `pos|score`, lower is stronger); 21697 genes, 20670 shared with BARCS.

Spearman correlation of gene scores: **0.79**


Effect direction agreement: 70.0% of 20670 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 4 | 0.25 | 6 | 6 |
| 25 | 13 | 0.35 | 12 | 12 |
| 50 | 27 | 0.37 | 23 | 23 |
| 100 | 46 | 0.30 | 54 | 54 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): NELFCD (3 / 14), DHX15 (4 / 12), DDRGK1 (6 / 11), GCN1L1 (7 / 17), hsa-mir-943 (8 / 38), RPLP0 (10 / 30)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): NELFB (4 / 57), CDK5RAP3 (5 / 26), EIF5AL1 (6 / 279), UFM1 (7 / 182), POLR3H (8 / 13), GAPDH (10 / 101)

## BARCS calls

Genes at FDR 0.05: 62; at FDR 0.10: 299. Top 15: CRCP, SART3, NELFCD, DHX15, SEC61B, DDRGK1, GCN1L1, hsa-mir-943, NELFA, RPLP0, NAA38, EIF6, POLR3H, DHX8, PRPF3
