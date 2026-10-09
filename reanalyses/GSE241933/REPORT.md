# GSE241933 reanalysis with BARCS 0.2.2

**Paper.** "Transcriptional and epigenetic regulators of human CD8+ T cell function identified through orthogonal CRISPR screens", *Nature Genetics* (2023), PMID 37945901, doi:10.1038/s41588-023-01554-0 (PMC10703699).

**Screens.** This SubSeries holds every sort-based screen in the paper. Two are reanalyzed here.

1. *Primary: CRISPRa TF screen.* dSaCas9-VP64 with 1,979 guides tiling the promoters (±500 bp) of 120 transcription factors and epigenetic regulators (about 16 per gene), plus 120 non-targeting (NT) guides. Primary human CD8+ T cells from three donors were sorted into CCR7-high and CCR7-low bins. The paper ran DESeq2 per guide (paired by donor), then built gene scores from the guide p-values: each p was transformed against the 120 NT guides, and the guides' fold changes were averaged with weights from the transformed p. Its Supplementary Table 2F gives 14 genes at adjusted p < 0.10, led by BATF, BATF3 and EOMES (gene effect −0.92, −0.78, −0.99, all on the CCR7-low side). This table is the published comparison.
2. *Secondary: TFome knockout screen with BATF3 overexpression.* 6,450 guides (about 4 per TF) plus 550 NT guides, sorted into IL7R-high and IL7R-low bins, two donors. The paper ran MAGeCK test (paired, NT controls) and published its gene table (Supplementary Table 6D). It named BATF3, JUNB and IRF4 as BATF3-dependent hits in IL7R-low (cofactors), and ZNF217, GATA3 and AHR as IL7R-high hits. The same screen without BATF3 overexpression was also run, for context.

Count tables are the deposited CSVs, with the gene taken from the guide name. Column names (Low_D1..High_D3) match the GSM titles. All values are integers.

**Design.** CRISPRa: `~ donor + sort`, CCR7-high vs CCR7-low, 6 libraries, 2 residual df (each donor gave one sort into both bins). KO: `~ donor + sort`, IL7R-high vs IL7R-low, 4 libraries, **1 residual df**.

**Calibration and controls.** CRISPRa: 9.2% of NT guides reached p < 0.05, so the test was calibrated to the controls (5.0% after). There is no control offset (0.03 z), and the control null is centred on the controls. Composition is unremarkable (top 1% of guides hold 2–8% of reads). KO with BATF3: 20.4% of NT guides reached p < 0.05, calibrated to 4.9%. The NT guides sit 0.52 z from the targeting guides, so the control null is centred on the targeting guides. KO without BATF3: 6.6%, not calibrated.

## Results

| | BARCS | Paper |
|---|---|---|
| **CRISPRa CCR7** genes at FDR 0.10 | 2 (BHLHE41, HIC1, both CCR7-high); 6 against the control null (adds BACH1, FLI1, STAT5B, NFKB2) | 14 at adjusted p < 0.10 |
| BATF3 | #57 of 120, gene estimate +0.02, FDR 0.67 | #2, effect −0.78 (CCR7-low), adjusted p ≈ 0 |
| BATF / EOMES | #90 (FDR 0.78) / #34 (FDR 0.37) | #1 / #3 |
| Rank correlation with the paper's gene table | −0.01; top-14 overlap 1 | |
| **KO + BATF3, IL7R** genes at FDR 0.10 | 38 (30 depleted in IL7R-high); 39 against the control null | MAGeCK: 276 IL7R-low genes at FDR 0.10 |
| IL7R (positive control) | #1 depleted, FDR 5 × 10⁻⁷ | rank 1 |
| BATF3 | #12 depleted, FDR 0.008 | rank 7 |
| IRF4 / JUNB | #40 (FDR 0.15) / #111 (FDR 0.35) | named cofactors |
| ZNF217 / GATA3 / AHR | the three most enriched in IL7R-high (FDR ≤ 1 × 10⁻⁴) | validated IL7R-high hits |
| Rank correlation with MAGeCK (depleted) | 0.74; top-25 overlap 20 | |

In the KO screen without BATF3, BATF3 is neutral (FDR 0.98), as are IRF4 and JUNB. IL7R, FOXO1, ZNF217, GATA3 and AHR are called as in the BATF3 screen (80 genes at FDR 0.10; 53 against the control null). This matches the paper's point that the BATF3, IRF4 and JUNB effects depend on BATF3 overexpression.

## Direction of BATF3 in the CRISPRa screen

The paper's own gene table puts BATF3 activation on the **CCR7-low** side (gene effect −0.78), and its BATF3-overexpression RNA-seq shows CCR7 lowered (log2 FC −0.40, adjusted p 0.012). The "memory-like" claim rests on IL7R and other genes, not on CCR7. So the triage observation (BATF3 enriched in CCR7-low) agrees with the paper; it is not a contradiction. In BARCS the three BATF3 guides the paper calls (BATF3_2, _4, _18) point the same way: BATF3_2 drops about 7-fold into CCR7-low in all three donors (estimate −2.04, beyond every NT guide, whose largest |estimate| is 1.09).

## Where BARCS agrees and differs

- **KO screen: agrees.** IL7R, BATF3, FOXO1, DNMT1 and the IL7R-high hits ZNF217, GATA3 and AHR are all strong BARCS calls, and BARCS's ranking tracks MAGeCK's closely (Spearman 0.74, 20 of the top 25 shared). BARCS's list is much shorter (38 vs 276 at FDR 0.10), as expected with 1 residual df and calibration to NT controls that were too tight (20% at p < 0.05 before calibration). IRF4 and JUNB, the two named cofactors, rank #40 and #111 but miss FDR 0.10. BARCS-only and MAGeCK-only genes in the top 25 are near-misses on both sides (for example KAT7 #15 / 26), except NANOGNB and ZNF506 (MAGeCK 19 and 23, BARCS ~1,285). These likely rest on one guide each, which RRA can rank highly.
- **CRISPRa screen: differs.** Guide by guide, BARCS and the paper's DESeq2 agree almost perfectly (Spearman 0.96 of guide statistics across 2,099 guides). The disagreement is at gene level. In a CRISPRa promoter-tiling library only the few guides near the transcription start site work: 3 of 18 for BATF3, 3 of 16 for BATF, 2 of 13 for EOMES. BARCS combines all guides of a gene with a Stouffer sum, which dilutes three strong guides with fifteen null ones (BATF3 gene estimate +0.02). The paper's gene score is weighted toward the guides with the smallest p, which suits tiling. BARCS's own top genes, BHLHE41 and HIC1, are the opposite case: a small shift shared by most of 21 and 27 guides (median guide estimates about +0.3), none of which is strong alone. Guide-level p-values are also larger in BARCS than in DESeq2 (BATF3_2: 0.0024 vs 3 × 10⁻¹⁷) because BARCS calibrates to the NT guides. At the guide level, no guide passes FDR 0.10.

## Limits

- CRISPRa gene-level calls depend on how tiling guides are combined; BARCS's Stouffer combination is not suited to libraries where most guides of a gene are inactive by design. The guide-level evidence for BATF3, BATF and EOMES is strong and in the paper's direction.
- KO screen: 2 donors and 1 residual df; the dispersion prior carries the variance estimate, and the NT controls were too tight before calibration.
- The CRISPRi TF screen (2 donors) and the regulatory-element tiling screens in the same series were not reanalyzed.
