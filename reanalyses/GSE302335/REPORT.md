# GSE302335 reanalysis with BARCS 0.2.1

**Paper.** "Multiplexed perturbation enables scalable pooled screens", *Nature Methods* (2026), PMID 42185540, doi:10.1038/s41592-026-03095-w. It is a methods paper whose application is a genome-wide CRISPRi screen for regulators of ICAM-1 (CD54).

**Screen.** Genome-wide CRISPRi (one guide per gene, 21,554 guides including 1,026 non-targeting) sorted into CD54-low and CD54-high bins. The deposited table splits each guide over 41 cell barcodes; they were summed. The highest-coverage arm at MOI 0.3 was used.

**Design.** `~ replicate + bin`, CD54-low vs CD54-high, 4 libraries, 1 residual df.

## Calibration problem

Non-targeting guides show a low-vs-high difference that reproduces between replicates (correlation 0.47; 0.68 for targeting guides). The two replicates were probably split from one transduced population and share clone-level noise. Consequences:

| Approach | Genes at FDR 0.10 | Non-targeting at p < 0.05 |
|---|---|---|
| Model | 2,176 | 11% |
| Calibrated to controls (`tail_quantile`) | 1,533 | 5% |
| Empirical null from the 1,026 control guides | **45** | by construction |

Calibration fixes the 5% point but not the extreme tail of the controls (2.3% reach p < 0.001). The empirical null is the trustworthy count.

## Results

- **ICAM1_P1P2:** rank 7, enriched in CD54-low (positive control).
- **TRAF6_P1P2:** rank 4. TRAF6 signals to NF-κB, which induces ICAM1.
- **Other top genes:** CLSTN2, PTPN1, SYN3, HADHB, CHP2. These are untested candidates.

## Limits

- One guide per gene.
- Shared clonal structure between replicates.
- The paper's own candidate list is not in its abstract.
