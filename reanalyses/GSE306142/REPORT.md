# GSE306142 reanalysis with BARCS 0.2.1

**Paper.** "Leveraging Medulloblastoma Clonal Dynamics to Overcome Treatment Resistance", *Clinical Cancer Research* (2026), PMID 41091115, doi:10.1158/1078-0432.CCR-24-4010.

**Screen.** Group 3 medulloblastoma cells with the TKOv3 library (71,090 guides) were treated with the BMI1 inhibitor PTC596 or DMSO, in three replicates (T42A–C). PACE_115 in the deposited file is a reference reused from another series and was excluded.

**Design.** `~ replicate + treatment`, 6 libraries, 2 residual df.

**Calibration.** 6.7% of control guides (EGFP, LacZ, luciferase) reached p < 0.05, under the 7.5% threshold, so no calibration was applied.

## Results

| | Value |
|---|---|
| Genes at FDR 0.10 | 2 |
| Top gene | EED, enriched (knockout tolerates PTC596), FDR 0.08 |
| MTOR, RPTOR, AKT1/2 | ranks 7,000–17,000, no effect |
| PIK3CA, PLK1, RICTOR | ranks 766–2,741, slightly *enriched*, not significant |

## Where BARCS agrees and differs

- **Differs.** None of the core pathway genes the abstract highlights are depleted under PTC596, and only two genes pass FDR 0.10. Earlier versions of this page, before separated guides were kept, reported 26.
- **Indirect comparison.** The paper's pathways came from intersecting its sensitizer list with phosphoproteomic changes and neural stem cell essential genes. That list is not in GEO, so the pathway-level claim cannot be tested gene by gene.
- **EED.** Loss of EED, a core PRC2 subunit, is the strongest effect. PTC596 targets BMI1 (PRC1), so this is a plausible, untested link between the two Polycomb complexes.

## Limits

- Two residual degrees of freedom.
- The authors' gene list was not available.
