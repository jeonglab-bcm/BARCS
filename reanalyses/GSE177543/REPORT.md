# GSE177543 reanalysis with BARCS 0.2.3

**Paper.** Grodzki et al., "Genome-scale CRISPR screens identify host factors that promote human coronavirus infection", Genome Medicine (2022), PMID 35086559, doi:10.1186/s13073-022-01013-1 (PMC8792531). This is the paper's second HEK293T-hACE2 screen; GSE177537 and GSE177541 hold the others.

**Screen.** Brunello knockout library (77,441 guides, 1,000 non-targeting) in HEK293T-hACE2 cells infected with SARS-CoV-2 at MOI 0.3; survivors were sequenced at day 10. GEO holds Day-0, uninfected day-10 and day-15, and infected libraries in triplicate (integer reads, self-named). prepare.R builds the authors' MAGeCK table (Additional file 7, MOI 0.3 initial infection).

**Design.** `~ condition`, SARS-CoV-2 vs uninfected day-10 controls, 3 vs 3 (4 residual df). The paper says only "uninfected control library replicates"; median-normalized fold changes of its top genes match the day-10 controls better than Day 0, and these are time-matched. No pairing term.

**Checks.** 18% of non-targeting guides reached p < 0.05 before calibration, so run_barcs.R calibrated to the controls (5.0% after), which shortens the list. Composition is flat. The control null (centred on the controls, shift +0.06) calls 63 genes against the model's 41.

## Results

| | BARCS 0.2.3 | Authors (MAGeCK RRA, positive side) |
|---|---|---|
| Genes at FDR 0.10 | 41 (31 enriched, 10 depleted); 63 against the control null | 28 at FDR 0.10 |
| Named hits | TMEM251 #1, CTSL #2, CCZ1B #3, CCZ1 #4, CDH2 #8, ACE2 #17 (FDR <= 0.011), C18orf8 #25 (FDR 0.053) | CTSL, CCZ1B, TMEM251, ACE2, C18orf8, CCZ1, CDH2 |
| Rank correlation / top-20 overlap | 0.62 / 16 of 20 | |

## Where BARCS agrees and differs

- **Agrees.** All seven genes the paper names are BARCS calls at FDR 0.10 (C18orf8 just above 0.05), and the top four (TMEM251, CTSL, CCZ1B, CCZ1) are the endolysosomal entry factors the authors highlight. Sixteen of the top twenty genes are shared.
- **Differs slightly.** BARCS's calibration to the inflated control rate trims the list to the strongest effects; ACE2 ranks #17 rather than near the top because one of its four guides does not rise.

## Limits

- The reference group is inferred (the paper does not name it). Control calibration was needed.
