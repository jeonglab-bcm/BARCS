# BARCS versus published results

BARCS genes: `results/calB_GFPneg_vs_GFPpos/genes.csv` (18840 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PPID | 1 | 18840 | 1.077 | 4.2e-20 | 7.9e-16 |
| PI16 | 4 | 18840 | 1.124 | 9.4e-16 | 4.5e-12 |
| SHISA3 | 3 | 18840 | 1.175 | 2.6e-17 | 1.6e-13 |
| ITM2A | 6 | 18840 | 0.717 | 2.9e-13 | 9.1e-10 |

## Agreement with the published table

Published: `suppl/GSE318876_All_screens_MAGeCK_gene_summaries.xlsx` (score `neg|score`, lower is stronger); 19095 genes, 18840 shared with BARCS.

Spearman correlation of gene scores: **0.48**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 38 | 0.61 | 12 | 12 |
| 100 | 64 | 0.47 | 36 | 36 |
| 200 | 110 | 0.38 | 90 | 90 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): CD38 (26 / 64), TNFRSF10A (30 / 79), RAP1GAP2 (31 / 62), ZNF592 (33 / 123), UCK2 (35 / 82), NR4A3 (36 / 74), PIP4K2C (40 / 81), PLXNA4 (41 / 172), LYN (43 / 58), HCAR2 (46 / 96), NKX2-5 (47 / 135), RBMY1B (49 / 153)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): CD14 (11 / 110), CDIP1 (12 / 89), GPR15 (18 / 55), MAP4K1 (27 / 57), CA9 (37 / 288), C3orf52 (38 / 335), NR2F1 (39 / 77), LHX9 (40 / 93), BATF2 (44 / 90), SP3 (45 / 893), EMP1 (46 / 94), TNFRSF10B (50 / 53)

## BARCS calls

Genes at FDR 0.05: 132; at FDR 0.10: 178. Top 15: PPID, SPN, SHISA3, PI16, SELPLG, ITM2A, ARHGDIB, MUC1, ZYG11A, ACE, PTPRC, LRRC15, CD44, FOXC1, ICAM3
