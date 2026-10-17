# GSE229545 reanalysis with BARCS 0.2.3

**Paper.** Sangare, Tachibana et al., "Host genetics highlights IFN-gamma-dependent Toxoplasma genes encoding secreted and non-secreted virulence factors in in vivo CRISPR screens", *Cell Reports* (2023), PMID 37269286, doi:10.1016/j.celrep.2023.112592. This series is the **ROP/GRA sublibrary**; GSE229545 (ROP/GRA), GSE229547 (endomembrane/nucleus) and GSE229548 (metabolism) are three sublibraries of the one study, each deposited and analysed as its own record.

**Screen.** Virulent *Toxoplasma gondii* RH tachyzoites carrying this sublibrary (about 10 gRNAs per gene, no non-targeting guides) were passaged in vitro (P3/P4) and in vivo through wild-type C57BL/6 mice (WT) and through IFN-gamma-receptor-deficient Ifngr1-/- mice (KO). GEO has no series count matrix; each GSM carries a two-column guide/count file. `prepare.R` merges them into `counts.tsv.gz` (gene = guide ID minus the trailing _<n>) and rebuilds the paper's per-gene tables from the study supplement (`paper/wt_vs_ko.tsv`, `paper/p4_vs_wt.tsv`).

**Design.** Library sizes use `median_ratio` because the in vivo libraries are heavily bottlenecked (top 1% of guides hold 20-41% of reads, up to half the guides are zero): parasites are purged through the mouse, so library totals would call almost everything depleted. Only between-arm comparisons are interpreted.
- Primary: **WT vs KO** (`~ condition`, KO reference), reproducing the paper's IFN-gamma-dependence test. A negative estimate means a guide is depleted in WT but not in Ifngr1-/- mice: an IFN-gamma-dependent virulence factor.
- Secondary: **P4 vs WT** (`design_p4wt.json`, P4 reference), in vivo fitness in WT mice.
There are no neutral control guides (the panel shared across the three sublibraries mixes essential and dispensable genes), so control calibration and the control null were not used.

## Results

| | BARCS 0.2.3 (WT vs KO) | Paper (Fig 3 / Table S1E) |
|---|---|---|
| Genes at FDR 0.10 | 71 (70 depleted in WT, 1 enriched); 25 residual df, guide corr 0.014 | validated set of IFN-gamma-dependent virulence factors |
| GRA12 (TGGT1_288650) | #1, FDR 9e-16 | validated |
| ROP18 (TGGT1_205250) | #2, FDR 1e-15 | validated |
| ROP5 (TGGT1_308090) | #3, FDR 2e-13 | validated |
| GRA45 (TGGT1_316250) | #4, FDR 8e-11 | validated |
| Effect-size correlation with paper (WT-KO score) | r = 0.32; 90% sign agreement on the paper's top 30 | |
| p-value rank correlation (Spearman) | -0.09 | |

GRA7 (TGGT1_203310, #6) and two hypothetical proteins round out the top depleted genes. P4 vs WT (in vivo fitness) calls 140 genes and again puts ROP5, GRA12 and ROP18 at the top.

## Where BARCS agrees and differs

- **Agrees.** All four validated IFN-gamma-dependent virulence factors are the four most significant depleted-in-WT genes, and effect sizes correlate with the paper's WT-KO score (r = 0.32, 90% sign agreement among the paper's strongest genes).
- **Differs.** The overall p-value ranking does not correlate (Spearman -0.09). Two causes: the in vivo libraries are strongly bottlenecked, so most genes carry little information and rank noisily; and the paper's WT-vs-KO list is dominated by genes *enriched* in WT (213 of 376 have a positive WT-KO score), which the depletion-directed BARCS score deprioritises. BARCS fits a negative-binomial model to guide counts with median-ratio normalisation; the paper t-tests per-gene fitness scores.

## Limits

Counts are rebuilt from per-sample files. The libraries are bottlenecked, so only the strongest depleted genes are interpretable and absolute depletion is not; there are no neutral controls to calibrate against.
