# GSE299588 reanalysis with BARCS 0.2.1

**Paper.** "CRISPR screen reveals SOX2 as a critical regulator of CD133 and cellular stress response in glioblastoma", *Scientific Reports* (2025), PMID 41102523, doi:10.1038/s41598-025-20183-7 (PMC12533111). The supplement is a Word file without a gene table, so the comparison uses the named genes.

**Screen.** BT935 patient-derived glioblastoma cells with the TKOv3 library (71,090 guides). At day 27 the cells were sorted into the top and bottom 5% of CD133 (AC133) staining, in triplicate.

**Design.** The count columns (GBM_80–89) are not labeled by condition, so I inferred the mapping:
- PROM1, the gene encoding CD133, is the built-in positive control. Its knockouts are depleted about 4-fold in GBM_84–86 and not in GBM_87–89, so 84–86 are CD133-top and 87–89 CD133-bottom.
- Log-count correlations pair 81/84/87, 82/85/88 and 83/86/89 (0.84–0.86 within a replicate, about 0.5 across). These are replicates A–C, each sorted from one culture.

**Calibration.** 15% of the 142 control guides (EGFP, LacZ, luciferase) reached p < 0.05, so the test was calibrated to them (4.5% after). Calibration widens the null about 1.5-fold, which leaves no gene significant genome-wide.

Model: `~ replicate + bin`, 6 libraries, 2 residual df, `test = "auto"` (471 guides used the likelihood-ratio test). Missing counts were read as zero.

## Results

| | Value |
|---|---|
| Genes at FDR 0.10 | 0 after control calibration (131 before) |
| PROM1 | **rank 1**, p = 1.5 × 10⁻⁴ |
| SOX2 | **rank 10**, p = 0.002 |
| Other genes lower in CD133-high cells | SLC25A36, NDUFB11, KEAP1, APBB1, MEN1, NF2, TADA1, TADA2B, FBXW7 |
| Higher in CD133-high cells | YPEL5, EGLN1, SPAST, PAXIP1, PLCG1 |

## Where BARCS agrees and differs

- **Ranking agrees, significance does not.** SOX2 knockouts lose CD133, as the paper reports, and SOX2 is the highest-ranked transcription factor. After calibration to the non-targeting guides, neither SOX2 nor PROM1 passes FDR 0.10.
- **Additional hits.** The SAGA/TADA subunits (TADA1, TADA2B) and MEN1 point to chromatin regulators of the PROM1 locus that the abstract does not discuss.
- **Uncertain.** These additional hits are not validated here. Sorting extremes (top/bottom 5%) amplify noise for low-count guides.

## Limits

- The column-to-condition mapping is inferred, though strongly supported by PROM1.
- Two residual degrees of freedom.
- No published gene table to compare against.
