# BARCS versus published results

BARCS genes: `results/AZA_vs_DMSO/genes.csv` (19010 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| TOPORS | 4 | 19010 | -1.139 | 6.8e-12 | 1.1e-08 |
| UBE2K | 2 | 19010 | -1.438 | 4.8e-13 | 1.2e-09 |
| UBXN7 | 16 | 19010 | -1.237 | 6.3e-05 | 0.0074 |

## Agreement with the published table

Published: `paper/beta_scores.tsv` (score `diff`, lower is stronger); 19112 genes, 19010 shared with BARCS.

Spearman correlation of gene scores: **0.72**


Effect direction agreement: 75.4% of 19010 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 5 | 0.11 | 20 | 20 |
| 50 | 7 | 0.08 | 43 | 43 |
| 100 | 11 | 0.06 | 89 | 89 |
| 200 | 36 | 0.10 | 164 | 164 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): PTEN (1 / 90), ARIH2 (3 / 34), SIRT6 (5 / 79), UBAP2L (6 / 91), TMEM215 (7 / 147), GLRX (8 / 158), GCM2 (9 / 1966), TMEM168 (10 / 154), TMEM120B (12 / 335), C9orf41 (13 / 799), FAM153A (15 / 522), TBC1D26 (17 / 136), BCO1 (18 / 764), RB1 (19 / 541), GLB1 (20 / 428), OR5D16 (21 / 321), SPPL3 (22 / 371), MLEC (23 / 1220), ATP8B4 (24 / 822), ARHGAP5 (25 / 134)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): TXNL4B (5 / 13860), NSMCE2 (6 / 978), SBDS (7 / 3199), PCBP1 (8 / 512), PHAX (9 / 18282), POLR3A (12 / 11888), NAPG (13 / 621), ECD (14 / 15596), UBA1 (16 / 5555), PCNA (18 / 4613), POLE (20 / 16378), SNRPF (21 / 14759), COPA (22 / 2525), MVK (23 / 3810), CDK9 (24 / 490), NFATC2IP (25 / 4900), GTF3C4 (26 / 1270), NOP58 (27 / 11880), STX4 (28 / 667), NSMCE4A (29 / 473)

## BARCS calls

Genes at FDR 0.05: 370; at FDR 0.10: 516. Top 15: PTEN, UBE2K, ARIH2, TOPORS, SIRT6, UBAP2L, TMEM215, GLRX, GCM2, TMEM168, BRAP, TMEM120B, C9orf41, PPP1R15A, FAM153A
