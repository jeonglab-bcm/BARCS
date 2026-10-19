# BARCS versus published results

BARCS genes: `results/GW_DTKP_lineage_vs_HSPC/genes.csv` (1982 genes, direction: both)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Tada1 | 683 | 1982 | -1.678 | 0.62 | 1 |

## Agreement with the published table

Published: `paper/castle_gw.tsv` (score `score`, higher is stronger); 21821 genes, 1982 shared with BARCS.

Spearman correlation of gene scores: **-0.14**


Effect direction agreement: 29.4% of 1982 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 25 | 1 | 0.02 | 24 | 24 |
| 50 | 2 | 0.02 | 48 | 48 |
| 100 | 5 | 0.03 | 95 | 95 |

### In the BARCS top 25 but not the published top 25

Gene (BARCS rank / published rank): Slc25a13 (1 / 1754), Alas2 (2 / 5612), Ptdss2 (3 / 4895), Commd8 (4 / 4639), Piga (5 / 3428), Glra3 (6 / 1700), Slc1a4 (8 / 4097), Uck2 (9 / 6482), Cd4 (10 / 6091), Cox7b (11 / 4556), Ak2 (12 / 3498), Aldh4a1 (13 / 15159), Mylk4 (14 / 3694), Scn2b (15 / 5322), Psph (16 / 8365), Map3k9 (17 / 16567), Pars2 (18 / 3104), Slc6a8 (19 / 1091), Prlr (20 / 12339), Ppm1f (21 / 4660), Gstk1 (22 / 9084), Slc16a5 (23 / 4942), Hexb (24 / 5951), Drd2 (25 / 16698)

### In the published top 25 but not the BARCS top 25

Gene (published rank / BARCS rank): Tada1 (35 / 683), Dolpp1 (55 / 93), Cmas (86 / 1703), Bpi (105 / 1073), Pfas (117 / 1781), Ms4a2 (146 / 1814), Cyp4a32 (148 / 1722), Gucy2c (159 / 30), Gale (195 / 1696), Fam21 (227 / 1970), Vps25 (294 / 1605), Psap (310 / 1715), Gria1 (311 / 653), Ppp2r2a (313 / 1584), Trrap (382 / 166), Gad1 (430 / 352), Agpat3 (433 / 1760), Ndufa11 (437 / 1371), Gldc (450 / 998), Sec14l2 (457 / 1015), Hk1 (461 / 1295), Rpl23 (467 / 937), Mapkap1 (472 / 630), B4galt1 (483 / 1775)

## BARCS calls

Genes at FDR 0.05: 4; at FDR 0.10: 7. Top 15: Slc25a13, Alas2, Ptdss2, Commd8, Piga, Glra3, Ly96, Slc1a4, Uck2, Cd4, Cox7b, Ak2, Aldh4a1, Mylk4, Scn2b
