# BARCS versus published results

BARCS genes: `results/WT_vs_Mir139KO_d14/genes.csv` (21598 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| Polr2m | 1163 | 21598 | -3.522 | 0.18 | 1 |

## Agreement with the published table

Published: `paper/per_gene.tsv` (score `pvalue`, lower is stronger); 21705 genes, 21569 shared with BARCS.

Spearman correlation of gene scores: **0.00**


Effect direction agreement: 78.9% of 21569 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 16 | 0 | 0.00 | 16 | 16 |
| 50 | 0 | 0.00 | 50 | 50 |
| 100 | 0 | 0.00 | 100 | 100 |
| 200 | 2 | 0.01 | 198 | 198 |

### In the BARCS top 16 but not the published top 16

Gene (BARCS rank / published rank): mmu-mir-6990 (1 / 624), Coq2 (2 / 4394), Echs1 (3 / 1884), Efr3a (4 / 6507), C87977 (5 / 229), Bbc3 (6 / 4313), Pdss2 (7 / 2461), Ndufaf6 (8 / 1663), Zbtb11 (9 / 2806), Lyn (10 / 1400), Rnf7 (11 / 9865), Chfr (12 / 6493), Olfr1392 (13 / 6260), Serpinb9d (14 / 13247), Pten (15 / 3235), Slc22a23 (16 / 8339)

### In the published top 16 but not the BARCS top 16

Gene (published rank / BARCS rank): Cul4b (1 / 6334), mmu-mir-92b (2 / 6512), Clip1 (3 / 4531), 2310036O22Rik (4 / 6873), Adat2 (5 / 6887), Rpl14 (6 / 6898), Arl14 (7 / 7423), Tpi1 (8 / 14461), Psmb3 (9 / 5093), Gm2696 (10 / 7129), mmu-mir-376b (11 / 7130), mmu-mir-382 (12 / 16845), Cited2 (13 / 7185), Zfp148 (14 / 5261), Rps15a (15 / 14246), mmu-mir-5101 (16 / 14306)

## BARCS calls

Genes at FDR 0.05: 7; at FDR 0.10: 8. Top 15: mmu-mir-6990, Coq2, Echs1, Efr3a, C87977, Bbc3, Pdss2, Ndufaf6, Zbtb11, Lyn, Rnf7, Chfr, Olfr1392, Serpinb9d, Pten
