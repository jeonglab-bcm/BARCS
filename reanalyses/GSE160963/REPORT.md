# GSE160963 reanalysis with BARCS 0.2.3

**Paper.** "The BTB transcription factors ZBTB11 and ZFP131 maintain pluripotency by repressing pro-differentiation genes", *Cell Reports* (2022), PMID 35294876, doi:10.1016/j.celrep.2022.110524 (PMC8972945).

**Screen.** Mouse ESC CRISPR loss-of-function screen targeting ~1,700 transcription factors (10 guides/TF, 1,000 non-targeting). sgRNA representation was read in the plasmid pool and on days 5, 8 and 12 after transduction; guides against TFs needed for pluripotency or growth drop out over time.

**Design.** `~ time`, day 12 vs the plasmid pool, 2 libraries, 0 residual df (one ESC culture, so the no-replicate path pools overdispersion across the 1,000 non-targeting guides; calls are screening-level). The two maxiprep libraries agree near-Poisson and were summed into one plasmid reference (prepare.R). 9.8% of non-targeting guides reached p < 0.05 before calibration, so calls were calibrated to the controls (5.0% after).

## Results

| Gene | Paper | BARCS rank (depleted) | FDR |
|---|---|---|---|
| ZBTB11 | lead hit (3 methods) | 26 / 1682 | 0.0012 |
| ZFP131 | lead hit (3 methods) | 71 / 1682 | 0.0026 |

Both named hits are strongly depleted and pass FDR 0.10. BARCS calls 277 genes at FDR 0.05 and 313 at FDR 0.10.

## Agreement with the paper

The paper identified depleted TFs with three methods (log-fold-change, a mixed linear model = 218 TFs, and MAGeCK-RRA = 302 TFs), with 196 shared high-confidence TFs. Against the MAGeCK table, BARCS gene scores correlate at Spearman 0.70, and the top-300 overlap is near-complete (Jaccard 0.99). The strongest core-machinery genes (RNA Pol II subunits, splicing factors, TRIM28) dominate both lists. Differences in the top 50 are reorderings among these essential genes, expected from BARCS's dispersion-moderated test versus RRA rank aggregation.

## Limits

- One ESC culture (no biological replicates): the no-replicate path pools overdispersion across controls, so calls are screening-level.
- The maxiprep re-reads were summed; the day-12 vs plasmid contrast measures combined growth + pluripotency dropout, as in the paper.
