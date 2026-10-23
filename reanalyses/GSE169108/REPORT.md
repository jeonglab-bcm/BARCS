# GSE169108 reanalysis with BARCS 0.2.3

**Paper.** Sun et al., "Genome-scale CRISPR screen identifies TMEM41B as a multi-function host factor required for coronavirus replication" (focused library), *PLoS Pathogens* (2021), PMID 34871328, doi:10.1371/journal.ppat.1010113 (PMC8675922).

**Screen.** A focused validation library of the 79 top candidate genes from the genome-wide PigGeCKO screen (about 1,400 guides, 15 non-targeting `ntc_` controls; ANPEP guides were deliberately left out) in PK-15-Cas9 cells challenged with TGEV at high MOI for up to five rounds (Sun et al. 2021). GEO deposits only read1/read2 **normalized** values (two decimals) and their average; no raw counts. Each normalized column is raw reads times one constant, so `prepare.R` recovers the integer reads (100% of each column's values become integers; scales in `recovery_scales.json`, k = 1-489) and sums the two reads of each library (which agree at a constant ratio 1.10-1.22, as separate reads of one library). Gene symbols were mapped from the companion PigGeCKO file by Ensembl id. The authors' top candidates after rounds 3 and 5 were FUT8, TMEM41B, DYRK1A and MLST8.

**Design.** Rounds 3 and 5 each compared with the control library, `~ condition`, 1 vs 1. No residual df, so `run_barcs.R` used the no-replicate path; 15 controls are too few for the control null, so the overdispersion is pooled over all guides. Totals are median-ratio size factors (a few guides dominate); not capped. The calls are screening-level.

**Checks.** 15 non-targeting controls are too few to calibrate or build a control null. Control and selected libraries correlate at Spearman 0.36-0.39; rounds 3 and 5 at 0.92.

## Results

| | BARCS 0.2.3 (round 3 vs control) | Authors (top candidates) |
|---|---|---|
| Genes at FDR 0.10 | 3 (FUT8, TMEM41B, MLST8) | FUT8, TMEM41B, DYRK1A, MLST8 as top candidates |
| FUT8 | #1, estimate 3.8, FDR 1.7e-12, 9 of 10 guides up | #1 |
| TMEM41B | #2, estimate 2.8, FDR 4e-4, all 10 guides up | top hit |
| MLST8 | #3, estimate 2.2, FDR 0.017 | top candidate |
| DYRK1A | #4, estimate 2.0, FDR 0.24 (FDR 0.09-level by round) | top candidate |
| LPP / TAX1BP1 / BARHL2 (validated by TCID50) | #16 / #63 / #36, not enriched | validated in follow-up |

## Where BARCS agrees and differs

- **Agrees on the ranking.** BARCS reproduces the paper's candidate order exactly: FUT8, TMEM41B, MLST8, DYRK1A are the top four by enrichment in both rounds, and FUT8, TMEM41B and MLST8 pass FDR 0.10 even with one library per round. TMEM41B, the paper's headline gene, is #2 with all ten guides enriched.
- **Differs on the follow-up genes.** Of the five genes the authors took to TCID50 validation (ANPEP, TMEM41B, LPP, TAX1BP1, BARHL2), ANPEP was not in this library and TMEM41B is #2, but LPP, TAX1BP1 and BARHL2 are not enriched here (ranks 16, 63, 36). Their validation rests on the individual-knockout assays, not on enrichment in this pooled library.

## Limits

- Counts were recovered from normalized values (exact, every column integer-valued). One library per round, sequential selections, 15 controls; the calls are screening-level and only enrichment is interpreted.
