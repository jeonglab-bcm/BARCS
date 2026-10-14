# BARCS versus published results

BARCS genes: `results/early_vs_nonplur/genes.csv` (18358 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Smad2 | 2790 | 18358 | -0.989 | 0.3 | 1 |
| Smad4 | 605 | 18358 | -1.720 | 0.073 | 1 |
| Pou5f1 | 1838 | 18358 | -1.835 | 0.21 | 1 |
| Sox2 | 4212 | 18358 | -1.576 | 0.42 | 1 |
| Smarcc2 | 13101 | 18358 | 0.060 | 0.9 | 1 |
| Smarca4 | 4469 | 18358 | -1.216 | 0.44 | 1 |
| Hes1 | 5020 | 18358 | -0.818 | 0.48 | 1 |
| Fut9 | 573 | 18358 | -3.036 | 0.069 | 1 |

## Agreement with the published table

Published: `paper/tableS1.xlsx` (score `neg|score`, lower is stronger); 18380 genes, 18358 shared with BARCS.

Spearman correlation of gene scores: **0.51**


Effect direction agreement: 82.0% of 18358 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 50 | 1 | 0.01 | 49 | 49 |
| 100 | 4 | 0.02 | 96 | 96 |
| 250 | 22 | 0.05 | 228 | 228 |

### In the BARCS top 50 but not the published top 50

Gene (BARCS rank / published rank): Nf2 (1 / 3362), Agfg1 (2 / 5201), Mcee (3 / 10003), Glis1 (4 / 5212), Ccdc7 (5 / 2859), Pld2 (6 / 5024), Gm2a (7 / 2321), Tprgl (8 / 5328), Trim32 (9 / 13322), Pde6c (10 / 16252), Cldn10 (11 / 13380), Bcas1 (12 / 7248), Zc3h12d (13 / 623), Pex7 (14 / 13331), Setd6 (15 / 4691), Nin (16 / 1057), Clpsl2 (17 / 2904), Fam184b (18 / 5290), Gna13 (19 / 740), Gm7714 (20 / 3990), Scn2b (21 / 924), Eps8l3 (22 / 2034), Zcchc5 (23 / 17294), Abca1 (24 / 16570), Vil1 (25 / 944)

### In the published top 50 but not the BARCS top 50

Gene (published rank / BARCS rank): Fut9 (1 / 573), Psmb7 (2 / 3227), Gmds (3 / 788), Dhx35 (4 / 3433), Hgd (5 / 6286), Sfrp5 (6 / 1455), Myef2 (7 / 10594), Dynap (8 / 5190), Ube2m (9 / 1398), Ccl28 (10 / 14795), Tsta3 (11 / 152), Vmp1 (12 / 10707), Apod (13 / 2390), Polrmt (14 / 2460), Slc35c1 (15 / 69), Cenpa (16 / 9391), Pou5f1 (17 / 1838), Pqbp1 (18 / 519), Gdpd4 (20 / 5131), Cer1 (21 / 130), Utp11l (22 / 7157), Sfi1 (23 / 2590), Ddx5 (24 / 6138), Ptprn (25 / 3390), Slc35a2 (26 / 1262)

## BARCS calls

Genes at FDR 0.05: 56; at FDR 0.10: 73. Top 15: Nf2, Agfg1, Mcee, Glis1, Ccdc7, Pld2, Gm2a, Tprgl, Trim32, Pde6c, Cldn10, Bcas1, Zc3h12d, Pex7, Setd6
