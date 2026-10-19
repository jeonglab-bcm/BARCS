# BARCS versus published results

BARCS genes: `results/GW_ACOC_lineage_vs_HSPC/genes.csv` (2945 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Runx1 | 1 | 2945 | -3.579 | 8.4e-108 | 2.5e-104 |
| Gata3 | 287 | 2945 | 6.704 | 0.6 | 1 |
| Cic | 376 | 2945 | 8.169 | 0.7 | 1 |

## Agreement with the published table

Published: `paper/castle_gw.tsv` (score `score`, higher is stronger); 21821 genes, 2934 shared with BARCS.

Spearman correlation of gene scores: **0.21**


Effect direction agreement: 30.9% of 2934 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 9 | 0.22 | 16 | 16 |
| 50 | 13 | 0.15 | 37 | 37 |
| 100 | 25 | 0.14 | 75 | 75 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Tspyl2 (2 / 1054), Nfkbib (4 / 2351), Snw1 (7 / 653), Cables2 (8 / 805), Tst (10 / 2072), Psmc1 (13 / 1019), Epas1 (14 / 2270), Aldob (15 / 1885), Wiz (16 / 1816), Cd19 (17 / 509), Mettl7b (19 / 1288), Tpd52l1 (20 / 1859), Igf2r (21 / 3988), Vil1 (22 / 2352), Unc119 (24 / 3088), Cbfb (25 / 1983)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Jmjd7 (15 / 1657), Dynlt1b (43 / 2369), Bod1 (57 / 735), Ddx54 (75 / 37), Pla2g5 (99 / 500), Fiz1 (115 / 281), Ugt1a1 (130 / 2891), Ugt1a2 (143 / 269), Dkk1 (157 / 59), Ptprt (160 / 1810), Tgfbr1 (161 / 248), Tsta3 (183 / 219), Npy (187 / 189), Tpm3 (196 / 149), Agr2 (233 / 156), Dcx (252 / 562)

## BARCS calls

Genes at FDR 0.05: 11; at FDR 0.10: 14. Top 15: Runx1, Tspyl2, Ccnt1, Nfkbib, Ep300, Gja1, Snw1, Cables2, Specc1, Tst, Usf2, BC052040, Psmc1, Epas1, Aldob
