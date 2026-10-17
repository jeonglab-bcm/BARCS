# GSE298081 reanalysis with BARCS 0.2.3

**Paper.** Billmann, Costanzo et al. "Global genetic interaction network of a human cell maps conserved principles and informs functional interpretation of gene co-essentiality profiles", *Cell* 2026, PMID 42049019 (PMC13281610, doi:10.1016/j.cell.2026.03.044). SuperSeries GSE298085; this is the rich-medium (IMDM) sub-series. The minimal-medium sub-series is GSE298082.

**Screen.** About 360 genome-wide TKOv3 knockout screens (71,090 guides, 142 non-cutting EGFP/LacZ/luciferase controls) in HAP1 query knockout lines and parental wild-type (WT) cells. Each screen has a T0 library and three endpoint libraries (A/B/C, parallel passages of one infection, T10-T20). Genetic interactions (qGI) compare each query screen's dropout with a WT reference.

**What was reproduced.** There are hundreds of query screens, so this reanalysis takes the paper's showcase query, PTAR1. PTAR1 is the GGTase-III subunit that prenylates the SNARE YKT6. Its interactions are in Data S7 (per-screen qGI/FDR and a mean over four screens), and the paper discusses them in the text (YKT6; vesicle-trafficking negatives overlapping a gene-trap screen; suppression by ABHD16A and ABHD17B). PTAR1 was screened four times in rich medium: GIN003, GIN044, GIN288 and GIN298, the four used for the MCMC consensus. The reference is the 16 QC-passing parental WT rich-medium screens. The diploid WT clone GIN036 is excluded.

**Counts.** `GSE298081_gin_read_counts_matrix_rich.txt.gz` holds raw integer counts, one column per sequencing library (Moffat_<n>), with guide IDs `<gene>_<spacer>`. Blank cells are guides with no reads; the matrix contains no zeros and its minimum is 1. `prepare.R` does the following:
- maps libraries to screens with the paper's Data S1, which agrees with the GSM titles;
- writes blank cells as 0 and adds a Gene column;
- sums each screen's three endpoint libraries into one column `<GIN>_end`;
- takes two T0 columns that were deposited only in the minimal-medium matrix of GSE298082. These T0s were shared between a rich- and a minimal-medium screen of the same infection: Moffat_343_814 for WT GIN001 and Moffat_619 for PTAR1 GIN044.

Summing makes the screen (infection) the unit of replication, as in the paper's replicate analysis.

**Design.** `~ screen + phase + gi` on 40 columns (one T0 and one summed endpoint for each of 20 screens):
- `screen` absorbs each infection's T0 representation;
- `phase` is the common endpoint dropout;
- `gi` marks the PTAR1 endpoints. The tested term `giPTAR1_end` is the PTAR1-specific change in guide abundance beyond the WT dropout, the quantity qGI scores (negative = negative interaction).

The model has 18 residual df and the moderation prior df is 26.5. The design rests on Data S1. The one uncertainty is that screens ran to different endpoints (T10-T20). qGI corrects for this with an M-A loess normalization against the WT LFC, which BARCS does not apply.

**Checks.**
- Composition is normal: the top 1% of guides hold 2.3-3.3% of reads.
- Control calibration was applied: 9.3% of control guides had p < 0.05 before calibration, 5% after.
- Guide correlation is 0.039.
- The control null is centred on the controls (shift -0.23 z) and gives 1177 genes at FDR 0.10.
- Top BARCS-only calls (RPP25L, MECR, SUV39H1, TXNDC17) move in the same direction on most guides and across the four PTAR1 screens. They have no jackpots.

## Results
- 700 genes at FDR 0.10: 245 depleted (negative GI) and 455 enriched (positive GI).
- Top depleted: GOLGA7, VAMP3, RCE1, PICALM, RAB14, WDFY1, VAMP2, INO80D, SLC25A1, SS18. These are mostly Golgi/endosome trafficking genes, matching the paper's PTAR1 GO enrichment. RCE1 is the CAAX protease of the prenylation pathway.
- Top enriched: TAF3, ABHD17B, ARF1, ADIPOR2, PSMD6, CNOT4, TAF4, TMED2, SLC39A9, ABHD16A. PTAR1 itself is enriched (FDR 5e-6), as expected for a self-interaction.
- Named hits:

| Gene | Direction | BARCS FDR |
|---|---|---|
| VAMP3 | negative | 7e-8 |
| SEC23IP | negative | 0.0016 |
| GOSR1 | negative | 0.062 |
| ABHD17B | positive (rank 2) | 9e-13 |
| ABHD16A | positive | 4e-8 |
| RAB1A | negative | 0.13 (missed) |
| TRAPPC12 | negative | 0.16 (missed) |
| YKT6 | negative | 0.92, no effect (missed) |

## BARCS vs paper
The published table is the mean of the two rich-medium per-screen qGI scores in Data S7 (GIN003, GIN044). BARCS also uses GIN288 and GIN298.

| | Negative (depleted) | Positive (enriched) |
|---|---|---|
| Spearman correlation with qGI | 0.53 | 0.53 |
| Effect direction agreement | 68% | 68% |
| Top-50 overlap | 22 | 22 |
| Top-100 overlap | 44 | 36 |

The paper reports 626 negative and 564 positive interactions (|qGI| > 0.3, FDR < 0.1) in either rich-medium screen. BARCS calls 131 of those negatives and 200 of those positives. Of the four-screen MCMC consensus, BARCS recovers 105/316 negatives and 209/416 positives.

Where they differ:
- The paper discusses YKT6 as the mechanistic partner of PTAR1. Its published rich-medium qGI is weak (-0.65 and -0.25 in GIN003 and GIN044, FDR 0.087 and 0.80), and BARCS sees no effect.
- BARCS-only enriched calls include general fitness and transcription genes (TAF3, TAF4, CNOT4, PSMD6, EIF2B2). These are typical of a dropout-scale difference that qGI's loess normalization removes.
- 17 BARCS calls are among the 80 variable-fitness genes the paper dropped from Data S7, for example INO80D, KMT2A, HDAC3, CYB5R4 and KEAP1. HDAC3 and CYB5R4 head the paper's PTAR1 MCMC consensus profile (Data S5).
- Paper-only calls include RABGEF1, RAB5C, CTNNA1 and OAZ1. BARCS gives them small, inconsistent effects across the four screens.

## Limits
- One query of a ~360-screen network.
- The WT reference is all QC-passing parental rich-medium screens. The paper's exact WT reference set is not given.
- No M-A/loess normalization.
- Different endpoint times across screens.
- Endpoint passages are summed, so within-screen variation is not used.
- Calls are against non-cutting controls. These sit close to the targeting guides in this differential contrast.
