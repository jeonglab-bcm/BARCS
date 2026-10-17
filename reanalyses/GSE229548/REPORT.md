# GSE229548 reanalysis with BARCS 0.2.3

**Paper.** Sangare, Tachibana et al., "Host genetics highlights IFN-gamma-dependent Toxoplasma genes encoding secreted and non-secreted virulence factors in in vivo CRISPR screens", *Cell Reports* (2023), PMID 37269286, doi:10.1016/j.celrep.2023.112592. This series is the **metabolism sublibrary**; GSE229545 (ROP/GRA), GSE229547 (endomembrane/nucleus) and GSE229548 (metabolism) are three sublibraries of the one study, each deposited and analysed as its own record.

**Screen.** Virulent *Toxoplasma gondii* RH tachyzoites carrying this sublibrary (about 10 gRNAs per gene, no non-targeting guides) were passaged in vitro (P3/P4) and in vivo through wild-type C57BL/6 mice (WT) and through IFN-gamma-receptor-deficient Ifngr1-/- mice (KO). GEO has no series count matrix; each GSM carries a two-column guide/count file. `prepare.R` merges them into `counts.tsv.gz` (gene = guide ID minus the trailing _<n>) and rebuilds the paper's per-gene tables from the study supplement (`paper/wt_vs_ko.tsv`, `paper/p4_vs_wt.tsv`).

**Design.** Library sizes use `median_ratio` because the in vivo libraries are heavily bottlenecked (top 1% of guides hold 20-41% of reads, up to half the guides are zero): parasites are purged through the mouse, so library totals would call almost everything depleted. Only between-arm comparisons are interpreted.
- Primary: **WT vs KO** (`~ condition`, KO reference), reproducing the paper's IFN-gamma-dependence test. A negative estimate means a guide is depleted in WT but not in Ifngr1-/- mice: an IFN-gamma-dependent virulence factor.
- Secondary: **P4 vs WT** (`design_p4wt.json`, P4 reference), in vivo fitness in WT mice.
There are no neutral control guides (the panel shared across the three sublibraries mixes essential and dispensable genes), so control calibration and the control null were not used.

## Results

| | BARCS 0.2.3 (WT vs KO) | Paper (Table S3A) |
|---|---|---|
| Genes at FDR 0.10 | 14 (10 depleted in WT); 13 residual df, guide corr 0.002 | per-gene WT-vs-KO fitness |
| ROP18 (TGGT1_205250, shared positive control) | #1, FDR 6e-9 | IFN-gamma-dependent |
| p-value rank correlation (WT vs KO) | Spearman 0.64; top-25 overlap 17/25 | |
| P4 vs WT (in vivo fitness) | 193 genes; Spearman 0.32 vs paper | |

The small WT-vs-KO hit list (ROP18, ROP1, a methyltransferase, DG32 and hypotheticals) reflects that the metabolism sublibrary holds few genes with a strong IFN-gamma-dependent effect; most metabolism genes matter for in vivo growth regardless of host IFN-gamma, which shows up in the larger P4-vs-WT list.

## Where BARCS agrees and differs

- **Agrees.** ROP18 (shared positive control) is first, and the WT-vs-KO ranking correlates well with the paper (Spearman 0.64, top-25 overlap 17/25).
- **Differs.** The P4 vs WT contrast uses a single in vitro library against eight WT libraries, so its moderate correlation (0.32) partly reflects that one-library reference. BARCS's model and the paper's per-gene fitness test otherwise agree on direction.

## Limits

Counts are rebuilt from per-sample files; libraries are bottlenecked (median-ratio totals, depletion only); no neutral controls; the P4 arm is a single library.
