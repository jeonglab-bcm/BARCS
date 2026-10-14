# GSE253290 reanalysis with BARCS 0.2.3

**Paper.** "CRISPR activation screens identify oncogenic lncRNAs that are susceptible to CDK4/6 inhibitor treatment", *Nature Communications* 2026, PMID 41957359 (PMC13287569, doi 10.1038/s41467-026-70816-2).

**Screens.** lncRNA CRISPRa (SAM) screens in MCF-7 under palbociclib. Genome-wide: ~52k sgRNAs for lncRNA TSSs, 500 non-targeting. Focused: 160 lncRNAs x 6 sgRNAs, 40 non-targeting.

**Sample mapping (corrected from GEO).** The paper describes P0 (plasmid), one untreated sample (P14) and three palbociclib replicates (T14a/b/c) in the genome-wide screen, and P0, P14a/b and T14a/b/c in the focused screen. GEO labels genome-wide S3 and focused cdk1 as "no drug 4 weeks". The data side with the paper:
- S3-S5 vs S2 reproduces the paper's palbociclib beta (Spearman 0.77 over transcripts), while S4/S5 vs S3 does not (0.02).
- cdk1-3 vs p14a/b reproduces the focused beta (0.91), while cdk2/3 vs cdk1 does not (-0.02).

So S2 is untreated and S3-S5 are palbociclib; p14a/b are untreated and cdk1-3 are palbociclib. This mapping is inferred, not stated in GEO.

**Counts.** `prepare.R` rebuilds the genome-wide table: GEO repeats each sgRNA once per GENCODE v19 transcript (134k rows, 52k sgRNAs). Transcripts are mapped to Ensembl genes with the paper's Supplementary Dataset 1, and rows are collapsed to one per sgRNA and gene (65,015). sgRNAs shared by overlapping genes count in each gene, as in the paper's MAGeCK run, which inflates every library's total by the same factor (1.306-1.309). The focused table is used as deposited.

**Paper's analysis.** MAGeCK MLE normalized to non-targeting guides. Genome-wide: 685 genes at treatment Wald FDR < 0.10 (494 with negative beta, i.e. sensitizing). Focused: 49 at FDR < 0.10 (25 negative). The three validated lncRNAs are TENM3-AS1 (ENSG00000177822), LINC01117 (ENSG00000224577) and ENSG00000226706. They promote proliferation and sensitize cells to palbociclib, so they should be depleted under the drug.

**Design.** Palbociclib vs untreated with control (non-targeting) totals, as the paper normalized:
- Genome-wide: 3 vs 1, 2 residual df.
- Focused (`design_focused.json`): 3 vs 2, 3 residual df.

There is a single untreated culture in the genome-wide screen, so its own drift cannot be separated from the drug effect.

## Results
- **Genome-wide, controls are inflated.** 28.8% of non-targeting guides reach p < 0.05, so BARCS calibrated to the controls. After calibration only **13 genes are at FDR 0.10** (11 enriched, led by ENSG00000186017, and 2 depleted; all at FDR 0.089-0.092), and **0 against the control null** (centred on the controls; control shift 0.04 z). With library totals instead of control totals the picture is similar (27.8% raw control rate, 2 genes). Gene effects still rank like the paper's betas (Spearman 0.74 between BARCS estimates and MAGeCK treatment beta), so the signal BARCS sees has the same shape as the paper's, but the non-targeting guides vary between the untreated and drug libraries as much as most lncRNA genes do. Eleven of the paper's 685 FDR-0.10 genes reach FDR 0.10 after calibration (10 with the paper's sign of beta), all marginally (FDR 0.089-0.092); none reaches FDR 0.05, and none passes against the control null.
- **Named hits, genome-wide:** TENM3-AS1 rank 146 among depleted genes (by p; p 0.36, FDR 0.60); LINC01117 and ENSG00000226706 lean enriched (FDR 0.72 and 0.92). No guide-level pattern supports them: ENSG00000226706's ten guides move in both directions.
- **Focused screen, controls fail and cannot be calibrated.** 87.5% of the 40 non-targeting guides are at p < 0.05 with control totals (85% with library totals). Individual NT guides differ reproducibly between the untreated and drug libraries by 2-4x (e.g. NT3 272/175 vs 627/776/697 reads; NT12 3523/3452 vs 7151/7991/7986). This looks like drift shared within each arm (p14a and p14b correlate 0.996), not drug biology. Automatic calibration needs at least 50 controls, so the focused list (128 genes at FDR 0.10) is **not interpretable** and is not quoted as a result. In it, LINC01117 has FDR 0.08 (depleted), TENM3-AS1 0.98 and ENSG00000226706 0.37 (enriched).

## BARCS vs paper
Differ. The paper's three validated lncRNAs and nearly all of its genome-wide hits are not supported once the non-targeting guides are used to judge the noise: 11 of its 685 genome-wide genes pass BARCS FDR 0.10, only marginally (0.089-0.092) and not against the control null, and the focused list cannot be judged. With one untreated library (genome-wide) or untreated replicates that share drift (focused), differences between the arms are as large for non-targeting guides as for targeted lncRNAs. MAGeCK MLE models dispersion from the mean-variance trend of all guides and does not check the controls. BARCS's gene ranking does correlate with the paper's (0.74), so the screens measure the same direction of effects; what they cannot show is which effects exceed drift.

## Limits
The sample mapping is inferred from the data and the paper text because GEO's labels conflict with both. Only one untreated library in the genome-wide screen. Too few controls in the focused screen to calibrate. Overlapping genes share sgRNAs.
