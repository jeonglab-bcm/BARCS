# BARCS versus published results

BARCS genes: `results/SEM_Cas9_day14_vs_day0/genes.csv` (248 genes, direction: depleted)

## Genes the paper highlights

| Gene | BARCS rank | of | Effect | p | FDR |
|---|---|---|---|---|---|
| RPS19-sgRNA-design_cli | 1 | 248 | -2.374 | 6.1e-238 | 1.5e-235 |
| chr13:28842907-28843340(.)::npk3::pkscore157:PAN3 | 2 | 248 | -0.822 | 1.3e-45 | 1.6e-43 |
| chr13:28819406-28820051(.)::npk3::pkscore264:PAN3 | 4 | 248 | -0.400 | 1.3e-24 | 7.8e-23 |
| chr7:92384146-92384756(.)::npk3::pkscore178:CDK6 | 219 | 248 | 0.045 | 0.0023 | 0.011 |
| chr21:36247065-36247353(.)::npk2::pkscore95:RUNX1 | 24 | 248 | -0.084 | 0.0034 | 0.014 |
| chr14:24583753-24584104(.)::npk3::pkscore221:DCAF11 | 23 | 248 | -0.018 | 0.0029 | 0.013 |
| chr8:22832812-22833132(.)::npk2::pkscore134:PEBP4 | 8 | 248 | -0.123 | 1.6e-10 | 4.9e-09 |
| chr11:67797980-67798220(.)::npk2::pkscore68:NDUFS8 | 19 | 248 | -0.094 | 0.0012 | 0.0069 |
| chr9:37324704-37325208(.)::npk3::pkscore465:ZCCHC7 | 11 | 248 | -0.114 | 1.6e-07 | 3.5e-06 |
| chr1:26097697-26098053(.)::npk2::pkscore114:MAN1C1 | 89 | 248 | 0.025 | 0.91 | 0.94 |

## Agreement with the published table

Published: `paper/SEM_Cas9_day14_mageck.tsv` (score `neg|rank`, lower is stronger); 249 genes, 248 shared with BARCS.

Spearman correlation of gene scores: **0.76**


Effect direction agreement: 83.1% of 248 genes


| Top N | Shared | Jaccard | BARCS only | Published only |
|---|---|---|---|---|
| 10 | 9 | 0.82 | 1 | 1 |
| 25 | 22 | 0.79 | 3 | 3 |
| 50 | 38 | 0.61 | 12 | 12 |

### In the BARCS top 10 but not the published top 10

Gene (BARCS rank / published rank): chr19:16477848-16478351(.)::npk3::pkscore133:EPS15L1 (10 / 14)

### In the published top 10 but not the BARCS top 10

Gene (published rank / BARCS rank): chr10:1166923-1167369(.)::npk2::pkscore89:WDR37 (9 / 16)

## BARCS calls

Genes at FDR 0.05: 84; at FDR 0.10: 100. Top 15: RPS19-sgRNA-design_cli, chr13:28842907-28843340(.)::npk3::pkscore157:PAN3, chrM:2957-3621(.)::npk3::pkscore140, chr13:28819406-28820051(.)::npk3::pkscore264:PAN3, chrM:15876-16458(.)::npk3::pkscore449, chr16:22200786-22201103(.)::npk2::pkscore123:SDR42E2, chr13:23025165-23025837(.)::npk2::pkscore69, chr8:22832812-22833132(.)::npk2::pkscore134:PEBP4, hg38chrM:15876-16458(.)::npk3::pkscore449, chr19:16477848-16478351(.)::npk3::pkscore133:EPS15L1, chr9:37324704-37325208(.)::npk3::pkscore465:ZCCHC7, chr7:27205198-27205564(.)::npk2::pkscore110:HOXA9, chr1:32250493-32250900(.)::npk3::pkscore330, chr8:6669714-6669970(.)::npk2::pkscore63:XKR5, chr19:10870028-10870304(.)::npk2::pkscore74:DNM2
