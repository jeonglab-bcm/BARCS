# BARCS versus published results

BARCS genes: `results/top10_vs_next25/genes.csv` (19114 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| SPTAN1 | 1317 | 19114 | -6.327 | 0.32 | 1 |
| RAF1 | 5813 | 19114 | -6.502 | 0.68 | 1 |
| STIM2 | 2 | 19114 | -2.143 | 0.013 | 1 |
| MYL2 | 4392 | 19114 | -6.332 | 0.59 | 1 |
| ACTA1 | 4035 | 19114 | -6.447 | 0.56 | 1 |
| KRAS | 872 | 19114 | -0.730 | 0.26 | 1 |

## Agreement with the published table

Published: `paper/mageck_mle.tsv` (score `wald_p`, lower is stronger); 19112 genes, 19086 shared with BARCS.

Spearman correlation of gene scores: **0.08**


Effect direction agreement: 77.5% of 19086 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 0 | 0.00 | 50 | 50 |
| 100 | 2 | 0.01 | 98 | 98 |
| 200 | 10 | 0.03 | 190 | 190 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): SLC43A1 (1 / 766), STIM2 (2 / 75), RPP25L (3 / 380), BCL2L10 (4 / 616), SNAI2 (5 / 2147), SWSAP1 (6 / 1417), LIFR (7 / 1092), FUNDC1 (8 / 454), SF1 (9 / 974), DNAJC18 (10 / 8239), BAIAP3 (11 / 4941), CDC73 (12 / 2201), LZTS2 (13 / 1579), ROM1 (14 / 264), ABHD17C (15 / 89), TMCO5A (16 / 12363), G0S2 (17 / 599), NDUFA5 (18 / 6797), DPM1 (19 / 681), TRAK2 (20 / 663), ABCG1 (21 / 18121), CYP51A1 (22 / 344), RNF186 (23 / 10417), TECR (24 / 392), GRAMD4 (25 / 252)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): OR4D9 (1 / 5085), ERICH2 (2 / 5118), TMC8 (3 / 4728), AIFM2 (4 / 5424), LENEP (5 / 5358), BATF3 (6 / 3675), LMNTD2 (7 / 5152), EVX1 (8 / 4365), SYPL2 (9 / 5305), ZNF737 (10 / 4116), KLHL33 (11 / 4309), PADI3 (12 / 3694), MGC57346-CRHR1 (13 / 5429), BCL2 (14 / 4792), RPL36 (15 / 5581), ASMTL (16 / 3987), PPEF2 (17 / 4687), OR8H3 (18 / 2545), APBA2 (19 / 3124), FKBP9 (20 / 4474), ADAM17 (21 / 5131), CNBD1 (22 / 6314), ZC3H12C (23 / 5483), ROMO1 (24 / 5833), HTR1B (25 / 2275)

## BARCS calls

Genes at FDR 0.05: 0; at FDR 0.10: 0. Top 15: SLC43A1, STIM2, RPP25L, BCL2L10, SNAI2, SWSAP1, LIFR, FUNDC1, SF1, DNAJC18, BAIAP3, CDC73, LZTS2, ROM1, ABHD17C
