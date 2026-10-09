# GSE280676 reanalysis with BARCS 0.2.2

**Paper.** "Pooled CRISPR screens identifies key regulators of bovine stem cell expansion for cultured meat", *Communications Biology* 8 (2025), PMID 40885801, doi:10.1038/s42003-025-08760-y, PMC12398484 (open access). Supplementary Data 1 (`MOESM2_ESM.xlsx`, sheet "MaGeCK Results") gives MAGeCK gene results for days 3, 7, 10, 16, 24 and 30. The paper does not say which sample it used as the reference. It says only "relative to baseline (day 0)". The comparison uses that sheet's day-16 rows (`paper/mageck_day16.csv`) and the genes the paper names.

**Series.** The paper deposited two screens. GSE280676 is the short-term (30-day) screen, reanalyzed here. GSE280666 is the long-term (100-day) screen and is excluded; see `work/GSE280666/REJECT.txt`. Both used the same 3,000-guide library: 2,564 guides on 603 genes plus 436 non-cutting `nc_guide` controls, and every control has its own gene label. Both used adipose-derived bovine MSCs (AD-bMSCs) with Cas9. The setups differ. In this screen, fresh cells were transduced at low MOI (~0.3, about 600 cells per guide), passaged every 3–4 days, and sampled on days 1, 3, 7, 10, 16, 24 and 30, with 3 replicate cultures plus 3 plasmid libraries. In the long-term screen, cells were first cultured for 75 days (about 100 doublings) and then transduced at a higher MOI to look for combinatorial knockouts.

**Counts.** `GSE280676_ShortTermScreen_raw_counts.txt.gz` is UTF-16. It was converted unchanged to UTF-8 (`counts_utf8.tsv.gz`) and holds integer counts. Column names match the GSM titles one to one (GSM8603599–GSM8603622). Day-1 replicates correlate at 0.995 (log CPM) and plasmid at 0.976.

## Composition and choice of contrast

Day 30 is the paper's headline time point, but by then the screen has been taken over by a few clones:

| Time point | Top-1% read share | Zero guides | Replicate r (log CPM) |
|---|---|---|---|
| day 1 | 4.3–4.4% | 1.0–1.2% | 0.995 |
| day 10 | 4.7–4.8% | 1.6–1.7% | 0.84 |
| day 16 | 7.4–8.3% | 1.9–2.0% | 0.68 |
| day 24 | 28–39% | 2.3–3.0% | 0.50 |
| day 30 | 48–72% | 3.4–4.6% | 0.43 |

At day 30 against day 1 with library totals, 60.5% of the non-targeting guides reach p < 0.05. Calibrating to the controls fixes that rate but leaves no enriched gene: TP53 ranks 3rd among enriched genes, but its FDR is only 0.30, because each replicate is led by different TP53 guides at different strengths. The run also calls 464 genes depleted, which is the dilution effect of the clones, not biology. Median-ratio totals are capped in day30 rep3, where single guides hold most of the reads, so depletion at day 30 cannot be interpreted either. Day 24 behaves the same way (34% raw control rate; 0 enriched genes after calibration).

The primary analysis is therefore **day 16 vs day 1** (3 vs 3), the last time point before the clones take over. It passes every check of the rule applied to both series:

- The top 1% of guides hold no more than 8.3% of reads in any library.
- 10.4% of controls reach p < 0.05 before calibration and 4.9% after.
- The strongest single non-targeting guide would rank 5th among enriched genes, below the 4 genes called.
- 74% of the guides that move more than 2-fold change in the same direction in all three replicates.
- All 5 TP53 guides and all 4 PTEN guides rise in every replicate. No top hit depends on a jackpot guide: the largest single-guide count is TP53_1 in rep 3 (about 1% of reads), and its other replicates are also up.

Library totals are used because composition is close to normal at day 16. Median-ratio totals are a sensitivity run, and day 30 vs day 1 is kept to document the paper's headline contrast.

Replicates are separate lineages after day 1: each replicate's day-16 changes carry on to day 30 (r ≈ 0.7 within a replicate, ≈ 0.2 across replicates). The day-1 libraries, however, cannot be told apart, so the model has no replicate term. Day 1 is used rather than the plasmid because the plasmid libraries are shallow (0.4–1.1 M reads) and were sequenced in other batches. The paper's "day 0" baseline may be the plasmid, so the reference may differ slightly from the paper's.

## Results (day 16 vs day 1, library totals)

| | BARCS | Paper (MAGeCK, day 16) |
|---|---|---|
| Genes at FDR 0.10 | 135 (4 enriched, 131 depleted) | 83 (5 enriched, 78 depleted) |
| Against the control null (centred on targeting guides; controls offset −0.66 z) | 47 (24 enriched, 23 depleted) | – |
| TP53 | enriched #2, FDR 4.5 × 10⁻⁴, 5/5 guides up | pos rank 1, FDR 0.005 |
| PTEN | enriched #1, FDR 1.4 × 10⁻⁴, 4/4 guides up | pos rank 3, FDR 0.012 |
| VGLL4 | enriched #3, FDR 0.0019 | pos rank 2, FDR < 0.1 |
| SMAD4 | enriched #4, FDR 0.059 | pos rank 13, FDR 1 |
| MPC1 / MPC2 / SMAD3 / SMAD5 / RUNX1 | FDR 0.31 / 0.71 / 0.41 / 0.48 / 0.81 | not significant |

The depleted calls are canonical fitness genes: RPS9, RRM2, DONSON, RRM1, ANKLE2, MYC, HINFP, CDC45, ribosomal proteins and JUN. 61 of the paper's 78 depleted genes at day 16 are among BARCS's 131. Median-ratio totals give 25 genes (8 enriched: PTEN, VGLL4, TP53, MPC1 and four weaker ones), with TP53, PTEN and VGLL4 at FDR < 0.007. Against the control null, the model's 4 enriched calls are all confirmed (empirical FDR 0.002–0.005), and the null adds 20 weaker enriched genes, among them PDCD10, NR3C1, NLK, FOXO4, RELA and MPC1.

## Where BARCS agrees and differs

- **Agrees.** All three proliferation inhibitors the paper names (TP53, PTEN, VGLL4) are BARCS's top three enriched genes at day 16, every guide is concordant, and the control null confirms them. The paper's day-16 enriched list holds 5 genes; BARCS calls 3 of them. Gene scores correlate with the paper's day-16 MAGeCK positive scores at Spearman 0.73. The top 10 share 6 genes and the top 50 share 28.
- **Differs.** ZBTB11 and TXNL4A, the paper's other two day-16 enriched calls, have BARCS FDR 0.92 and 0.85. SMAD4 is called by BARCS (FDR 0.059) but not by the paper at day 16. The secondary pathways the paper discusses (MPC1/MPC2, SMAD3/SMAD5, RUNX1) do not pass FDR 0.10.
- **Day 30.** The paper's day-30 enriched list (FDR < 0.1) includes RPS11, RPL31, ETF1, WEE1 and KIF11. These are fitness genes, and BARCS estimates them as depleted at day 30. Their "enrichment" in the paper probably comes from single guides inside expanding clones, which RRA ranking does not discount. In BARCS the replicate disagreement at day 30 removes all enriched calls, TP53 included. In this screen the paper's day-30 headline therefore rests on clonal outgrowth. The same genes come out cleanly at day 16.

## Limits

- The primary contrast is day 16, not the paper's headline day 30, and the paper's baseline (day 0 or day 1) is not certain.
- The paper does not say whether the three replicate cultures were transduced separately. The day-1 libraries are nearly identical (r = 0.995), so the replicates may be lineages split from one infected pool.
- The 131 depleted calls exceed the control-null count (23 depleted), because the non-cutting controls sit 0.66 z above the targeting guides (no cutting toxicity). Read the depleted list as relative to targeting guides, not to the controls.
