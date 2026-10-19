# BARCS versus published results

BARCS genes: `results/combo_vs_DMSO/genes.csv` (18907 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PTEN | 1 | 18907 | 1.446 | 1.1e-60 | 2.1e-56 |
| NF1 | 3 | 18907 | 0.769 | 5.3e-28 | 3.3e-24 |
| KEAP1 | 63 | 18907 | 0.820 | 2.4e-10 | 6.5e-08 |
| CUL5 | 6 | 18907 | 0.935 | 1.6e-25 | 5.1e-22 |
| ARIH2 | 4 | 18907 | 1.632 | 5.3e-27 | 2.5e-23 |
| PLCG1 | 2 | 18907 | 1.309 | 2.3e-39 | 2.2e-35 |

## Agreement with the published table

Published: `paper/rsa_NCI-H23.tsv` (score `rsa_activator_logp`, lower is stronger); 19092 genes, 18907 shared with BARCS.

Spearman correlation of gene scores: **0.37**


Effect direction agreement: 63.5% of 18907 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 11 | 0.28 | 14 | 14 |
| 50 | 13 | 0.15 | 37 | 37 |
| 100 | 28 | 0.16 | 72 | 72 |
| 200 | 57 | 0.17 | 143 | 143 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): NF2 (5 / 71), CSNK2A1 (7 / 77), PIK3R3 (8 / 190), TAOK1 (11 / 456), ROR1 (12 / 302), CBL (13 / 163), RASA2 (14 / 86), EGLN1 (15 / 85), PDE4B (17 / 264), BIRC2 (18 / 298), RNF7 (19 / 29), PRKAA2 (23 / 181), CASP1 (24 / 980), CACHD1 (25 / 448)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): SLC25A19 (7 / 2754), HDGFRP2 (9 / 1504), ELOF1 (10 / 437), DCUN1D3 (12 / 61), GRSF1 (14 / 4349), CARM1 (15 / 72), CSAD (16 / 4879), YWHAE (17 / 723), ZBTB7A (18 / 1204), NDUFAF5 (19 / 3194), DDN (20 / 2160), SCD (21 / 67), FASTKD5 (22 / 439), SIPA1L1 (25 / 1965)

## BARCS calls

Genes at FDR 0.05: 6791; at FDR 0.10: 8606. Top 15: PTEN, PLCG1, NF1, ARIH2, NF2, CUL5, CSNK2A1, PIK3R3, SRGAP1, PPP6C, TAOK1, ROR1, CBL, RASA2, EGLN1
