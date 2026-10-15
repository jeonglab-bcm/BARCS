# GSE273299 reanalysis with BARCS 0.2.3

**Paper.** "IL-4 drives exhaustion of CD8+ CART cells", *Nature Communications* 2024, PMID 39266501 (PMC11393358).

**Screen.** Genome-wide GeCKO v2 library A knockout screen (63,950 guides, 1,000 non-targeting) in CART19-28z cells from three healthy donors, chronically stimulated with JeKo-1 cells. Libraries at day 8 (baseline) and day 22 (exhausted) for each donor (GSM8425869-74).

**Counts.** GEO holds only the MAGeCK-normalized table (`GSE273299_all.count_normalized.txt.gz`). It is raw reads times one constant per library: dividing by the smallest value gives integers for 100% of entries in every column (scales 0.79-1.21; raw totals 27.6-41.1 M reads). `prepare.R` rebuilds `recovered_counts.tsv` with `tools/screen-reanalysis/recover_counts.R` and checks it against `recovery_scales.json`.

**Mapping.** Columns C384K122LA*, C385K122LA*, C386K122LA* are donors 1-3 (GSM descriptions C384K122_Day8 etc.); suffix D8/D22 is the time point. Certain.

**Design.** `~ donor + condition`, day 22 vs day 8 paired by donor, 6 libraries, 2 residual df. Library sizes come from the 1,000 non-targeting guides (`"totals": "control"`), as the paper normalized to them in MAGeCK-VISPR MLE. Read direction: enriched at day 22 = knockouts that resist exhaustion.

## Results

- 215 genes at FDR 0.10 (22 enriched, 193 depleted); 306 against the control null.
- Calibration: 4.6% of non-targeting guides at p < 0.05 (no recalibration needed); guide correlation 0.003; moderation applied (prior df infinite); 91 guides tested by likelihood ratio.
- Composition normal (top 1% of guides hold 4-5% of reads in every library).
- Control null: centred on the controls; targeting guides sit -0.23 z from the controls, and the control-null count (306) exceeds the model's (215), so the control-null number overstates the hits; quote the model count.
- Depleted calls are dominated by ribosomal and translation genes (RPL3, RPL34, POP5, PSMG4), the expected essential-gene signal the paper also reports.

## BARCS vs paper

The paper ran MAGeCK-VISPR MLE (no gene table deposited or in the supplement) and names CSF2, SOCS1 and PTPN2 as top positively selected genes, then reports that 2 of 3 IL4 guides rose from day 8 to day 22.

| Gene | BARCS rank (enriched) | Effect (log) | FDR |
|---|---|---|---|
| PTPN2 | 2 | +0.72 | 1.1e-07 |
| SOCS1 | 5 | +0.94 | 0.0026 |
| CSF2 | 1 | +0.18 | 3.1e-18 |
| IL4 | 1916 / 20667 | +0.36 | 0.77 |

- **PTPN2 and SOCS1** are clear, consistent hits (most guide-donor pairs rise).
- **CSF2** ranks first only because of a jackpot: one guide in donor 3 goes from 420 to 42,388 reads while the other eight guide-donor pairs fall or barely move. Its small estimate (+0.18) shows this; discount it.
- **IL4**, the gene the paper is about, is not called. Its guides rise in donors 1 and 2 but fall in donor 3 (HGLibA_23166: 803->1190, 689->1563, 791->500), and IL4R and STAT6 are not enriched either. The paper's IL-4 claim rests on pathway analysis of the screen plus RNA/ATAC-seq and functional work, not on a gene-level screen hit, and BARCS agrees that the screen alone does not single out IL4.
- Other enriched genes held up by one or two guide-donor pairs (CCNC, UBE2L3, CASP3, DRG1) are weak.

## Limits

Three donors give 2 residual df; the IL4 signal varies between donors, which a replicate-aware model shows directly. Counts were recovered from a normalized table (exact). No published gene-level table, so only the named genes can be compared.
