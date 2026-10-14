# GSE293842 reanalysis with BARCS 0.2.3

**Paper.** "Targeting the ferritinophagy-lysosome axis as a therapeutic vulnerability in gastroenteropancreatic neuroendocrine tumors", *Cell Reports Medicine* 2026, PMID 41881024 (PMC13130658, doi 10.1016/j.xcrm.2026.102695).

**Screen.** Kinome-wide Brunello knockout (763 kinases, 8 guides per gene, 100 non-targeting guides per half-pool) in BON-1 pancreatic NET cells, day 14 vs day 0. The library was split into two half-pools, A (sgRNA sets 1-4) and B (sets 5-8), each transduced and sequenced as its own library (GSM8891594-97).

**Counts.** `GSE293842_counts_matrix.txt.gz` holds both half-pools in two columns with a `pool` column. The half-pools differ in their Day14/Day0 read ratio (A 0.92, B 1.07), so they need separate library totals. `prepare.R` puts each guide's counts in its own pool's columns (0 in the other pool's) and appends the pool to every guide ID, which also makes the 100 non-targeting IDs that occur in both pools unique.

**Paper's analysis.** Fold change per gene integrated over libraries A and B (Table S1, `final`); candidates at fold change < -0.3 (44 genes). The paper highlights four genes needed for pNET survival but not pan-essential: ILK, PTK2 (FAK), PIKFYVE and PIK3C3 (VPS34), and follows up PIKfyve.

**Design.** Day 14 vs day 0, one analysis per half-pool (4 guides per gene each), library totals. **One library per time point, no replicates**: BARCS uses the no-replicate path (overdispersion pooled over the ~100 non-targeting guides of each pool), so the calls are screening-level and the FDR does not include variation between replicate cultures. Only 100 controls per pool remain after filtering (99 usable in pool B), below what the control null needs, so there is no control-null count. Pool B's raw control rate was 9.1% at p < 0.05 and was calibrated to 5%; pool A's was 6.1%.

## Results
- **Pool A: 47 genes at FDR 0.10** (29 depleted). **Pool B: 36** (30 depleted). 15 genes are depleted in both pools; 44 in either.
- All four named genes are depleted in pool A: **PTK2 #1, ILK #2, PIK3C3 #16, PIKFYVE #26** (ranks among depleted genes, by p; FDR 1e-7 to 0.04). In pool B, ILK #4 (FDR 9e-8), PIKFYVE #18 (FDR 0.014) and PTK2 #30 (FDR 0.09) pass, and PIK3C3 does not (#57, FDR 0.67).
- PIKFYVE's evidence is moderate in both pools: 5 of 8 guides fall (e.g. 4729 -> 2390, 1081 -> 384) and one rises (3769 -> 5144).
- Against Table S1 (pool A): Spearman 0.69, 9 of the paper's top 10 in the BARCS top 10 (WEE1, CDK12, PTK2, TAF1, PKMYT1, ILK, CLP1, DTYMK, CHEK1). 32 of the paper's 44 candidates are depleted at FDR 0.10 in at least one pool. Paper-only genes (TP53RK, TRIO, STK11, RAF1, SRC, ...) sit near the paper's -0.3 fold-change cutoff, which is not a significance threshold.
- The top calls are core-essential kinases (WEE1, CDK12, CHEK1, PKMYT1, CDK1, TAF1, TRRAP, CDC7), as expected for a 14-day fitness screen. Pool A also has 18 small enrichments (PKN2, ROCK1/2, TAOK1, CSK), which the paper does not discuss.

## BARCS vs paper
Agree. The four highlighted kinases are significant depletions in pool A, and ILK and PIKFYVE are significant in both half-pools. BARCS's ranking matches the paper's fold-change ranking at the top (Spearman 0.69). PIK3C3 rests on pool A only.

## Limits
One library per time point and half-pool, so the calls are screening-level. The paper merged the half-pools; BARCS keeps them apart because their totals differ, so each analysis uses 4 of the 8 guides per gene. With only about 100 controls per pool there is no control null.
