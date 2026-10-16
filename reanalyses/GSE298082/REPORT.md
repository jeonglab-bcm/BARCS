# GSE298082 reanalysis with BARCS 0.2.3

**Paper.** Billmann, Costanzo et al. "Global genetic interaction network of a human cell maps conserved principles and informs functional interpretation of gene co-essentiality profiles", *Cell* 2026, PMID 42049019 (PMC13281610, doi:10.1016/j.cell.2026.03.044). SuperSeries GSE298085; this is the minimal-medium (DMEM, 10 mM glucose / 1 mM glutamine) sub-series. The rich-medium sub-series is GSE298081.

**Screen.** Genome-wide TKOv3 knockout screens (71,090 guides, 142 non-cutting EGFP/LacZ/luciferase controls) in HAP1 query knockout lines and parental WT cells. Each screen has one T0 and endpoint libraries A/B/C, which are parallel passages of one infection.

**What was reproduced.** This reanalysis takes the paper's showcase query, PTAR1, in minimal medium. The PTAR1 screens are:
- GIN043, 14-bp deletion;
- GIN053, 14-bp deletion;
- GIN109, an independent 1-bp insertion allele.

GIN108 failed the paper's QC and is excluded.

The reference is 16 WT/parental minimal-medium screens. The following were excluded:
- the diploid WT clones (GIN035, GIN054);
- a WT line from another lab (GIN175);
- GIN145, whose endpoints are not deposited;
- GIN030, whose T0 library is titled GIN028_T0 on GEO, contradicting Data S1.

GIN089 and GIN181 have two endpoints each. The comparison table is the mean of the two minimal-medium per-screen qGI scores in Data S7 (GIN043, GIN109).

**Counts.** `GSE298082_gin_read_counts_matrix_min.txt.gz` holds raw integer counts per sequencing library. Blank cells are no reads; the matrix has no zeros. `prepare.R` does the following:
- maps libraries to screens with Data S1, which agrees with the GSM titles;
- writes blanks as 0 and adds a Gene column;
- sums each screen's endpoint libraries into `<GIN>_end`.

**Design.** `~ screen + phase + gi` on 38 columns (19 screens × T0 + summed endpoint). The term `giPTAR1_end` is the PTAR1 dropout beyond the WT dropout (negative = negative interaction). The model has 17 residual df and the moderation prior df is 33. Endpoint times are well matched in this medium (T17-T20). qGI's M-A loess normalization is not applied.

**Checks.**
- Composition is normal: the top 1% of guides hold 2.3-4.6% of reads.
- Controls are calibrated without adjustment: 5.7% of control guides at p < 0.05.
- Guide correlation is 0.020.
- The control null is centred on the controls (shift -0.10 z) and gives 759 genes at FDR 0.10.

## Results
- 1035 genes at FDR 0.10: 518 depleted and 517 enriched.
- Top depleted: VAMP2, PICALM, RAB14, VAC14, ZDHHC5, VAMP3, TSSC1, DBF4, RAB1A, FASN, WDFY1, WDR44.
- Top enriched: TADA1, ABHD17B, ARF1, REXO2, CCNC, BAX, NF2, PMAIP1, SUPT20H, ADIPOR2.
- Named hits:

| Gene | Direction | BARCS rank | BARCS FDR |
|---|---|---|---|
| VAMP3 | negative | 6 | 2e-7 |
| RAB1A | negative | 9 | 3e-6 |
| SEC23IP | negative | 15 | 2e-5 |
| TRAPPC12 | negative | 68 | 0.004 |
| GOSR1 | negative | | 0.065 |
| ABHD17B | positive | 2 | 1e-25 |
| ABHD16A | positive | | 5e-7 |
| YKT6 | negative | | 0.97 (missed) |

## BARCS vs paper
| | Negative (depleted) | Positive (enriched) |
|---|---|---|
| Spearman correlation with qGI | 0.58 | 0.58 |
| Effect direction agreement | 69% | 69% |
| Top-50 overlap | 20 | 17 |
| Top-100 overlap | 39 | 32 |

The paper reports 413 negative and 405 positive interactions (|qGI| > 0.3, FDR < 0.1) in either minimal-medium screen. BARCS calls 156 and 151 of them.

Where they differ:
- YKT6 is significant in only one of the two published minimal-medium screens (GIN109, FDR 0.002). BARCS sees no effect.
- 46 BARCS calls are genes absent from Data S7, mostly the paper's excluded variable-fitness genes. Strong positive examples are the p53/apoptosis genes BAX, PMAIP1 and BBC3, plus NF2, TADA1, TADA2B, TSC1 and TSC2. Their loss gives a growth advantage whose size differs between cell lines and batches, so these calls are plausible line-specific suppression of a PTAR1 fitness defect, not artifacts of the counts. The paper's network excludes them by design.
- Paper-only calls include CTNNA1, RAB5C, PTP4A2 and USP7. BARCS gives them inconsistent effects across the three PTAR1 screens, which include the 1-bp insertion allele in GIN109.

## Limits
- One query.
- The WT reference set was chosen from Data S1, since the paper's exact reference is not given.
- No M-A/loess normalization.
- Endpoint passages are summed.
- GIN053 is not in the published per-screen columns.
