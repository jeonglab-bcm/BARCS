# GSE328470 reanalysis with BARCS 0.2.3

**Paper.** Gierisch et al., "Mitochondria serve as a holdout compartment for aggregation-prone proteins hindering efficient degradation", *Nature Communications* 2026, PMID 42098118 (doi 10.1038/s41467-026-72783-0, PMC13153185).

**Screen.** Genome-wide Brunello knockout screen (about 77k guides, 1000 non-targeting `Control_` guides) in MelJuSo cells carrying the YFP-CL1 degradation reporter. Two independent experiments (R1, R2), each with the unsorted pool and the ~0.5% YFP-low and YFP-high tails (6 libraries, raw integer counts in `GSE328470_Readcount_per_guide.txt.gz`; columns match GSM titles). Suppressors of reporter degradation are enriched in YFP-low; genes needed for degradation (UBE2G2, RNF139) in YFP-high.

**Paper's analysis.** MAGeCK per experiment, sorted bin vs unsorted pool (Supplementary Data 1), keeping genes enriched in both experiments: 824 genes for YFP-high and 1,187 overlapping genes for YFP-low, enriched for mitochondrial functions. eIF5A was "the only gene strongly enriched in both experiments"; no gene passes MAGeCK FDR 0.10 in either low-bin experiment (EIF5A FDR 0.89 and 0.35). For comparison, `prepare.R` builds `paper/SD1_YFPlow_combined.tsv` from Supplementary Data 1: per gene, the larger of the two MAGeCK pos p-values (enriched in both) and the mean LFC.

**Design.** Primary: YFP-low vs unsorted, `~ bin`, 2 vs 2 (2 residual df, moderation applied, prior df 20). Second: YFP-high vs unsorted, the paper's positive-control arm. No experiment term: it would leave 1 residual df, and the sorted libraries do not correlate more within an experiment than across. Library totals. The sorted tails are heavily bottlenecked (10-36% zero guides; top 1% of guides hold 12% of reads in R1 YFP-low), so single-guide jackpots are expected; 5,637 guides were tested by likelihood ratio.

**Calibration.** YFP-low: 2.6% of control guides at p < 0.05 (no calibration needed). YFP-high: 10.0% before, calibrated to 5%. Controls sit close to the targeting guides (shift -0.14 and -0.07 z), so the control null is centred on the controls.

## Results
- **YFP-low vs unsorted:** 321 genes at FDR 0.10, but 320 are depleted, mostly core essential genes (NHP2, FEN1, MED31, AURKB, RPS17, CDC123, VARS...). These guides are lost from the sorted tail relative to the pool, which is about fitness or sort bottlenecks rather than reporter degradation. Only one gene is enriched at FDR 0.10: **GORAB** (all four guides up in both experiments). 121 genes pass against the control null.
- **EIF5A ranks #20 of 19,113 among low-enriched genes** (FDR 0.24); three of four guides go from tens or hundreds of reads in the pool to 435-766 in YFP-low in both experiments. NDUFA10 (complex I) ranks #2, fitting the paper's mitochondrial theme. BOLA3 and COMMD10, which the paper added because they ranked high in experiment 2 only, rank #594 and #580 here: their guides are at zero in experiment 1's YFP-low library.
- **Rank agreement with the paper's table is good:** Spearman 0.65 across 19,097 genes; 14 of the top 50 and 65 of the top 200 shared. Several of the paper's top genes (C9orf139 #1, WNT5A #6) have mean LFC near zero or negative and rest on one experiment's jackpot guides; BARCS does not rank them.
- **YFP-high vs unsorted:** RNF139 is the #1 and UBE2G2 the #3 enriched gene, as the paper expects, but with two libraries per arm neither reaches FDR 0.10 (0.21 and 0.33). The 17 genes at FDR 0.10 are all depleted (RPL3, RFC2, TIMM9...), again fitness genes lost from the sorted tail.

## BARCS vs paper
Both analyses rank EIF5A at the very top of the YFP-low enrichment, and neither gives it a significant FDR on its own: the paper relied on reproducibility across the two experiments plus siRNA, GC7 and knockout follow-up. BARCS adds one enriched call at FDR 0.10 (GORAB) and agrees with the positive-control arm by rank only. The hypusination enzymes DHPS and DOHH, which the paper targets with GC7, do not score in the screen in either analysis.

## Limits
Two libraries per arm and strongly bottlenecked sorted tails: power is low and single-guide jackpots are common. The depleted calls in both arms are fitness or bottleneck effects, not reporter biology. The published comparison table is a derived combination of the paper's two per-experiment MAGeCK runs.
