# GSE276161 reanalysis with BARCS 0.2.2

**Paper.** "CRISPRi/a screens in human iPSC-cardiomyocytes identify glycolytic activation as a druggable target for doxorubicin-induced cardiotoxicity", *Cell Stem Cell* (2024), PMID 39515331, doi:10.1016/j.stem.2024.10.007 (PMC11646563).

**Screen.** The druggable-genome sublibraries of hCRISPRi-v2 and hCRISPRa-v2 (about 2,300 genes, mostly 10 guides each) in iPSC-derived cardiomyocytes. The cells carry dCas9-KRAB (CRISPRi) or dCas9-VPR (CRISPRa) and were treated with doxorubicin (0.5 µM, 72 h) or vehicle, in two biological replicates; surviving cells were sequenced. The paper scored guides as in Horlbeck et al. 2016. It reports 21 CRISPRi and 43 CRISPRa genes whose perturbation protected cardiomyocytes, enriched after doxorubicin (Table S1, which could not be downloaded). The top CRISPRi hits are HPGDS, SCMH1, CA12, ERBB2 and DGKH; CA12, HPGDS and SCMH1 "also ranked low in the CRISPRa screens". The top CRISPRa hits are CLK2, ATP4A, TWF2, FLT4 and MAP3K4. CA12 was validated by knockdown, knockout and the CA12 inhibitor indisulam. No gene table is available, so only named hits are compared.

**Counts.** There is one file per GSM, listing all 209,069 guides of the full v2 library. Only about 27,000 CRISPRi and 56,000 CRISPRa guides have reads (the druggable sublibrary plus scattered single reads); the `min_total_count` filter of 30 removes the rest. The CRISPRa values are integers. **The CRISPRi values were deposited scaled.** In each sample, every nonzero value is an exact integer multiple of that sample's smallest nonzero value (1.1355, 1.0685, 1.2619 and 1.2080 for Vehicle Rep1, Vehicle Rep2, Doxo Rep1 and Doxo Rep2; largest deviation from an integer multiple 4 × 10⁻⁶). Raw counts were recovered as round(value / smallest nonzero value). This assumes the smallest value is one read. That follows from the data: the scaled values' common divisor equals their minimum, so the true counts' common divisor equals the true minimum. Raw counts across 26,000 guides cannot share a common factor above 1, so the minimum is one read. Each sample has 500–1,000 guides at that value (the usual single-read background) and about 50% odd multiples. Recovered depths are 16.2–18.4 M reads, about 2,600 reads per guide, similar to the CRISPRa libraries.

**Design.** Doxorubicin vs vehicle, `~ condition`, 4 libraries, 2 residual df. Rep1 vehicle and Rep1 doxorubicin show no sign of pairing (CRISPRi libraries all correlate 0.95–0.97), so there is no replicate term. Knockdowns that protect from doxorubicin are enriched.

**Calibration (CRISPRi).** 4.0% of the 496 counted non-targeting guides reached p < 0.05, so no calibration was needed. The controls sit where the targeting guides do (offset 0.01 z; mean 2,654 vs 2,625 reads), so the control null is centred on the controls and is informative. The top 1% of the 209,069 listed guides (about 8% of the guides with reads) hold about 21% of reads in every library, the same in vehicle and doxorubicin, so there is no treatment-driven composition shift.

## Results (CRISPRi, primary)

| | BARCS 0.2.2 | Paper |
|---|---|---|
| Genes at FDR 0.10 | 1 (IL2, a one-guide jackpot, see below); 0 against the control-pseudo-gene null | 21 protective hits (score > 2, p < 0.01) |
| CA12 | **#1 enriched** of 2,484 genes (#2 overall), +0.48, p 3 × 10⁻⁴, FDR 0.35; control-null FDR 0.50 | top 5, validated |
| HPGDS | #8 enriched, p 0.010, FDR 1 | top 5, validated |
| ERBB2 | #5 enriched, p 0.008, FDR 1 | top 5 |
| DGKH | #178 enriched, FDR 1 | top 5 |
| SCMH1 | #1,359 (−0.07), FDR 1 | top 5, validated |

**The only call is an artifact.** IL2 has one guide, with 10,399 reads in Vehicle Rep1 and 183, 2,796 and 175 in the other libraries. It is a jackpot in one vehicle library and is discounted. The control null does not support it either (empirical FDR 0.76).

**CA12.** Eight of ten guides are enriched after doxorubicin and the other two are flat (−0.06, +0.02). Seven move by +0.23 to +0.81 log. The eighth (0, 0, 134, 55 reads) is absent from both vehicle libraries and was tested by likelihood ratio (+5.9). Several CA12 guides are lowest in Vehicle Rep2, so the signal partly rests on one library.

## CRISPRa (secondary)

Library totals give 1,020 genes at FDR 0.10, all but 8 depleted after doxorubicin (824 against the control null), with guide correlation 0.39. Median-ratio totals give 1,207, all depleted (1,353 against the null centred on targeting guides). Neither result is credible. 6,563 targeting guides (12%) have reads in both vehicle libraries but none in either doxorubicin library, often every guide of a gene (for example all ACSM2A guides: 4–21 and 51–132 reads in vehicle, 0 in doxorubicin). Not one of the 812 counted non-targeting guides does this. The doxorubicin libraries therefore lack whole blocks of targeting guides for technical reasons (library representation or sequencing), and the depletion calls are not interpretable. On the enrichment side, which the paper used, nothing passes FDR 0.10. The paper's top CRISPRa hits still rank high among enriched genes: TWF2 #18, CLK2 #21, FLT4 #28, MAP3K4 #56 of 6,807 (FDR 0.27–0.54); ATP4A is #363. CA12 is neutral in CRISPRa (+0.03, #3,623), consistent with the paper's "ranked low" rather than a depletion.

## Where BARCS agrees and differs

- **Agrees in ranking.** CA12 is BARCS's strongest credible gene in the CRISPRi screen, and HPGDS and ERBB2 are in its top 8 enriched. These are three of the paper's top five CRISPRi hits. In CRISPRa, four of the paper's top five are in the top 56 enriched of 6,807.
- **Differs in significance.** None of the paper's hits passes FDR 0.10 in either screen, in the model or against the control null. With two replicates per arm and weak selection (vehicle and doxorubicin libraries correlate 0.95–0.97), the screen supports a ranking, not a hit list. The paper's per-guide score and p < 0.01 cut-off has no multiple-testing control, and its 21 + 43 hits came with individual validation, which is where CA12 was established.

## Limits

- CRISPRi counts were recovered from scaled values. The recovery is exact (every value an integer multiple of the minimum), but it rests on the deduction that the minimum is one read.
- Two replicates per arm, unpaired (2 residual df).
- The paper's Table S1 could not be retrieved, so there is no rank correlation with the published scores.
- CRISPRa doxorubicin libraries are missing blocks of guides; only its enrichment ranks are reported.
