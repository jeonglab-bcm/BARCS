# GSE291529 reanalysis with BARCS 0.2.2

**Paper.** "Identification of Functional Genetic Components Modulating Toxicity Response to PFOS using Genome-wide CRISPR Screens in HepG2/C3A cells", bioRxiv 2025, PMID 41446233 (PMC12724516).

**Why it was excluded before.** Only MAGeCK median-normalized guide counts were deposited (Excel), not raw reads.

**Count recovery.** The deposited `*_sgRNAcount_normalized.xlsx` is raw reads times one constant per sample (MAGeCK median normalization, written unrounded). For every sample column, x / s is an integer (within 1e-9) for 100.0% of positive values at s = v_min (k = 1). Recovered integer counts in `recovered_counts.tsv` (per-column scale factors in `recovered_counts_scales.json`); library totals 8-42 M reads.

**Screen.** Genome-wide Brunello-style KO (18,819 genes, ~37.8k guides) in HepG2/C3A liver cells, control vs PFOS (192 uM, 10 doublings), 3 vs 3.

**Design.** `~ condition`, PFOS vs control, 6 libraries, 4 residual df. Non-targeting + safe-harbor guides (205) as controls; raw control p<0.05 rate 10.2%, calibrated to 4.9%.

## Results
- 0 genes at FDR 0.10 (model); 15 against the control null. Composition is clean (top 1% hold ~3% of reads), guide correlation 0.
- The two validated resistance genes: **SLC6A9 ranks #9 among enriched genes** (estimate +0.91, empirical FDR 0.13, just outside 0.10); **CPSF2** is weak (enriched rank ~1327; one of its two guides has near-zero counts).

## BARCS vs paper
The paper called 340 candidate genes (189 sensitizers, 151 resistance) at a permissive MAGeCK threshold and individually validated SLC6A9 and CPSF2 as resistance genes. BARCS, with replicate-aware dispersion and control calibration, is far more conservative: no gene reaches FDR 0.10. SLC6A9 sits near the top of the enriched list (a near miss), CPSF2 does not. BARCS does not reproduce a 340-gene hit list from 3 vs 3 libraries.

## Limits
Plasmid/T0 column named in the sheet was not deposited, so this is endpoint-vs-control only. Agreement: partial (SLC6A9 recovered among top enriched, CPSF2 not; no gene passes FDR 0.10).
