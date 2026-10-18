# GSE268342 reanalysis with BARCS 0.2.3

**Paper.** Tsung, Liu, Han et al., "CRISPRi screen of long non-coding RNAs identifies LINC03045 regulating glioblastoma invasion", *PLoS Genetics* (2024), PMID 38857306, doi:10.1371/journal.pgen.1011314 (PMC11192328).

**Screen.** U87 glioblastoma cells expressing dCas9-KRAB were transduced with the U87 sublibrary of CRiNCL: 2,307 lncRNA TSSs, 10 guides each (a few have 20), and 450 non-targeting guides. The cells were then seeded in Matrigel Boyden chambers for 24 h. The non-invading cells left in the top chamber ("After") were sequenced with the input population ("Before"), in two screen replicates. Knockdowns that reduce invasion are enriched in the top chamber. The authors scored each lncRNA by the mean phenotype of its top three guides times −log10 of a Mann-Whitney p against the non-targeting guides. They report 45–48 hits and focus on LINC03045 (CRiNCL annotation LH02236), with ZNF215-AS1 (LH02727) as a second candidate. No gene-level table is published, so only the named hits can be compared.

**Counts.** GEO has one integer count table (sgId plus four libraries, 32–122 M reads) without gene labels. `prepare.R` adds the CRiNCL "LH" gene annotation from the Horlbeck/Liu library table (ScreenProcessing, pinned commit). All 24,030 guides match.

**Design.** After vs Before, `~ condition`, two libraries per arm, 2 residual degrees of freedom. The replicate numbers are shared between arms, but the correlations show no pairing (After_Rep_5 correlates with Before_Rep_6 at 0.94 and with Before_Rep_5 at 0.90), so no replicate term is used. Library totals; the top 1% of guides hold 2.2–2.5% of reads, so there is no bottleneck.

**Checks.** The raw control rate at p < 0.05 was 10.2%. `run_barcs.R` calibrated to the 450 non-targeting guides (scale 1.17), which brings it to 4.9%. The controls sit 0.25 z above the targeting guides, so the control null is centred on the targeting guides. Dispersion moderation applied (prior df 71). Guide correlation is 0.018. The top genes' 10 guides move together, with no jackpots.

## Results

| | BARCS | Paper |
|---|---|---|
| Hits | 5 genes at FDR 0.10, all enriched in the non-invading cells; 1 against the centred control null (empirical FDR 0.09) | 45–48 lncRNAs at Mann-Whitney p < 0.01 / threshold |
| LINC03045 (LH02236) | #2, estimate +0.25, p 9e-5, FDR 0.083; all 10 guides up (empirical FDR 0.11) | top candidate, validated |
| ZNF215-AS1 (LH02727) | #4, FDR 0.086 (empirical 0.11) | second candidate |
| Other BARCS calls | LH11271 (#1, FDR 0.006), LH02000, LH05145 | not named |

## Where BARCS agrees and differs

- **Agrees.** Both lncRNAs the paper follows up are among BARCS's five calls at FDR 0.10 and rank second and fourth of 2,307, with every guide shifted the same way.
- **Differs.** BARCS calls 5 genes where the paper reports about 45. The effects are small, about a 28% increase in the non-invading fraction. The 24 h invasion assay retains most cells in the top chamber, which compresses the dynamic range. The paper's score uses the best three guides and a per-gene Mann-Whitney test without correction for 2,307 tests. BARCS uses all ten guides and controls the FDR across genes. The control null, centred on the targeting guides, confirms only the strongest gene at 0.10, and LINC03045 and ZNF215-AS1 sit just above it (0.11).

## Limits

- No published gene-level table, so only the named hits can be compared.
- Two replicates per arm, and the noise needed calibration to the controls (10% → 5% at p < 0.05), so the calls sit close to the threshold.
- The comparison is non-invading vs input, not invaded vs non-invaded cells. Proliferation over the short assay cannot be separated from invasion, although the paper's MTT assay found no growth effect of LINC03045 knockdown.
