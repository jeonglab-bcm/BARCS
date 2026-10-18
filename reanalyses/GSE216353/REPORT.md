# GSE216353 reanalysis with BARCS 0.2.3

**Paper.** "Metabolic Reprogramming via ACOD1 depletion enhances function of human induced pluripotent stem cell-derived CAR-macrophages in solid tumors", *Nature Communications* (2023), PMID 37723178, doi:10.1038/s41467-023-41470-9 (PMC10507032).

**Screen.** A human metabolic-gene knockout library (about 2,980 genes, 30,198 guides, 499 INTERGENIC non-targeting) in Cas9 THP-1-derived macrophages (tMAC), stimulated with LPS+IFN-gamma and sorted into CD80-high and CD80-low pro-inflammatory bins (one library per bin). An iPSC-macrophage (iMAC) arm was run the same way. The authors ranked sgRNA-targeted genes by enrichment in each bin (Supplementary Fig. 1f); there is no gene-level MAGeCK table in the supplement.

**Design.** `~ bin`, CD80-high vs CD80-low, one library per bin, so the no-replicate path pools the overdispersion over the intergenic guides; calls are screening-level. A positive estimate means the knockout raises CD80 (the paper's CD80-high enriched genes), a negative one lowers it (CD80-low enriched). The iMAC arm is not analyzed: its deposited bin labels are internally inconsistent (the GSM titles swap CD80 high/low relative to the filenames, and both deposited file headers read "high").

**Checks.** Non-targeting guides at p < 0.05 are 0.5%, so BARCS is conservative here. The overdispersion is large (inflation 510 at rho = 0), as expected when a single sorted library per bin carries all the biological and technical noise. Composition is moderately skewed (top 1% of guides hold 9-10% of reads). Controls sit within 0.05 z of the targeting guides.

## Results

| | BARCS 0.2.3 | Paper (Supplementary Fig. 1f, tMAC) |
|---|---|---|
| Genes at FDR 0.10 | 0 (0 against the control null) | ranked top-20 lists per bin (sgRNA-level, no FDR shown) |
| Direction of the paper's named genes | all correct: KEAP1, NFKB1, NDUFS6, MPST depleted in CD80-high (lower CD80); B3GNT8, ST3GAL6, NANS, ULK1, GCLM enriched (raise CD80) | — |
| Named-gene ranks in BARCS | KEAP1 #960, NFKB1 #1504, NDUFS6 #270, B3GNT8 #820 of 2,966 | top 20 |

## Where BARCS agrees and differs

- **Direction agrees, significance does not.** Every one of the paper's highlighted genes moves in the direction BARCS expects, and the effect sizes are large (KEAP1 −6.9, NFKB1 −7.2, B3GNT8 +7.2 on the log scale). But with one library per bin and an overdispersion pooled over the controls, each of those large effects also has a large standard error, so their p-values are 0.4-0.85 and nothing passes FDR 0.10. The paper ranked sgRNAs (several guides per gene) by enrichment rather than fitting a gene-level dispersion; that surfaces KEAP1 and NFKB1 that BARCS leaves mid-pack.
- **No hits called.** BARCS calls no gene at FDR 0.10 and the control null agrees.

## Limits

- One library per bin, large overdispersion: the screen cannot be resolved at the gene level without replicate sorts, so BARCS recovers the paper's directions but calls nothing. The result is screening-level and more conservative than the paper's sgRNA-enrichment ranking.
- The iMAC arm is omitted because its deposited bin labels are inconsistent.
- No gene-level paper table exists; the comparison uses the paper's named/top-ranked genes only.
