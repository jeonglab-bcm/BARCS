# GSE264535 reanalysis with BARCS 0.2.3

**Paper.** "Exogenous RNA surveillance by proton-sensing TRIM25", *Science* 2025, PMID 40179174 (doi:10.1126/science.ads4539; not open access).

**Count recovery.** Only a normalized table was deposited (`GSE264535_normed-count.txt.gz`). It is raw reads times one scale per library plus a pseudocount of 1: after subtracting 1, every value of every one of the 30 columns is an integer multiple of the column's smallest value (integrality 100%, max deviation < 1e-11; scales 0.024-0.032). `prepare.R` runs `tools/screen-reanalysis/recover_counts.R` with `RECOVER_OFFSET=1` and checks the recovered totals against `recovery_scales.json`; recovered libraries hold 31-42 M reads.

**Screen.** HCT116 Brunello KO cells (77,441 guides, 1,000 non-targeting controls) treated with LNP-delivered GFP mRNA, either unmodified (UTP) or N1-methylpseudouridine (N1m), plus a stable-GFP cell line as cellular control; cells sorted on GFP into the top 0-2.5%, top 2.5-5%, bottom 2.5-5% and bottom 0-2.5%, with an unsorted input, two replicates each. Column names (`utp_bri_2_5_1` ..) match the GSM titles; that `2_5` denotes the outer 0-2.5% bin is inferred from the names and supported by TRIM25 guides being more enriched in `bri_2_5` than in `bri_5`.

**Design.** For each mRNA, the outer GFP-high bin and the outer GFP-low bin are compared with the unsorted input of the same mRNA (`~ bin`, 2 vs 2, 2 residual df, moderated). Enrichment in GFP-high = suppressors of exogenous mRNA; enrichment in GFP-low = factors needed for LNP uptake, endosomal escape or translation. A replicate term would pair each sort with its own input but leave 1 residual df, so it was left out. The stable-GFP control line was not analyzed.

**Checks.** Composition normal (top 1% of guides hold 3.4-4.9% of reads). Controls well calibrated without adjustment (4.9-5.5% at p < 0.05), control shift 0.07-0.12 z (null centred on controls). Guide correlation < 0.005. TRIM25's four guides are enriched consistently in both GFP-high replicates (e.g. 3,280 and 3,905 reads vs 641 and 581 in the inputs), not from one jackpot.

## Results
| Analysis | FDR 0.10 | Control null | Top genes |
|---|---|---|---|
| UTP GFP-high vs input | 2 | 7 | **TRIM25** (#1, FDR 0.003), **N4BP1** (#2, FDR 0.053) |
| UTP GFP-low vs input | 24 (14 enriched) | 34 | ATP6V0C, ATP6V1A, ATP6AP1, SRPR, ATP6V0D1, ATP6V1B2, ATP6AP2, SLC35B2, EXTL3 |
| N1m GFP-high vs input | 0 | 0 | TRIM25 rank 4,467 (FDR 0.94) |
| N1m GFP-low vs input | 35 (22 enriched) | 58 | ATP6AP1, ATP6V0D1, ATP6V1A, ATP6V0C, ATP6V0B, SLC35B2, SRPR, ATP6V1B2, EXT1, B4GALT7, NDST1, EXTL3 |

- **TRIM25** is the top suppressor of unmodified mRNA, with **N4BP1** second; KHNYN (rank 6,448) and ZAP/ZC3HAV1 (rank 131) are not called on their own, which fits the paper's finding that N4BP1, KHNYN and ZAP act redundantly.
- With N1m-modified mRNA nothing is enriched in the GFP-high bin and TRIM25 is neutral, as the paper predicts (N1m reduces TRIM25 binding).
- **V-ATPase** subunits (ATP6V0C, ATP6V1A, ATP6AP1, ATP6V0D1, ATP6V1B2, ATP6AP2, ATP6V1G1, ATP6V0B, ATP6V1D) and **heparan-sulfate synthesis** genes (SLC35B2, EXTL3; plus EXT1, NDST1 and B4GALT7 for N1m) dominate the GFP-low bins for both mRNAs. That matches the paper's uptake (HSPG) and endosomal-escape (V-ATPase) factors. EXT1 passes FDR 0.10 only in the N1m screen (FDR 0.002; UTP FDR 0.5).

## BARCS vs paper
The paper's supplementary tables are behind the Science paywall, so the comparison is to the genes it names. Every main claim the screen supports is reproduced: HSPG and V-ATPase in the GFP-low bins, TRIM25 (and N4BP1) as the suppressor of unmodified but not N1m-modified mRNA. The paper's own gene-level statistics could not be compared directly.

## Limits
Counts recovered from a normalized table (exact). Two replicate sorts per bin and 2 residual df. The bin labelling (outer vs inner 2.5%) is inferred from sample names. The stable-GFP control, which separates LNP-specific factors from general GFP-expression factors, was not analyzed, so genes such as SRPR and COPA in the GFP-low bins may reflect GFP expression or secretion in general.
