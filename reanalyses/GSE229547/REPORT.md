# GSE229547 reanalysis with BARCS 0.2.3

**Paper.** Sangare, Tachibana et al., "Host genetics highlights IFN-gamma-dependent Toxoplasma genes encoding secreted and non-secreted virulence factors in in vivo CRISPR screens", *Cell Reports* (2023), PMID 37269286, doi:10.1016/j.celrep.2023.112592. This series is the **endomembrane/nucleus sublibrary**; GSE229545 (ROP/GRA), GSE229547 (endomembrane/nucleus) and GSE229548 (metabolism) are three sublibraries of the one study, each deposited and analysed as its own record.

**Screen.** Virulent *Toxoplasma gondii* RH tachyzoites carrying this sublibrary (about 10 gRNAs per gene, no non-targeting guides) were passaged in vitro (P3/P4) and in vivo through wild-type C57BL/6 mice (WT) and through IFN-gamma-receptor-deficient Ifngr1-/- mice (KO). GEO has no series count matrix; each GSM carries a two-column guide/count file. `prepare.R` merges them into `counts.tsv.gz` (gene = guide ID minus the trailing _<n>) and rebuilds the paper's per-gene tables from the study supplement (`paper/wt_vs_ko.tsv`, `paper/p4_vs_wt.tsv`).

**Design.** Library sizes use `median_ratio` because the in vivo libraries are heavily bottlenecked (top 1% of guides hold 20-41% of reads, up to half the guides are zero): parasites are purged through the mouse, so library totals would call almost everything depleted. Only between-arm comparisons are interpreted.
- Primary: **WT vs KO** (`~ condition`, KO reference), reproducing the paper's IFN-gamma-dependence test. A negative estimate means a guide is depleted in WT but not in Ifngr1-/- mice: an IFN-gamma-dependent virulence factor.
- Secondary: **P4 vs WT** (`design_p4wt.json`, P4 reference), in vivo fitness in WT mice.
There are no neutral control guides (the panel shared across the three sublibraries mixes essential and dispensable genes), so control calibration and the control null were not used.

## Results

| | BARCS 0.2.3 (WT vs KO) | Paper (Table S2A) |
|---|---|---|
| Genes at FDR 0.10 | 160 (90 depleted in WT); 25 residual df, guide corr 0.004 | per-gene WT-vs-KO fitness |
| ROP18 (TGGT1_205250, shared positive control) | #1, FDR 3e-30 | IFN-gamma-dependent |
| p-value rank correlation (WT vs KO) | Spearman 0.28; top-100 overlap 58/100 | |
| P4 vs WT (in vivo fitness) | 229 genes; Spearman 0.43 vs paper | |

Top sublibrary-specific depleted-in-WT candidates: a YggS-family pyridoxal-phosphate enzyme (TGGT1_318720), a glutathione S-transferase (TGGT1_306030), AP2VIII-7 (TGGT1_269010) and several hypothetical proteins.

## Where BARCS agrees and differs

- **Agrees.** The shared positive control ROP18 is the single most significant depleted-in-WT gene. The WT-vs-KO and P4-vs-WT rankings track the paper (Spearman 0.28 and 0.43, top-100 overlap 58/100).
- **Differs.** BARCS calls a longer list (160 vs the paper's thresholded set) and ranks some genes differently, as expected from its guide-level negative-binomial model versus the paper's per-gene fitness-score test under a bottlenecked library.

## Limits

Counts are rebuilt from per-sample files; libraries are bottlenecked (median-ratio totals, depletion only); no neutral controls.
