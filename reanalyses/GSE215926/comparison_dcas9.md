# BARCS versus published results

BARCS genes: `results/SEM_dCas9KRAB_day14_vs_day0/genes.csv` (248 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| RPS19-sgRNA-design_cli | 6 | 248 | -0.028 | 4.9e-06 | 0.00017 |
| chr13:28842907-28843340(.)::npk3::pkscore157:PAN3 | 2 | 248 | -0.488 | 3.2e-30 | 4e-28 |
| chr13:28819406-28820051(.)::npk3::pkscore264:PAN3 | 244 | 248 | 0.105 | 2.4e-05 | 0.00049 |
| chr7:92384146-92384756(.)::npk3::pkscore178:CDK6 | 1 | 248 | -0.213 | 4.4e-45 | 1.1e-42 |
| chr21:36247065-36247353(.)::npk2::pkscore95:RUNX1 | 5 | 248 | -0.114 | 7.3e-10 | 3.6e-08 |
| chr14:24583753-24584104(.)::npk3::pkscore221:DCAF11 | 7 | 248 | -0.024 | 1.3e-05 | 0.00032 |
| chr8:22832812-22833132(.)::npk2::pkscore134:PEBP4 | 81 | 248 | 0.025 | 0.76 | 0.87 |
| chr11:67797980-67798220(.)::npk2::pkscore68:NDUFS8 | 4 | 248 | -0.173 | 3.7e-21 | 2.3e-19 |
| chr9:37324704-37325208(.)::npk3::pkscore465:ZCCHC7 | 186 | 248 | 0.050 | 0.061 | 0.21 |
| chr1:26097697-26098053(.)::npk2::pkscore114:MAN1C1 | 12 | 248 | -0.014 | 0.072 | 0.23 |

## Agreement with the published table

Published: `paper/SEM_dCas9KRAB_day14_mageck.tsv` (score `neg|rank`, lower is stronger); 249 genes, 248 shared with BARCS.

Spearman correlation of gene scores: **0.67**


Effect direction agreement: 71.4% of 248 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 8 | 0.67 | 2 | 2 |
| 25 | 15 | 0.43 | 10 | 10 |
| 50 | 29 | 0.41 | 21 | 21 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): chr13:30945870-30946121(.)::npk3::pkscore65:LINC00426 (9 / 32), chr11:122542274-122542642(.)::npk3::pkscore92:UBASH3B (10 / 11)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): chrX:131614759-131615090(.)::npk2::pkscore58:MBNL3 (7 / 180), chr20:39554596-39555053(.)::npk2::pkscore84 (9 / 170)

## BARCS calls

Genes at FDR 0.05: 27; at FDR 0.10: 48. Top 15: chr7:92384146-92384756(.)::npk3::pkscore178:CDK6, chr13:28842907-28843340(.)::npk3::pkscore157:PAN3, chr6:135601986-135602494(.)::npk3::pkscore74, chr11:67797980-67798220(.)::npk2::pkscore68:NDUFS8, chr21:36247065-36247353(.)::npk2::pkscore95:RUNX1, RPS19-sgRNA-design_cli, chr14:24583753-24584104(.)::npk3::pkscore221:DCAF11, chr1:32250493-32250900(.)::npk3::pkscore330, chr13:30945870-30946121(.)::npk3::pkscore65:LINC00426, chr11:122542274-122542642(.)::npk3::pkscore92:UBASH3B, chr16:77713713-77714007(.)::npk3::pkscore99, chr1:26097697-26098053(.)::npk2::pkscore114:MAN1C1, chr20:35603369-35603734(.)::npk2::pkscore93, chr8:66922210-66922545(.)::npk2::pkscore82, chrM:176-598(.)::npk3::pkscore244
