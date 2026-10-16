# GSE217131 reanalysis with BARCS 0.2.3

**Paper.** Kim, Koo, Riessland et al., "TNF-NF-κB-p53 axis restricts in vivo survival of hPSC-derived dopamine neurons", *Cell* (2024), PMID 38866017, doi:10.1016/j.cell.2024.05.030 (PMC11641762).

**Screen.** H9 hPSC-derived dopamine neurons carrying a doxycycline-inducible Cas9 and a focused "large pool" library: 538 guides covering about 160 cell-death and survival genes (3 guides each) with 50 non-targeting and 50 safe-harbor control guides. After Dox-induced editing, the day-25 edited pool was either kept in vitro (D25 Dox+) or grafted into the mouse striatum (D25 Graft Dox+). Guides enriched in the graft mark genes whose knockout improves neuron survival in vivo. The paper's central result is that TP53-mediated apoptosis (with upstream TNF-NF-κB signalling) limits graft survival.

**Counts.** Each condition sheet in the GEO workbook holds two count columns. They are technical re-reads of one library (correlation > 0.998, near-constant ratio), so `prepare.R` sums them to one library per condition. Gene = guide name without the `_k` index; the 100 non-targeting and safe-harbor guides form the control group.

**Design.** Graft vs in vitro at day 25, `~ condition`, one library each. With no replicate cultures `run_barcs.R` uses the no-replicate path, pooling the overdispersion over the 100 controls (ρ = 1.2e-5, 28-fold the Poisson variance). The calls are screening-level. Direction enriched (knockouts that aid survival). Top 1% of guides hold 3-4% of reads (no bottleneck).

**Checks.** The raw control rate at p < 0.05 was 16%, so the test was calibrated to the controls (to 5%). The controls sit 0.62 z below the targeting guides, so the control null is centred on the targeting guides (3 genes against it). Dispersion pooled over all guides.

## Results

| | BARCS |
|---|---|
| Genes at FDR 0.10 | 1 (TP53, enriched); 3 against the control null |
| TP53 | #1 of 164, estimate +0.33, FDR ~0, empirical FDR 0.003; all 3 guides up |
| Other apoptosis genes | CASP9 #19, BAK1, BBC3/PUMA #59, BAX #101 — enriched in direction but not significant |
| Top genes | TP53, ATG4D, IFNA13, CASP2, ULK1, ENDOG, TNFRSF11B, RIPK3 |

## Where BARCS agrees and differs

- **Agrees.** BARCS recovers the paper's central finding: TP53 is the single clear hit, strongly enriched in the graft (knocking out TP53 rescues grafted neurons), and the next-ranked genes are apoptosis/autophagy regulators. TP53 passes both the model FDR and the control null.
- **Differs.** Only TP53 clears FDR 0.10. The downstream effectors the paper emphasises (BBC3/PUMA, BAX, caspases) and the TNF-NF-κB genes are enriched in direction but with small effects that one library per condition cannot call significant. The paper validated BBC3 and the TNF axis in a separate 33-guide "small pool" screen and in individual experiments, not from this large-pool statistic alone.

## Limits

- One library per condition (the two GEO columns are technical re-reads): the calls are screening-level, with no measure of culture-to-culture variation.
- The library is a focused cell-death panel (164 genes), so this is a targeted survival screen, not a genome-wide one.
- The in vivo selection is modest in effect size over most genes; only TP53 rises clearly above the controls.
