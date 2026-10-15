# GSE219136 reanalysis with BARCS 0.2.3

**Paper.** "G6PD and ACSL3 are synthetic lethal partners of NF2 in Schwann cells", *Nat Commun* 2024, PMID 38879607 (PMC11180199, doi:10.1038/s41467-024-49298-7).

**Screen.** TKOv3 genome-wide KO library (~90k guides) in human Schwann cells (ipn02.3 2λ), NF2-WT and NF2-KO#1, passage 0 (one library each) and passage 7 (two replicates each). Controls: 142 non-cutting EGFP/LacZ/luciferase guides (plus 1,380 chr10 cutting-control guides, analysed as genes).

**Counts.** `GSE219136_NF2-CRISPR-screen.txt.gz` holds raw counts, normalized counts, ratios and a log2FC difference side by side under a two-line header. `prepare.R` keeps sgRNA, gene and the six raw-count columns (WT_T0, KO_T0, WT_T7_R1/R2, KO_T7_R1/R2; names match the GSM titles) and drops a trailing "total" row. 91,320 guides, 33-45 M reads per library.

**Design.** The paper ranks genes by the difference between NF2-KO and NF2-WT in log2(passage 7 / passage 0) (Fig. 1F-G), then keeps genes that are neutral or mildly negative in WT. BARCS main analysis: `~ genotype * time`, term `genotypeKO:timeT7` (6 libraries, 2 residual df, moderated, prior df 35), depletion = synthetic lethal with NF2 loss. Replicates are not stated to be paired across genotypes, so no replicate term. Sensitivity analysis: KO vs WT at passage 7 only (2 vs 2).

**Checks.** Composition normal (top 1% of guides hold 3.6-5.6% of reads). Control calibration applied: 18.3% of control guides at p < 0.05 before (34.5% in the passage-7-only contrast), 4.9% after; control shift ~0, so the control null is centred on the controls. Guide correlation 0. ACSL3 and G6PD are depleted in KO on all their guides (no jackpots).

## Results
- **Interaction (main):** 314 genes at FDR 0.10 (361 against the control null; 122 depleted, 192 enriched).
- **ACSL3**: rank 34 among depleted genes, estimate -1.30, FDR 1.2e-4 (control-null FDR 0.0024).
- **G6PD**: rank 100, estimate -1.57, FDR 0.054 (control-null FDR 0.026).
- KO vs WT at passage 7: 655 genes at FDR 0.10 (419 against the control null); ACSL3 FDR 7e-4, G6PD FDR 0.002.
- The strongest depleted interaction terms are CUL3, PDCD10, TSC1, KEAP1, NF2, TAOK1, CAND1, TSC2: genes whose loss makes NF2-WT cells overgrow (contact-inhibition and Hippo-pathway suppressors), an effect blunted in NF2-KO cells. The paper reports this pattern (Fig. 1F) and excluded such genes on purpose, because they would be tumor suppressors. BARCS's interaction ranks them first because they have the largest KO-minus-WT difference. ACSL3 and G6PD are the strongest depleted genes that are not of that type.

## BARCS vs paper
Agreement: both named synthetic-lethal partners pass FDR 0.10 in the interaction model and in the control null. The paper gave no gene-level table (Fig. 1G is a ranked bar chart; the Source Data only list guide log2FCs for NF2, G6PD and ACSL3), so the comparison is to the named hits only. The paper's ranking is a guide-averaged difference in log2FC with no test. BARCS adds a model with replicate variance, calibrated to the non-cutting controls and the interaction tests each guide's change from its own genotype's passage 0 library; G6PD is weaker there (FDR 0.054) than ACSL3.

## Limits
One passage-0 library per genotype; replicates only at passage 7; 2 residual df. The paper's filter (no effect in WT) was not applied to the BARCS list.
