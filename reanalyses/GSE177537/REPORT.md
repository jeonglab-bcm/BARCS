# GSE177537 reanalysis with BARCS 0.2.3

**Paper.** Grodzki et al. 2022, Genome Medicine, PMID 35086559, doi:10.1186/s13073-022-01013-1 (PMC8792531). First HEK293T-hACE2 screen of the paper; GSE177541 and GSE177543 hold the others.

**Screen.** Brunello library (77,441 guides, 1,000 non-targeting) in HEK293T-hACE2 cells infected with SARS-CoV-2 or OC43 at MOI 0.01; survivors sequenced. Integer counts as deposited; prepare.R builds the authors' MAGeCK tables for the initial infections (Additional files 6 and 8).

**Design.** ~ condition, infected vs Day 0: SARS-CoV-2 4 vs 4 (library totals, flat composition) and OC43 5 vs 4. The OC43 libraries are dominated by few guides (top 1% hold 82-86% of reads), so that analysis uses median-ratio totals and only enrichment is read; its depleted calls reflect dropout and composition, not the virus.

**Checks.** Controls were inflated before calibration (27% and 21% at p < 0.05) and run_barcs.R calibrated both analyses to 5%. Controls sit 0.7-0.85 z above the targeting guides, so the control null is centred on the targeting guides; its counts are larger than the model's and are not quoted as hits.

## Results

| | BARCS 0.2.3 | Authors (MAGeCK RRA) |
|---|---|---|
| SARS-CoV-2 enriched at FDR 0.10 | 33 (after calibration) | ranked list, FDR 0.25 cutoff |
| SARS-CoV-2 named hits | EDC4 #1, DNM2 #5, TMEM251 #6, CDH2 #7, WASL #9, CCZ1 #18, XRN1 #27 (all FDR <= 0.072) | EDC4 top, XRN1, CCZ1, DNM2, WASL |
| SARS-CoV-2 rank corr / top-20 overlap | 0.77 / 15 of 20 | |
| OC43 enriched at FDR 0.10 | 7 (median-ratio totals) | ranked list |
| OC43 named hits | VMP1 #1 (FDR 0.05), SLC35B2 #4, CCZ1B #5 (FDR < 0.1), TMEM41B #10 (0.11), WDR81 #19, CCZ1 #94 | TMEM41B, VMP1, CCZ1B, SLC35B2, WDR81 |
| OC43 top-20 overlap | 18 of 20 | |

## Where BARCS agrees and differs

- **Agrees.** EDC4, the paper's overall top SARS-CoV-2 gene, is #1 in BARCS, and all seven named SARS-CoV-2 genes pass FDR 0.10 (XRN1 at 0.072). For OC43, 18 of the top 20 genes are shared, and VMP1, SLC35B2 and CCZ1B are calls; TMEM41B is #10 at FDR 0.11.
- **Differs.** The OC43 libraries are strongly bottlenecked, so the rank correlation over all genes is low (0.13) even though the tops agree, and the large depleted set in the OC43 analysis is dropout over the long selection, not a virus effect. Control calibration shortens both lists.

## Limits

- Strong post-infection bottlenecks (OC43 especially); inflated controls needed calibration; reinfection libraries are not analyzed.
