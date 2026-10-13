# GSE226977 reanalysis with BARCS 0.2.2

**Paper.** Roes & Dick, "A Genome Wide CRISPR Screen Reveals That HOXA9 Promotes Enzalutamide Resistance in Prostate Cancer", *Molecular and Cellular Biology* 44 (2024), PMID 39300912, doi:10.1080/10985549.2024.2401465 (PMC11583586, open access).

**Screen.** A genome-wide CRISPR knockout screen in LNCaP prostate cancer cells (71,090 guides, 4 per gene, 142 non-cutting controls: LacZ 96, luciferase 24, EGFP 22). Per-sample count files (`GSE226977_RAW.tar`) were merged on sgRNA into 12 libraries: T0 and final time point (TF), each DMSO and enzalutamide (EZ), 3 replicates. The paper looked for gene-loss events changing enzalutamide response, and validated **HOXA9** as a sensitizer: HOXA9 loss sensitizes cells to enzalutamide, so HOXA9 guides should **deplete** in EZ.

**Caveats for this series.**
- **The final libraries are severely bottlenecked.** The TF-EZ libraries have 17-21% of guides at zero and the top 1% of guides hold 23-33% of reads (vs ~3% in T0). Under this composition, library totals call most genes depleted, so the primary analysis uses **median-ratio totals** and enrichment is read first.
- **The 142 non-cutting controls cannot calibrate.** 0% of them reach p < 0.05 (raw and calibrated), so the test could not be tuned to the controls and the control-null count (246 genes) is centred on the controls while being far larger than the model's 88 — per the pipeline rule, that number is not quotable as a hit count.
- **No T0-anchored design.** The deposited T0-DMSO / T0-EZ labels appear swapped (only T0-EZ-Rep1 shows a bottleneck the other T0 libraries lack), and T0 is one pre-treatment pool, so no reliable time-zero reference exists.

## Results (EZ vs DMSO, final time point)

| Totals | Genes at FDR 0.10 | Direction |
|---|---|---|
| **median-ratio (primary)** | 88 | all depleted |
| library | 370 | all depleted |

The call count swings 88 vs 370 with normalization, confirming the bottleneck's effect. Reading enrichment first (median-ratio), the top enriched (resistance-direction) genes are ADO, PNPLA2, ATF3, LETMD1, ARPC3; **RB1 is enriched** (estimate +1.86, rank 37), consistent with the paper's finding that RB-p53 loss drives enzalutamide resistance. The strongest depleted genes are MGEA5 (OGA), MOGS, BAP1, ACD and OTOP1.

**HOXA9** (the paper's validated hit): depleted in EZ in both normalizations — estimate −1.03 (p 0.044) with median-ratio totals and −1.59 (p 0.009) with library totals — i.e. in the paper's sensitizer direction, but ranked ~1096 / ~914 of ~18,000 and not significant at FDR 0.10.

## Where BARCS agrees and differs

- **Agrees in direction.** HOXA9 depletes in enzalutamide in the direction the paper reports, and RB1 enriches (resistance), matching the paper's RB-p53 biology.
- **Does not confirm HOXA9 as a standout.** BARCS places HOXA9 in the middle of the ranked list, not among the called genes. The paper selected HOXA9 from the sensitivity category and validated it functionally; the screen counts alone, after accounting for the bottleneck and the uninformative controls, do not single it out.
- **Why.** The final EZ libraries are dominated by a few surviving clones. Under that bottleneck, random guide dropout produces large apparent depletions; library totals (as the paper's normalization would see them) call 370 genes, median-ratio totals 88, and the 142 non-cutting controls show no signal at p < 0.05 so cannot anchor the null. The paper's MAGeCK analysis plus functional validation is more robust to this than the deposited counts are on their own.

## Limits

- Severe bottleneck in the final EZ arm; depletion calls swing 88 vs 370 with normalization.
- 142 non-cutting controls give 0% at p < 0.05, so the test cannot be calibrated and the control null is not quotable.
- T0 labels appear swapped; no time-zero-anchored design is possible.
