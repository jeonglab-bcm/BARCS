# GSE168585 reanalysis with BARCS 0.2.3

**Paper.** "TP53 promotes lineage commitment of human embryonic stem cells through ciliogenesis and sonic hedgehog signaling", *Cell Reports* (2022), PMID 35172133, doi:10.1016/j.celrep.2022.110395 (PMC8904926).

**Screen.** Genome-wide GeCKO v2 knockout screen in human ESCs differentiated to neural progenitor cells (NPCs). Day-7 NPCs were FACS-sorted for the 1% lowest SOX1 (an NPC marker); guides enriched in SOX1-negative cells mark genes required for NPC differentiation. Paper method: MAGeCK, ranked by Z score.

**Design.** `~ replicate + population`, SOX1-negative vs unsorted, 4 libraries, 1 residual df (each replicate's sorted + unsorted libraries from one infection, so replicate is a blocking term). The third deposited column header is garbled; it was mapped to unsorted rep 2 and `wt2_b1` to SOX1-negative rep 2 from the correlation matrix and zero-fractions, not the labels. 7.6% of controls reached p < 0.05 before calibration (5.0% after).

## Results (enriched in SOX1-negative)

| Gene | Paper | BARCS rank | FDR |
|---|---|---|---|
| OFD1 (ciliogenesis) | top hit | 3 / 20692 | 0.005 |
| SOX1 (positive control) | top hit | 7 | 0.009 |
| IFT140 (ciliogenesis) | top hit | 12 | 0.013 |

The paper's top hits were SOX1 (self-control), ciliary genes (IFT140, OFD1) and negative regulators of Shh signaling. BARCS's top enriched genes include SUFU, OFD1, SOX1, IFT140 and GLI3 — exactly the ciliogenesis/Shh-repressor classes the paper highlights.

## Agreement with the paper

All three named genes are enriched and in the BARCS top 12 of ~20,700. The paper gave no gene-level results table in GEO or the open supplement, so the comparison rests on the named/validated hits and the shared top-ranked gene classes; both agree.

## Limits

- Column-to-sample mapping was inferred from correlations because one deposited header is corrupted.
- 4,417 genes pass FDR 0.10: a long list for a sort-based screen with one residual df; read the ranking rather than the count. The empirical control null (centred on the controls) gives a similar count (4,772).
