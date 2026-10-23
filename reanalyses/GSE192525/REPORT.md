# GSE192525 reanalysis with BARCS 0.2.3

**Paper.** Llanos et al., "Genome wide CRISPR/Cas9 screen identifies the coagulation factor IX (F9) as a regulator of senescence", Cell Death & Disease (2022), PMID 35184131, doi:10.1038/s41419-022-04569-3 (PMC8858321).

**Screen.** Genome-wide GeCKO knockout library (about 101,000 guides, no non-targeting controls) in MCF7 breast cancer cells treated for two weeks with the CDK4/6 inhibitor palbociclib or DMSO, two replicates each. Knockouts that escape the palbociclib-induced arrest are enriched. GEO deposits only an unrounded "transformed RPKM" table; prepare.R recovers integer reads (subtract the 0.001 pseudocount, then one scale per column; 99.5-99.8% of values become integers, the remaining 0.2-0.5% are left rounded, so the recovery is close but not perfectly exact; scales in recovery_scales.json). The authors called 18 genes with >2-fold enrichment in at least 3 guides and validated F9 and PROZ; the 18-gene list is only in a figure, so named genes are the comparison.

**Design.** `~ condition`, palbociclib vs DMSO, 2 vs 2, no pairing term (2 residual df). Composition is flat (top 1% of guides hold about 6% of reads).

**Checks.** No controls, so calibration and the control null could not be checked.

## Results

| | BARCS 0.2.3 | Authors |
|---|---|---|
| Genes at FDR 0.10 | 100 (42 enriched, 58 depleted) | 18 genes by fold-change rule |
| F9 | #2,243 enriched, estimate 0.89, p 0.17 | validated |
| PROZ | #6,782, p 0.72 | validated |
| Top BARCS enriched calls | NOTCH2, LSM7, NFE2L1, TMEM51 | not highlighted |

## Where BARCS agrees and differs

- **F9 and PROZ are not supported by the counts.** Of F9's six guides, two rise strongly in palbociclib (220 and 66 reads against 4 and 0 in DMSO), but two of the most abundant fall (726 vs 4,088 and 1,404) and one is absent. PROZ is similar: one guide rises from 16 to 762, others fall. A fold-change rule over 3 of 6 guides picks these genes up; a model that weighs all guides and replicate variation does not.
- **BARCS's own list** (NOTCH2, NFE2L1, LSM7) is not discussed in the paper. The validation of F9 rests on independent sgRNA, shRNA and recombinant-protein experiments, which this reanalysis does not test.

## Limits

- Counts were recovered from a transformed RPKM table (99.5%+ integer, not perfectly exact). No controls; 2 residual df.
