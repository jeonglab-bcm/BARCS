# GSE242880 reanalysis with BARCS 0.2.3

**Paper.** Pimentel, Freimer, Arce, Garrido, Marson and Pritchard, "A model for accurate quantification of CRISPR effects in pooled FACS screens", bioRxiv (2024), PMID 38948774, doi:10.1101/2024.06.17.599448 (PMC11213010). A methods paper introducing Waterbear, a Bayesian random-effects model for FACS-sorted CRISPR screens.

**Screen.** The authors repeated their earlier CD25 (IL2RA) screen in primary human CD4+ T cells (Freimer et al. 2022, GSE171674). They used the same ~1,350-gene transcription-factor knockout library (6,000 guides, 4 per gene, 593 non-targeting). Cells from 3 donors were sorted into four CD25 bins (Q1 lowest to Q4 highest). This was done at high coverage (~1,660x at MOI 0.3, ~1,180x at MOI 2) and low coverage (~200x), each at low (0.3) and high (2) MOI. The claim: with Waterbear, the cheap low-coverage, high-MOI screen keeps most of its power. Waterbear calls 79 of 1,350 genes, including 24 of 26 regulators validated by individual knockouts in the 2022 paper. MAGeCK calls 31 genes (17/26) and MAUDE 406 (25/26).

The count file is the GEO supplementary file as deposited. It holds integer reads, and its columns are named exactly as the GSM titles. Bin order was confirmed from the counts: IL2RA and STAT5B guides are enriched in Q1 and MYB guides in Q4.

**What the paper reports.** The preprint publishes no gene-level table (the Europe PMC supplement holds figures only, and the Waterbear GitHub repository holds code only). The comparison therefore uses named hits: the IL2RA regulators the 2022 paper validated and named (IL2RA, JAK3, STAT5A, STAT5B, MED12, CBFB, TNFAIP3, KLF2, ZNF217, FOXK1, HIVEP2, IRF4, ATXN7L3), plus MYB, whose knockout raises CD25. The full list of 26 validated genes is in the preprint's supplementary section, which could not be retrieved, so the named hits cover 13 of the 26.

**Design.**
1. *Primary:* low coverage, high MOI, Q4 vs Q1, `~ donor + bin`, 6 libraries, 2 residual df.
2. *Second:* high coverage, low MOI (the reference condition), the same model.

All bins of one donor come from one edited pool, so donor is paired. Waterbear uses all four bins and the unsorted GFP+ reference. BARCS compares only the two outer bins, so it uses about half the data.

**Calibration.**
- *Low coverage:* 6.1% of non-targeting guides reach p < 0.05, so no calibration was applied. The non-targeting guides sit +0.29 z from the targeting guides, so the control null was centred on the targeting guides. It calls 70 genes against the model's 82.
- *High coverage:* 6.2% of controls reach p < 0.05. The control null, centred on the controls (shift +0.23 z), calls 134 genes against the model's 107. Because the controls are offset, that 134 overstates the null count, and the model's number is the one to quote.

Composition is flat (2.3–2.8% of reads on the top 1% of guides), and the guide correlation is 0.013–0.015.

## Results

| | BARCS, low cov. / high MOI | BARCS, high cov. / low MOI | Paper, low cov. / high MOI |
|---|---|---|---|
| Genes at FDR 0.10 | 82 (45 up, 37 down in CD25-high) | 107 (56 / 51) | Waterbear 79; MAGeCK 31; MAUDE 406 |
| Against the control null | 70 (centred on targets) | 134 (controls offset; not quoted) | |
| Named hits at FDR 0.10 | 13/14 | 14/14 | 24/26 validated hits (Waterbear) |

Named-hit ranks in the low-coverage screen (of 1,350 genes) are:
- **Higher in CD25-high when knocked out (negative regulators):** MED12 #1, MYB #2, HIVEP2 #3, CBFB #5, KLF2 #7, TNFAIP3 #9, FOXK1 #10, ZNF217 #13, ATXN7L3 #23.
- **Lower in CD25-high when knocked out (positive regulators):** STAT5B #4, IL2RA #6, STAT5A #14, JAK3 #37.
- **Missed:** IRF4 ranks #131 (FDR 0.25) at low coverage. It is called at high coverage (#39, FDR 7e-5).

Other top calls are known T-cell regulators: IRF1, IKZF1, IRF2, LEF1, FOXO1, FOXP1, PRDM1, BCL11B, ETS1 and RELA.

**Consistency across conditions and with the original screen.**
- 55 of the 82 low-coverage calls are also called at high coverage.
- 52 of the 82 are among the 126 BARCS calls on the original 2022 CD25 high/low screen (GSE171674 record).
- Across all genes, the two conditions' statistics correlate only modestly (Spearman 0.32), because most genes have no effect.

## Where BARCS agrees and differs

- **Agrees.** The paper's experimental claim holds under BARCS. The low-coverage, high-MOI screen recovers the validated regulators: 13 of the 14 named genes at FDR 0.10, 12 of them in the top 25. Its hit count (82) is close to Waterbear's (79) and well above MAGeCK's (31). The strongest hits rank almost identically at high and low coverage.
- **Differs.**
  - IRF4 is missed at low coverage (FDR 0.25), one of the 2 of 26 that Waterbear also missed.
  - 22 low-coverage calls are found neither at high coverage nor in the 2022 screen. They are small effects (|estimate| 0.14–0.46), many on transcription factors that are probably not expressed in T cells (FEZF1, NKX6-3, DLX6, HNF1A, PAX8, NR1I2). Their four guides shift together, without jackpots: for example, PAX8 guides read 1,246–3,941 in Q1 and 1,338–5,110 in Q4. At ~200x cells per guide spread over four bins, such shifts are plausibly sorting noise that read depth cannot reveal. The control null (70 genes) suggests about a dozen of the 82 are of this kind.
  - Using only Q1 and Q4 loses the information in the middle bins, which Waterbear uses.

## Limits

- No gene table from the paper. The comparison is with named, previously validated hits, and only 13 of the paper's 26 validated genes could be identified.
- Two of four bins are analyzed. The GFP+ reference and the high-coverage, high-MOI and low-coverage, low-MOI conditions are not.
- There are 2 residual df per analysis (3 donors, paired).
