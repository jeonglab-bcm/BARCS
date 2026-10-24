# GSE169111 reanalysis with BARCS 0.2.3

**Paper.** Sun et al., "Genome-scale CRISPR screen identifies TMEM41B as a multi-function host factor required for coronavirus replication", *PLoS Pathogens* (2021), PMID 34871328, doi:10.1371/journal.ppat.1010113 (PMC8675922).

**Screen.** Porcine genome-scale knockout library (PigGeCKO, about 53,000 guides, no non-targeting controls) in PK-15-Cas9 cells challenged with the alpha-coronavirus TGEV at MOI 0.001. Surviving cells were collected and re-challenged for three rounds; guides enriched in survivors mark host factors whose loss confers resistance. GEO holds one library per sample (control and rounds 1-3), each with two integer read columns that agree at the Poisson level (ratio 1.005, dispersion index 0.94 in the control); `prepare.R` sums them. The authors ran MAGeCK and took the top 0.5% of sgRNAs per round; ANPEP (the known TGEV receptor) and TMEM41B were the headline genes.

**Design.** Each round compared with the control library, `~ condition`, 1 vs 1. No residual df, so `run_barcs.R` used the no-replicate path; with too few controls (none non-targeting) the overdispersion is pooled over all guides and is very conservative. Selection is extreme (80-88% of guides at zero after challenge, and a single ANPEP guide holds about a quarter of a selected library), so totals are median-ratio size factors and only enrichment is read; `run_barcs.R` reports the median-ratio totals as capped for TGEV1 (single guides hold most of the library), so depletion is uninterpretable. The calls are screening-level.

**Checks.** No controls, so calibration and the control null could not be checked. Control and selected libraries correlate at Spearman 0.28-0.37.

## Results

| | BARCS 0.2.3 (round 3 vs control) | Authors (MAGeCK, top 0.5% sgRNAs) |
|---|---|---|
| Genes at FDR 0.10 | 0 (conservative pooled dispersion, 1 library per round) | top 0.5% sgRNAs taken as candidates |
| TMEM41B | #3 of 14,582 by enrichment (estimate 6.1, all 6 guides up) | headline hit |
| ANPEP (TGEV receptor) | #3 in round 1, #87 in round 3 (only 2 guides pass the filter there) | known receptor, enriched every round |

## Where BARCS agrees and differs

- **Agrees on ranking.** TMEM41B is the #3 enriched gene in round 3 and ANPEP the #3 in round 1, both with all guides moving up, so BARCS puts the paper's two headline genes at the very top of the enrichment list.
- **Differs on calling.** With one library per round and no non-targeting controls, the pooled overdispersion is large and no gene reaches FDR 0.10. The paper did not use an FDR either; it took the top 0.5% of guides. So the two methods agree on which genes stand out but BARCS cannot certify them from this design. The companion focused library (GSE169108) does confirm them at FDR 0.10.

## Limits

- One library per round, sequential selections of one population (not replicates), no controls; the calls are screening-level and only enrichment is interpretable.
