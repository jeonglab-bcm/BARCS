# GSE179799 reanalysis with BARCS 0.2.3

**Paper.** Jones, Scholtes, Goodspeed et al., "NPEPPS Is a Druggable Driver of Platinum Resistance", *Cancer Research* (2024), PMID 38535994, doi:10.1158/0008-5472.CAN-23-1976 (PMC11094426). The GEO title calls it the "CRISPR Synthetic Lethal Screen" for the NPEPPS study.

**Screen.** Whole-genome CRISPR knockout screens in bladder cancer cell lines (253J, T24, TCCSUP, KU1919, 5637), treated with gemcitabine + cisplatin (GC) or saline and sequenced across timepoints. Genes whose knockout sensitises cells to GC deplete from the GC arm. The paper reports 46 genes that sensitise the resistant lines to GC, "most involved with DNA damage and repair pathways", and highlights NPEPPS as the novel, druggable hit. The custom library names guides GENE_position_sense with about four guides per gene and no non-targeting guides.

**Counts.** One combined matrix (GEO) of 76,403 guides across 90 samples. `prepare.R` sets the gene to the guide-name prefix (19,095 genes). All integer.

**Design.** The cleanest arms are KU1919 and 5637, each with three replicates of GC and three of Saline at the day-15 endpoint. The primary analysis pools both lines with a cell-line term (`~ cell + condition`, 9 residual df); per-line analyses (`~ condition`, 4 df each) are also run. Direction depleted (sensitisers). The 253J/T24/TCCSUP columns are combined-run files with a mixed replicate structure and are left out. Library totals; the top 1% of guides hold about 4.5% of reads (no bottleneck); guide correlation ~0.

**Checks.** No non-targeting guides were deposited, so control calibration and the control null cannot be checked. The top genes are driven by all four guides moving together, no jackpots.

## Results

| Contrast | Genes at FDR 0.10 (depleted / enriched) | NPEPPS |
|---|---|---|
| KU1919 GC vs Saline (3 v 3) | 55 / 6 | #5, estimate −1.08, FDR 5e-5 |
| 5637 GC vs Saline (3 v 3) | 278 / 36 | #3, estimate −2.74, FDR 1e-20 |
| Both lines (cell + condition) | 178 / 23 | #4, estimate −1.54, FDR 3e-15 |

Top depleted genes in the pooled analysis: UBE2T, RAD18, MUS81, NPEPPS, XPA, FANCA, FAAP100, CENPX, RFWD3, ERCC8, FANCB, UVSSA, FAAP24, BRIP1. These are the Fanconi-anaemia / translesion-synthesis / nucleotide-excision-repair machinery, exactly the "DNA damage and repair" signal the paper describes.

## Where BARCS agrees and differs

- **Agrees.** NPEPPS, the paper's named hit, is a top-5 sensitiser in every contrast, and the depleted list is dominated by the DNA-damage-and-repair genes the paper reports. The two cell lines agree on the leading genes.
- **Differs.** No published gene-level table is available (the paper is not open access), so only the named hits can be compared; the 46-gene meta-analysis list could not be matched row by row. The two lines differ in list length (55 vs 278 at FDR 0.10): the 5637 screen separates GC from Saline more sharply (NPEPPS estimate −2.7 vs −1.1), so more genes clear FDR. BARCS's pooled hit count (201) is the replicate-aware equivalent of the paper's per-line MAGeCK; without the paper's exact cross-line model and its vehicle/T0 anchoring, the counts are not directly comparable.

## Limits

- No non-targeting controls: calibration and the control null could not be checked.
- Only two of the five cell lines have a clean three-replicate GC/Saline endpoint; the others were not analysed.
- The published 46-gene list is behind a paywall, so the comparison rests on the named hits and the pathway signal, not a full table overlap.
