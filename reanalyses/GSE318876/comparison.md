# BARCS versus published results

BARCS genes: `results/calA_GFPneg_vs_GFPpos/genes.csv` (18886 genes, direction: enriched)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| PPID | 1 | 18886 | 1.013 | 4.4e-14 | 8.3e-10 |
| PI16 | 4 | 18886 | 0.562 | 7.2e-12 | 3.4e-08 |
| SHISA3 | 7 | 18886 | 0.814 | 3e-09 | 6.3e-06 |
| ITM2A | 8 | 18886 | 0.689 | 3.4e-09 | 6.5e-06 |

## Agreement with the published table

Published: `suppl/GSE318876_All_screens_MAGeCK_gene_summaries.xlsx` (score `neg|score`, lower is stronger); 19095 genes, 18886 shared with BARCS.

Spearman correlation of gene scores: **0.53**


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 33 | 0.49 | 17 | 17 |
| 100 | 61 | 0.44 | 39 | 39 |
| 200 | 101 | 0.34 | 99 | 99 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): PTPN12 (16 / 86), KLHDC10 (25 / 88), TFRC (28 / 61), C9 (29 / 54), ARHGAP40 (31 / 94), IRF4 (33 / 57), GCNT2 (36 / 77), UBE2E1 (37 / 344), GPX4 (38 / 177), TRIM5 (40 / 107), CBFA2T2 (41 / 78), FCGR2A (42 / 52), GRIFIN (44 / 164), HRH4 (45 / 205), GATA6 (47 / 67), CCR2 (48 / 106), HOXB13 (50 / 501)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): SPN (8 / 65), ACE (23 / 57), CA4 (24 / 95), ARHGAP20 (29 / 140), TRPV5 (30 / 206), ZYG11A (31 / 984), TOM1L1 (34 / 55), FASLG (35 / 81), PDPN (36 / 2137), CR2 (41 / 247), AIM2 (42 / 52), LITAF (43 / 71), EMP1 (46 / 72), TBX2 (47 / 181), IFITM1 (48 / 149), CD44 (49 / 188), TNFRSF10B (50 / 128)

## BARCS calls

Genes at FDR 0.05: 201; at FDR 0.10: 366. Top 15: PPID, ARHGDIB, CD14, PI16, MUC1, MX2, SHISA3, ITM2A, MUC21, RAP1GAP, C1orf54, ATP10A, GPR15, ICAM3, CD52
