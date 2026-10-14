# GSE278336 reanalysis with BARCS 0.2.3

**Paper.** "dHyperCas12a enables multiplexed CRISPRi screens", *Nature Communications* 2026, PMID 41673027 (PMC13004945, doi 10.1038/s41467-026-69090-z).

**Screen.** Low-MOI fitness screen in A549 cells with four-crRNA pre-crRNA arrays: 171 arrays for 145 core-essential gene promoters, cell-surface control arrays, 50 non-targeting (NT) and 25 intergenic (NEG) arrays, plus synthetic-lethal combination arrays (894 arrays in all). Four repressors (dHyperLbCas12a-KRAB, dHyperLbCas12a-4xSID, dEnAsCas12a-KRAB, dEnAsCas12a-4xSID), three independent transductions each, sampled at days 5, 7, 14 and 21. The PER1 sort screen in the same series was not analyzed.

**Counts.** GEO deposits one `samtools idxstats` file per sample. `prepare.R` downloads the 54 fitness-screen files (48 screen samples, 6 plasmid), takes column 3 (mapped reads) per array and drops the `*` row. The result is identical to the paper's raw counts (Supplementary Data 1, "Lb Raw Counts" and "As Raw Counts", all 894 arrays and 24 columns each). Gene labels follow the paper's MAGeCK gene names (single-target combination arrays X-k-NT / NT-X-k pooled under X; double-target arrays under the sorted gene pair).

**Paper's analysis.** DESeq2 per repressor with days in culture as a continuous variable (LRT), and MAGeCK MLE over the time course (Wald FDR < 0.05): 31 depleted genes for dHyperLbCas12a-KRAB, 5 for -4xSID, 1 for dEnAsCas12a-KRAB, 0 for dEnAsCas12a-4xSID. The conclusion is that dHyperLbCas12a-KRAB is the only repressor suitable for low-MOI screens.

**Design.** Day 21 vs day 5 per repressor, paired by transduction (`~ replicate + day`), library totals, 3 vs 3 (2 residual df, dispersion moderated). Composition is unshifted (top 1% of arrays hold 2.2-2.6% of reads). Only 75 control arrays, so the control null (which needs 100) is not available. The raw control rate was 9-15% at p < 0.05 in all four screens, so BARCS calibrated to the controls (5.3% after), which shortens the lists.

## Results

| Repressor | Ctrl p<0.05 raw | FDR 0.10 depleted / enriched | Paper (MLE, Wald FDR 0.05, depleted) | Overlap of depleted |
|---|---|---|---|---|
| **dHyperLbCas12a-KRAB** (primary) | 12.0% | 28 / 18 | 33 (31 in the text) | 28 of 28 BARCS calls are paper calls |
| dHyperLbCas12a-4xSID | 9.3% | 3 / 0 | 8 (5 in the text) | 3 of 3 |
| dEnAsCas12a-KRAB | 14.7% | 4 / 4 | 7 (1 in the text) | 4 of 4 |
| dEnAsCas12a-4xSID | 12.0% | 0 / 0 | 0 | - |

(The paper column counts genes with negative beta and `wald` < 0.05 in Supplementary Data 1, Beta Scores; it includes the NT pseudo-gene, so it runs slightly above the counts in the text.)

- BARCS reproduces the repressor ranking exactly: KRAB on dHyperLbCas12a gives by far the most depleted essential genes, 4xSID and dEnAsCas12a-KRAB a handful, dEnAsCas12a-4xSID none.
- The paper's top depleted genes are BARCS's top calls: RPL34 #1, SMC2 #2, XPO1 #3, MDM4 #5, SNRPE #7, RPS20 #11 (ranks among depleted genes, by p). Every array behind them falls 2.5-3.7x in all three transductions (e.g. RPL34 8964/10579/14117 -> 2783/3719/3886); no jackpots in this high-coverage library (~10k reads per array).
- Paper-only depleted genes (Lb-KRAB): EIF3D, MCL1, RPL13A, RPL19 (and the NT pseudo-gene), which are near the threshold in both analyses.
- BARCS also calls 18 small enrichments for Lb-KRAB (effects of +0.07 to +0.28 log, e.g. NUF2, RPL26, PSMB3, the BCL2L2 and CHEK2-MTOR combination arrays, some olfactory-receptor control arrays). These are small and the controls themselves sit slightly below zero (median -0.03), so they are best read as mild composition effects of essential-array depletion rather than biology. The paper's table also lists BCL2L2 and CHEK2-MTOR as significant with positive beta.
- Published-table agreement over 198 shared genes: 93% effect-direction agreement; top-25 overlap 20/25. Spearman correlation of scores is low (0.17) because the published `wald` score is two-sided and mostly ties near 1 outside the hits.

## BARCS vs paper
Agree. BARCS calls a subset of the paper's depleted genes for every repressor (28/33, 3/8, 4/7, 0/0) with no BARCS-only depletion calls, and the top depleted genes coincide. The shorter BARCS lists come from control calibration (raw control rate 9-15%) and from using the day-21 vs day-5 endpoint instead of the full time course.

## Limits
Only 75 control arrays (no control null). The endpoint comparison discards days 7 and 14, which the paper's time-course models use. Gene units for the combination arrays follow the paper's MAGeCK labels.
