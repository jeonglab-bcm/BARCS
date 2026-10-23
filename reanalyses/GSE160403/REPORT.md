# GSE160403 reanalysis with BARCS 0.2.3

**Paper.** Stavast et al., "The tumor suppressor MIR139 is silenced by POLR2M to promote AML oncogenesis", *Leukemia* (2022), PMID 34741119, doi:10.1038/s41375-021-01461-5 (PMC8885418).

**Screen.** Mouse GeCKOv2 knockout library (A+B halves, about 6 guides per gene, 998 non-targeting controls) in MLL-AF9 leukemia cells. GEO holds one library per condition: wild-type MLL-AF9 cells 24 h after selection, and wild-type and *Mir139*-knockout MLL-AF9 cells after 14 days. `prepare.R` merges the three per-sample files (integer reads, `<gene>:<guide>,<reads>`), drops the line of reads that matched no guide, and fills guides missing from a file with zero. Gene names are as deposited (a few were turned into dates by a spreadsheet, e.g. `10-Mar`). The paper's question: which knockouts kill wild-type cells but not *Mir139*-KO cells (factors that silence MIR139)? The authors picked genes with 5-6 guides each lost at least 10-fold in WT versus KO (16 genes, Supplementary Table 6) and validated *Polr2m*. They also used WT day 14 versus WT 24 h to show known MLL-AF9 dependencies (Men1, Eed, Rbbp4, Dot1l, Mllt3). Their gene-level table (MOESM12, "Per Gene", with a permutation p-value and neg/pos FDR) is the published comparison; `prepare.R` downloads it.

**Design.** Two analyses, each `~ condition` with 1 vs 1 library: WT d14 vs *Mir139*-KO d14 (the paper's main question; design term `conditionWT14d`, depletion = lost in WT), and WT d14 vs WT 24 h (dependencies). No residual df, so `run_barcs.R` used the no-replicate path, pooling the overdispersion over the non-targeting guides. **The calls are screening-level:** variation between replicate cultures was not measured.

**Checks.** The day-14 libraries are bottlenecked: 22% of all guides and 6.7% of non-targeting guides have zero reads, the top 1% of guides hold 15% (WT) and 19% (KO) of reads, and WT d14 and KO d14 correlate at Spearman 0.49. The pooled overdispersion is correspondingly large (inflation 139 and 76 at rho = 0). Control calibration is conservative (1.6% and 3.3% of non-targeting guides at p < 0.05). The control null is centred on the controls and calls far more genes than the model (57 and 778); by the rules for offset controls, those counts are not quoted as hits.

## Results

| | BARCS 0.2.3 | Authors (MOESM12 / text) |
|---|---|---|
| WT vs *Mir139*-KO, genes at FDR 0.10 | 8 (7 lower in WT, 1 higher) | 4 at neg-FDR 0.10 in their own table; 16 genes selected by the ≥10-fold-per-guide rule |
| *Polr2m* (validated) | rank 1,163 of 21,598, estimate −3.5, p = 0.18, FDR 1 | neg-FDR 0.46 in their table; selected by the 5-of-6-guides rule |
| Rank correlation with their p-value | 0.00 | |
| Top-16 / top-200 overlap | 0 / 2 | |
| WT d14 vs WT 24 h, genes at FDR 0.10 | 10, all enriched (Bag6, Pmaip1, Bcl2l11, Bax, Atxn7l3, ...); none depleted | Men1, Eed, Rbbp4, Dot1l, Mllt3 "lost" |
| Men1 / Rbbp4 / Eed (d14 vs 24 h) | ranks 695 / 1,352 / 1,833 depleted, FDR 0.77 | named dependencies |

## Where BARCS agrees and differs

- **Polr2m is not supported statistically.** Five of six *Polr2m* guides are lower in WT than in KO (summed 31 vs 1,029 reads), which is the pattern the authors selected on. But at day 14 the KO library itself swings widely (guide counts 1-686, against 16-280 at 24 h), and non-targeting guides fall to zero in 6.7% of cases. The authors' own permutation table gives *Polr2m* neg-FDR 0.46. BARCS agrees that it is not distinguishable from bottleneck noise. The validation experiments in the paper are independent of this.
- **BARCS's WT-vs-KO calls are mostly single-clone jackpots.** *mmu-mir-6990* (one guide 33,484 reads in KO vs 414 in WT), *Coq2* (12,862 vs 353), *C87977* (one guide, 17,589 vs 112), *Echs1*, *Efr3a*, *Pdss2* and *Bbc3* each rest on one or two guides with thousands of reads in the KO library only. These are expanded clones, not *Mir139*-dependent effects, and should be discounted. The one enriched call, *Bag6*, is consistent across all 6 guides and is also enriched in WT d14 vs 24 h, so it reflects a survival advantage of *Bag6* loss in general, not a *Mir139* interaction.
- **The paper's top table genes are also artifacts.** Its lowest p-values (Cul4b, mmu-mir-92b, Clip1, Tpi1, ...) come from one or two guides at 0 vs several hundred reads; BARCS ranks them in the thousands.
- **Dependencies (d14 vs 24 h).** The named dependencies do drop: *Men1* falls from 79-602 reads at 24 h to 0-2 in five of six guides at day 14, and *Rbbp4* likewise. BARCS does not call them because a guide at zero in a bottlenecked library is weak evidence under the pooled overdispersion, and the Wald test is conservative at zero counts. What BARCS does call cleanly is the opposite tail: knockouts of the pro-apoptotic genes *Pmaip1* (NOXA), *Bcl2l11* (BIM), *Bax* and *Bag6* expand over 14 days, a coherent apoptosis signal the paper does not discuss.

## Limits

- One library per condition with a strong bottleneck at day 14; the calls are screening-level and dominated by clone-level noise.
- The paper's hit selection was a guide-count rule (≥5 guides lost ≥10-fold), not a statistical test, so there is no FDR-controlled hit list to reproduce.
