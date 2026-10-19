# GSE241070 reanalysis with BARCS 0.2.3

**Paper.** "Construction and initial validation of key gene network for progesterone resistance in endometrial cancer based on genome-wide CRISPR screening", *Scientific Reports* (2026), PMID 41775739, doi:10.1038/s41598-026-36534-x (open access, PMC12957397).

**Screen.** GeCKOv2 library B knockout screen (56,869 guides, 3 per gene, 1,000 non-targeting) in Ishikawa endometrial cancer cells: a baseline library after puromycin selection, then 10 days of DMSO (control) or 15 uM medroxyprogesterone acetate (MPA). The GEO table `N2305307.count_allinfo` holds integer MAGeCK counts with self-named columns that match the GSM titles; it is used as served. The paper's RRA tables (Supplementary Material 5, MPA vs control) are converted to `paper/rra.tsv` by `prepare.R`.

**Design.** `~ condition`, MPA vs DMSO, one library each. With no residual degrees of freedom, `run_barcs.R` pools the overdispersion over the 1,000 non-targeting guides (inflation 4.3 over binomial) and tests each guide against the normal. **These are screening-level calls: no replicate cultures were measured, so culture-to-culture variation is not part of the error model.** Negative effects are depleted under MPA (the paper's "pro-resistance" genes), positive effects enriched ("anti-resistance").

**Checks.** Composition is flat (top 1% of guides hold 3.6% of reads in both libraries). Non-targeting guides at p < 0.05: 6.4%, so no calibration was applied. Controls sit 0.39 z from the targeting guides, so the control null is centred on the targeting guides: 123 genes at control-null FDR 0.10, against 114 at model FDR 0.10.

## Results

BARCS: 114 genes at FDR 0.10 (105 enriched under MPA, 9 depleted); 74 at FDR 0.05.

The paper's MAGeCK RRA called 332 depleted and 3,438 enriched genes at nominal p < 0.05; at RRA FDR 0.10, the threshold its methods name, it calls 1,228 enriched genes and no depleted gene. Its MLE ranking gave 829 and 5,098. Ten genes were picked by intersecting the RRA, MLE and an external progestin-resistance expression data set (GSE121367) and then validated:

| Gene | Paper role | BARCS rank | Effect | FDR |
|---|---|---|---|---|
| NNMT | pro-resistance (depleted) | 50 | -0.34 | 0.024 |
| ZIC2 | anti-resistance (enriched) | 49 | +0.46 | 0.024 |
| SOX17 | anti-resistance | 154 | +0.42 | 0.16 |
| HHIPL1 | anti-resistance | 293 | +0.17 | 0.28 |
| KCNRG | anti-resistance | 321 | +0.33 | 0.31 |
| PDE1A | pro-resistance | 544 | -0.24 | 0.41 |
| DTX3L | pro-resistance | 709 | -0.23 | 0.47 |
| ABCC2 | pro-resistance | 981 | -0.24 | 0.53 |
| AMPD3 | pro-resistance | 1127 | -0.17 | 0.55 |
| RPL22L1 | anti-resistance | 2976 | +0.22 | 0.74 |

All ten point in the paper's direction, but only NNMT and ZIC2 pass FDR 0.10 (NNMT and SOX17 were the two taken into xenografts).

Against the full RRA table (`comparison.md`): Spearman 0.52 between gene scores, 81% effect-direction agreement, and 28 / 67 / 131 genes shared in the top 50 / 100 / 200. The top hits are largely the same genes in both methods: ATP6V0C, SIN3A, ATP6V1G1, DET1, GINS1, BRF1 and PRC1 are top-10 in the paper's RRA or MLE lists and top-15 in BARCS.

## What the enriched hits are

The genes enriched under MPA are mostly core essential genes (V-ATPase subunits, GINS/MCM replication factors, ribosomal and RNA-processing genes). Their guides are depleted between baseline and DMSO (median gene log2 ratio -1.02 for the 105 BARCS-enriched genes; 0.04 for all genes) and less depleted under MPA (-0.37). For example, ATP6V0C guide 2 drops from 575 baseline reads to 20 in DMSO but keeps 265 under MPA. This is what a drug that slows proliferation does to an essential-gene dropout screen: fewer doublings under MPA leave essential-gene knockouts less depleted. The enrichment therefore mostly measures growth rate, not a specific progestin-sensitivity mechanism. The validated genes' effects are small (|log2| 0.2-0.5), and their raw counts (for example NNMT 574/183/513 reads in DMSO vs 419/147/324 under MPA) show modest, consistent shifts.

## Why BARCS and MAGeCK differ

RRA p-values in a 1 vs 1 design are rank-based and use MAGeCK's mean-variance fit across all guides. BARCS uses a beta-binomial overdispersion estimated from the non-targeting guides and combines the three guides per gene by Stouffer. Both find the same strong essential-gene signal. Neither can tell guide noise from culture-to-culture variation without replicates. The paper's nominal p < 0.05 lists (3,770 RRA genes) are far longer than any FDR-controlled list.

## Limits

- One library per condition, no replicate cultures: screening-level calls only.
- Three guides per gene: one aberrant guide moves a gene a long way.
- The validated genes were chosen by intersection with an external expression data set, not by screen significance, so they need not pass any screen FDR.
