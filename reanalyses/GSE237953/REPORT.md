# GSE237953 reanalysis with BARCS 0.2.2

**Paper.** "PAXIP1 and STAG2 converge to maintain 3D genome architecture and facilitate promoter/enhancer contacts to enable stress hormone-dependent transcription", *Nucleic Acids Research* (2023), PMID 37070193, doi:10.1093/nar/gkad267 (PMC10570044).

**Screen.** A Brunello library (76,932 guides, 998 non-targeting) in A549 lung cancer cells. After 24 h of hydrocortisone, cells were fixed, stained for the glucocorticoid-induced protein FKBP5, and sorted into the lowest and highest 7.5% (about 3.5 M cells per arm), in three replicates. The authors size-factor normalized the counts, pooled the replicates and ran MAGeCK RRA, FKBP5-low vs FKBP5-high. Their putative hits had FDR < 0.15, log2 fold change > 2.5 and p < 0.01; 10 genes meet those criteria in the deposited table. The deposited MAGeCK gene table is the published comparison here.

**Counts.** The deposited "raw" counts are all integers ≥ 1 with no zeros, and 30% are exactly 1. A pseudocount of 1 had evidently been added, so 1 was subtracted from every value before analysis. The libraries are sparse: about 12–14 M reads over 77k guides, with 24–36% of guides at zero in each library.

**Design.** FKBP5-low vs FKBP5-high, `~ replicate + condition`, 6 libraries, 2 residual df. lo_rN and hi_rN correlate 0.66–0.68; all other pairs correlate 0.29–0.31. The two bins of a replicate were therefore sorted from one infection, and replicate is a blocking term.

**Calibration.** 15.9% of non-targeting guides reached p < 0.05, so the test was calibrated to them (5.0% after). This calibration is less reliable than usual: the non-targeting guides are about 5× more abundant than targeting guides (median 2,399 vs 500 reads over the six libraries; 5% vs 31% zero counts). They therefore say little about the sparse targeting guides, where the noise is. Nearly half of all guides (35,196) moved more than 100-fold between bins and were tested by likelihood ratio. Most of these are guides seen in only one or two libraries.

## Results

| | BARCS (all guides) | BARCS (guides ≥ 1,000 reads, sensitivity) | Authors' MAGeCK |
|---|---|---|---|
| Genes at FDR 0.10 | 1,861 (1,197 enriched in FKBP5-low, 664 depleted) | 8 | 10 (the same 10 meet its FDR < 0.15, LFC > 2.5 criteria) |
| Against the control-pseudo-gene null | 1,944 | 17 | |
| NR3C1 (GR itself) | #2 enriched, FDR 2 × 10⁻⁶ | #1, FDR 8 × 10⁻⁷ | rank 1 |
| STAG2 | #13, FDR 0.0001 | #5, FDR 0.05 | rank 2 |
| PAXIP1 | #12, FDR 0.0001 | #19, FDR 0.24 | rank 3 |
| FKBP5 (reporter gene) | #8, FDR 0.0001 | #6, FDR 0.07 | rank 4 |
| Paper's 10 hits at FDR 0.10 | 10/10 (largest FDR 0.013, EHMT2) | 6/10 | |
| Rank correlation with MAGeCK | 0.69 (enriched direction) | | |
| Top-25 overlap with MAGeCK | 8 | | |

## Where BARCS agrees and differs

- **Agrees.** NR3C1, STAG2, PAXIP1 and the reporter gene FKBP5 are among the 13 most enriched genes in FKBP5-low cells. All ten of the authors' putative hits pass FDR 0.10; the largest FDR among them is 0.013 (EHMT2). In the sensitivity run, the six strongest genes are all hits from the paper's list.
- **The long tail is not credible.** The headline run calls 1,861 genes, but the screen does not support that many. Top BARCS-only genes such as LBHD1 (#3; MAGeCK rank 498) rest on guides seen in one or two libraries. Each of its four guides has 23–94 reads in one or two FKBP5-low libraries and 0–5 reads everywhere else. EXOC4, the #1 BARCS gene and MAGeCK rank 12, looks the same: one guide has 169 reads in lo_r1 and 0–1 elsewhere. This is jackpot sampling from a sort of a few million cells. Because the controls are much more abundant, they do not show this noise, so neither the calibration nor the control-pseudo-gene null (1,944) corrects for it. Restricting to guides with at least 1,000 reads, the range where the controls live, leaves 8 genes at FDR 0.10. That filter is itself biased against real hits, whose guides empty out of the FKBP5-high bin: PAXIP1 keeps only two guides and drops to FDR 0.24. The true list lies between the two runs and is close to the paper's.

## Limits

- The deposited counts had a pseudocount added, which was removed by subtraction (*inferred* from the absence of zeros).
- Sparse sorted libraries (24–36% zero guides) and controls far more abundant than targeting guides. Control-based calibration and the control null therefore under-correct, and BARCS's headline FDR count is inflated.
- The authors' MAGeCK pooled the replicates, so its FDRs do not use replicate variation.
