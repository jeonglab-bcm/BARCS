# GSE225235 reanalysis with BARCS 0.2.3

**Paper.** Ho et al., "The CD58-CD2 axis is co-regulated with PD-L1 via CMTM6 and shapes anti-tumor immunity", *Cancer Cell* (2023), PMID 37327789, doi:10.1016/j.ccell.2023.05.014 (PMC10524902).

**Screen.** A375 melanoma cells expressing Cas9 carry the genome-wide Brunello library (76,441 guides, 4 per gene, no non-targeting controls in the deposited table). At day 10 they were FACS-sorted into CD58-low cells and a CD58-mid control population. There are two biological replicates, each sorted twice (technical sorts A and B). The GEO table is raw MAGeCK counts with four columns per library (`_A`..`_D`). These are sequencing re-reads: between any two of them the Poisson z-variance is about 1.0. `prepare.R` sums the four lanes. It then sums the two technical sorts of each biological replicate, because the GSMs are per biological replicate and a paired model would leave one residual df. The virus, day 6 and day 10 pre-sort libraries are dropout references and are not used. The authors ran MAGeCK four times, once for each technical sort pair (Supplemental Table 2). `prepare.R` combines the four runs per gene into the mean positive rank, the number of runs with pos|fdr < 0.10, and the mean LFC (`paper/cd58_mageck_combined.tsv`).

**Design.** `~ sort`, CD58-low vs CD58-mid, 2 vs 2, 2 residual df, moderated (prior df 8.6). Each biological replicate's two bins come from one culture, but a replicate term would leave 1 df, so it is left out. This is conservative. A sensitivity run (`design_techsorts.json`) keeps the 8 technical sorts as libraries with a replicate term (5 df). It gives 128 genes with the same top 13. It treats sort-to-sort noise as replicate noise, so it is likely anti-conservative.

**Checks.** There are no non-targeting guides, so calibration and the control null could not be checked. Composition is flat (top 1% of guides hold 3.5-4.3% of reads). Guide correlation is 0.004. The top calls are not jackpots: CD58, PGAP2, CUL3 and DNAJC13 rise in all four guides and both replicates.

## Results

| | BARCS 0.2.3 (2 vs 2) | Authors' MAGeCK (4 separate sort-pair runs) |
|---|---|---|
| Genes at FDR 0.10 | 69 (66 enriched in CD58-low, 3 depleted) | 9 in all four runs, 21 in two or more, 60 in at least one |
| CD58 (target, positive control) | #1, FDR 5e-19 | #1 in three runs, #2 in one |
| CMTM6 (validated CD58 stabiliser) | #13, FDR 6e-7 | ranks 6, 9, 13, 21 (FDR < 0.10 in three runs) |
| Genes called in at least two MAGeCK runs that BARCS calls | 21 / 21 | |
| Rank correlation (enrichment score vs mean MAGeCK rank) | 0.82 | |
| Top-10 / top-25 / top-50 overlap | 8 / 20 / 44 | |

## Where BARCS agrees and differs

- **Agrees.** The two analyses rank the same core regulators: CD58 itself, the GPI-anchor remodelling and synthesis genes (PGAP2, PIGV, PIGO, PIGP, PIGX, PIGW, PIGL), CUL3, DNAJC13, KMT2D, DYRK1A, RUNX1, NF2 and CMTM6. BARCS calls all 21 genes that the authors' MAGeCK calls in two or more runs.
- **BARCS calls more.** BARCS pools both biological replicates in one model, so it calls about 45 genes that MAGeCK called in at most one technical run, or in none. Examples are ZBTB7A, KCTD10, TOX4, ATP13A1, KDM6A, TAOK1 and more GPI pathway members. Their four guides agree, but each single sort pair has too few cells to call them. Many of these are biologically coherent with CD58 surface display (GPI anchoring, ESCRT component SNF8).
- **Paper-only.** The 39 genes that MAGeCK calls in only one of four runs are mostly not BARCS calls. That fits single-run noise.

## Limits

There are only two biological replicates, so the calls rest on 2 residual df with moderation. Technical sorts are summed, which assumes they add only sampling noise; in fact they differ more than Poisson (z-variance about 6-30). Without non-targeting guides the null cannot be checked empirically.
