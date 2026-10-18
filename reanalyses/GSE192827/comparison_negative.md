# BARCS versus published results

BARCS genes: `results/low_vs_high/genes.csv` (17991 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| ZNF217 | 3 | 17991 | -2.251 | 5.7e-117 | 1e-113 |
| CTBP1 | 1 | 17991 | -3.559 | 5.3e-173 | 2.4e-169 |
| RUNX1 | 13 | 17991 | -2.786 | 2e-88 | 1.6e-85 |
| CBFB | 29 | 17991 | -2.387 | 4.3e-69 | 1.9e-66 |
| HDAC8 | 50 | 17991 | -0.990 | 2.8e-54 | 7.1e-52 |
| RING1 | 4 | 17991 | -1.274 | 2.9e-110 | 4.7e-107 |

## Agreement with the published table

Published: `paper/MOESM8.xlsx` (score `neg|score`, lower is stronger); 18000 genes, 17991 shared with BARCS.

Spearman correlation of gene scores: **0.75**


Effect direction agreement: 81.5% of 17991 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 13 | 0.35 | 12 | 12 |
| 50 | 36 | 0.56 | 14 | 14 |
| 100 | 81 | 0.68 | 19 | 19 |
| 200 | 158 | 0.65 | 42 | 42 |
| 500 | 437 | 0.78 | 63 | 63 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): AUP1 (7 / 29), GALE (12 / 42), SUPT7L (14 / 26), SLC35A1 (15 / 66), EIF4ENIF1 (16 / 34), ATXN7 (17 / 45), TGFBR2 (18 / 48), SLC4A7 (19 / 96), CDK13 (21 / 31), ERF (22 / 33), EDC4 (24 / 38), CCNL1 (25 / 28)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): HDAC8 (5 / 50), CBFB (8 / 29), ST6GAL1 (12 / 27), ATIC (15 / 34), TIAL1 (16 / 38), CSRNP1 (18 / 43), GADD45A (19 / 62), EDEM3 (20 / 42), AGO2 (21 / 41), RNASEH2A (22 / 32), SRD5A3 (23 / 28), ZNF281 (24 / 70)

## BARCS calls

Genes at FDR 0.05: 2683; at FDR 0.10: 3244. Top 15: CTBP1, CMAS, ZNF217, RING1, KCTD5, RBM38, AUP1, IKZF1, UBE2E1, RER1, MAP2K3, GALE, RUNX1, SUPT7L, SLC35A1
