# GSE145615 reanalysis with BARCS 0.2.3

**Paper.** "m6A RNA methylation regulates the fate of endogenous retroviruses", *Nature* (2021), PMID 33442060, doi:10.1038/s41586-020-03135-1.

**Screen.** Genome-wide CRISPR knockout screen in mouse ESCs carrying an IAPEz (ERV) reporter that confers blasticidin resistance when the ERV is de-repressed. Knockouts of ERV-restriction factors (the m6A writers Mettl3/Mettl14/Wtap/Zc3h13) survive blasticidin and are enriched in the +blast population. Paper method: MAGeCK (positive selection).

**Design.** `~ replicate + selection`, +blast vs -blast (Screen II, late selection), 4 libraries, 1 residual df. Positive selection collapses the +blast libraries (40-50% zero guides; the top 1% of guides hold up to 96% of reads), so library totals were replaced with `median_ratio`. Only 10 scrambled controls, too few to calibrate.

## Results

| Gene | BARCS rank (enriched) | FDR |
|---|---|---|
| Mettl3 | 11 / 18797 | 0.0003 |
| Mettl14 | 21 | 0.021 |
| Wtap | 323 | 0.84 |
| Zc3h13 | 848 | 0.24 |

BARCS's top enriched genes are the apoptosis (Apaf1, Casp9, Casp3, Trp53) and heme-biosynthesis (Hccs, Urod, Uros, Hmbs, Fech, Ppox) genes that dominate the blasticidin/reporter selection — the same classes at the top of the paper's own MAGeCK Screen tables — with the m6A writer Mettl3 at #11 and Mettl14 at #21.

## Agreement with the paper

Partial. BARCS recovers two of the four named m6A writers (Mettl3, Mettl14) in the top 21 and reproduces the selection-artifact gene classes the paper's tables also show at the top. But the quantitative agreement is weak (Spearman 0.39 vs the paper's MAGeCK pos|score; top-20 Jaccard 0.14), and the median-ratio totals are **capped** for both +blast libraries because single clones hold most of each library. Depletion is therefore uninterpretable, and the hit count is inflated (17,426 of 18,797 genes pass FDR 0.10): read only the top enriched ranks, not the count.

## Limits

- Extreme clonal bottleneck in the +blast arm (one guide ~96% of a library); median-ratio totals capped, depletion uninterpretable.
- Only 10 non-targeting controls, so no control calibration or empirical null.
- Wtap and Zc3h13 are not recovered near the top; the biochemically central Mettl3/Mettl14 are.
