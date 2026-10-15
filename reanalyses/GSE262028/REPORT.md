# GSE262028 reanalysis with BARCS 0.2.3

**Paper.** "Mef2d potentiates type-2 immune responses and allergic lung inflammation", *Science* (2024), PMID 38935708, doi:10.1126/science.adl0370 (PMC7616247).

**Screen.** A knockout library against 1,131 mouse transcription factors (4,732 guides, 4 per gene, 200 non-targeting). The library was transduced into innate lymphoid cell (ILC) progenitors from Cas9 reporter mice, which were then differentiated in vitro and sorted. Two screens (S17, S25) sorted on an Il13-tdTomato reporter and two (S31, S35) on GATA3 and T-bet reporters. The authors ran a Wilcoxon test (caRpools) per screen against the non-targeting guides and combined the two screens of each type with Fisher's method. Their gene-level table (Data File S1) is on science.org, which this pipeline cannot download. The comparison therefore uses the regulators named in the text: Mef2d, Zfp871, Nfkb2, Nfe2 and Gfi1b as positive regulators of IL-13, Runx3, Tcf12, Nfil3, Fli1 and Zbtb7a as negative ones, and 13 candidate GATA3 regulators. Mef2d is the paper's subject.

**Counts.** GEO holds four multiplexed count files (`*_lib_data.csv.gz`, one shared library) plus lists that name each pool. The lists also flag the two pools of each screen that the authors compared (`Screen` and `Bin` = P/N). `prepare.R` takes exactly those eight pools and merges them on guide ID:

- S17: `tomp` vs `linn`;
- S25: `Tp` vs `Neg`;
- S31: `ILC2` vs `NK`;
- S35: `GATA3` vs `TBET`.

The GSM titles alone would suggest otherwise for two screens: S25 negative could be `S25_Tn` and S31 T-bet could be `S31_ILC1`. The GSM characteristics also contradict their own titles ("GATA3 negative" for GATA3_pos). The authors' flags were followed. They are supported by the result: 8 of the paper's 10 named IL-13 regulators are in the BARCS top 10.

**Design.** `~ screen + population`, positive vs negative sort, for IL-13 (S17 and S25) and for GATA3 vs T-bet (S31 and S35). The two populations of a screen are sorted from one infected culture, so screen is paired. Each analysis has 4 libraries and 1 residual df. Moderation adds little for IL-13 (prior df 1.2) and fully pools the dispersion trend for GATA3 (prior df infinite). Non-targeting guides were well calibrated without adjustment (2.5% and 4.6% at p < 0.05). The top 1% of guides hold 8–15% of reads, as expected for a sorted focused library. Guide correlations are 0.006 and 0.016.

## Results

| | IL-13 screen (Tom+ vs Tom−) | GATA3 screen (GATA3+ vs T-bet+) |
|---|---|---|
| Genes at FDR 0.10 (model) | 0 (lowest FDR 0.15) | 36 (14 depleted, 22 enriched) |
| Genes at FDR 0.10 (control null, centred on controls) | 18 | 44 |
| Mef2d | #2 of 1,131 (two-sided), p 3e-4, FDR 0.15, control-null FDR 0.011 | depleted #52, FDR 0.25 |
| Named regulators in BARCS top 10 | 8 of 10 (Fli1 #1, Mef2d #2, Runx3 #4, Zfp871 #5, Tcf12 #7, Nfe2 #8, Nfkb2 #10); Gfi1b #24, Nfil3 #32, Zbtb7a #34 | Maf #1, Runx1 #4, Myb #5, Zfy2 #6, Arnt2 #7, Mitf #11, Pbx4 #13 depleted |
| Named regulators at FDR 0.10 | 0 of 10 (model); 9 of 10 against the control null | 7 of 13 (model): Maf, Runx1, Myb, Zfy2, Arnt2, Mitf, Pbx4 |
| Controls | | Tbx21 knockout enriched in GATA3+ (#1 overall, FDR 8e-8); Bcl11b depleted (#8, FDR 0.012) |

## Where BARCS agrees and differs

- **Agrees on the ranking.** In the IL-13 screen, BARCS's top genes are the paper's named regulators with the paper's signs. Mef2d, Zfp871, Nfe2 and Nfkb2 are depleted in Tom+; Fli1, Runx3 and Tcf12 are enriched. In the GATA3 screen, BARCS calls 7 of the 13 named GATA3 candidates and the known ILC2 regulators Maf and Bcl11b. Tbx21 knockout shifts cells out of the T-bet+ population, which validates the sort.
- **Differs on certainty.** With two paired screens (1 residual df) and weak moderation, no IL-13 gene passes the model's FDR 0.10. The control null passes 18 genes, including Mef2d (FDR 0.011) and 8 other named regulators. Here the null is the stronger evidence, but it rests on 200 non-targeting guides. The authors' Fisher combination treats each screen's Wilcoxon p-value as exact, which gives more calls from the same two screens. In the GATA3 screen, Mef2d is depleted (#52) but not called: its guides are depleted in S31 and mixed in S35.

## Limits

- Two screens per readout, 1 residual df. Screen-to-screen variation is barely estimated, so FDR values for the IL-13 screen are conservative.
- The pool assignment follows the authors' P/N flags in the deposited screen lists, not the GSM titles. Several other sorted pools sit in the same files (S16, S18, S19, S27, S28, S32) but are not linked to GSMs and were not used.
- The paper's gene-level table could not be retrieved, so the comparison uses only the genes named in the text.
