# GSE245526 reanalysis with BARCS 0.2.3

**Paper.** "Replication competent HIV-guided CRISPR screen identifies antiviral factors including targets of the accessory protein Nef", *Nature Communications* 2024, PMID 38714682 (PMC11076291).

**Why it was excluded before.** Only MAGeCK-normalized, non-integer guide counts were deposited.

**Count recovery.** `GSE245526_Counts_NL4.3_in_CEMM7_N_1-3.xlsx` is raw reads times one constant per sample (MAGeCK median normalization, unrounded). x / s is an integer (within ~1e-9) for 100.0% of positive values in every analyzed column (v_min lands at a small integer multiple of the read scale, so the accepted k ranges from 1 to a few hundred; e.g. the three inputs recover at k=4/8/221). Recovered integers in `recovered_counts.tsv`; analyzed library totals 4.6-11.9 M reads.

**Screen.** Replication-competent HIV library of 1,533 guides targeting ~511 host genes (plus NT controls), passaged in CEM-M7 cells; the virus itself carries the guide, so antiviral-factor guides enrich over passaging. Reproduced the deposited "15 dpi untreated vs input, N 1-3" comparison: three independent infections (n=1,2,3), each with its own virus-stock input.

**Design.** `~ replicate + condition`, 15 dpi vs input, 6 libraries, 2 residual df. NT (11 guides) as controls. Direction of interest is enrichment.

**Composition.** The 15 dpi libraries concentrate reads on surviving guides (top 1% hold 20-24% of reads vs ~5% at input), so library-total normalization over-calls depletion. Reported numbers use median-ratio totals (the correct read for a strong-enrichment screen); enrichment is the paper's direction.

## Results (median-ratio totals)
- 269 genes at FDR 0.10 (165 enriched, 104 depleted); guide correlation ~0.
- Every antiviral factor the abstract names as enriched >50-fold is recovered among enriched genes: **EHMT2 #1** (FDR 4e-10), **CEACAM3 #8** (FDR 1e-7), **CC2D1B #15** (FDR 4e-7), **CIITA #91** (FDR 8e-3), **GRN #96** (FDR 9e-3), **RHOA #109** (FDR 2e-2).

## BARCS vs paper
Full agreement on the paper's named enrichment hits, with EHMT2 as the single strongest. IFI16 (reported only for the Nef-deleted virus arm) is not expected in this untreated comparison and was not tested here. The paper used MAGeCK on the passaging enrichment; BARCS reaches the same lead genes once the composition shift is handled with median-ratio totals.

## Limits
Small, targeted library (1,533 guides). Depletion calls are unreliable under the strong enrichment; the enriched direction is interpretable. Only the untreated CEM-M7 arm was reanalyzed.
