# GSE316985 reanalysis with BARCS 0.2.3

**Paper.** "CRISPR screens identify PRMT7 as a therapeutic target to enhance T cell-mediated killing in breast cancer", npj Breast Cancer (2026), PMID 41565695, doi:10.1038/s41523-025-00888-8 (PMC12891518).

**Screen.** Paired CRISPR knockout and CRISPRi screens of a custom library targeting breast-cancer GWAS/TWAS risk genes (5 guides per gene; 1,000 AAVS1 and 1,000 non-targeting guides, 193 core-essential genes, 26 positive-control resistance genes) in MCF7 cells. At day 11 the cells were either left alone or co-cultured with HLA-matched cytotoxic T cells; surviving cells were sequenced. Three replicates per arm. GEO deposited MAGeCK-normalized guide tables; prepare.R recovers the raw reads exactly with tools/screen-reanalysis/recover_counts.R (one unrounded scale per column, every column 100% integral, scales down to ~1/100 of a read so the search runs to k=400; recovered totals match the triage scales). Two count files are built: ko_counts.tsv and crispri_counts.tsv.

**Design.** `~ replicate + condition`, D11+T vs D11 (no T cells), 6 libraries, 2 residual df, for each of the KO (design.json) and CRISPRi (design_crispri.json) arms. Both arms of a replicate come from the same infected culture, so replicate is paired. Enriched after T-cell exposure = loss confers resistance (resistor); depleted = loss sensitizes.

**Difference in method.** The paper ran MAGeCK-MLE with three terms (a Common fitness term, an IFNg term, and a Tcell term), so it separates the T-cell effect from differential growth over the extra culture days, then filtered out genes whose selection was fitness-driven to reach a final list of 33 (20 resistors, 13 sensitizers; 88 genes at FDR 0.2 before filtering). BARCS fits a single D11+T vs D11 contrast, which is closest to the paper's Tcell term but does not subtract the fitness/IFN components. The published table used here is that MLE Tcell term (Supplementary Data 4), extracted to paper/ko_tcell.tsv and paper/i_tcell.tsv.

**Calibration.** Controls (999 non-targeting plus AAVS1) behave: control_p05 0.040 (KO) and 0.046 (CRISPRi), so no calibration needed; control_shift +0.02 (KO) and -0.04 (CRISPRi), so the control null is centred on the controls. It calls 105 vs the model's 88 (KO) and 184 vs 175 (CRISPRi). Composition flat (top 1% hold ~7% of reads).

## Results

| | BARCS KO | paper Tcell (KO) | BARCS CRISPRi | paper Tcell (CRISPRi) |
|---|---|---|---|---|
| Genes at FDR 0.10 | 88 (51 resistor, 37 sensitizer); 105 vs control null | 14 at Tcell FDR 0.05, 38 at 0.2 | 175 (65 / 110); 184 vs control null | 25 at FDR 0.05, 65 at 0.2 |
| Positive controls (IFNGR1, IFNGR2, JAK2, HLA-A, TAP1, CD58) | ranks 1, 2, 6, 3, 11, 13, all FDR < 1e-9 | all positive beta | ranks 1, 2, 34, 47, 71, 5 | all positive beta |
| Rank correlation (two-sided) | 0.49 | | 0.49 | |

**Six validated genes (recovered across the two arms, as in the paper).**

| Gene | role | BARCS KO rank / FDR | BARCS CRISPRi rank / FDR |
|---|---|---|---|
| CFLAR | sensitizer | #8, 6e-14 | #16, 5e-11 |
| CREBBP | sensitizer | #12, 2e-10 | #1297, 0.86 |
| PRMT7 | sensitizer (lead target) | #119, 0.16 | **#38, 3e-06** |
| IRF1 | resistor | #26, 0.0014 | #13, 5e-13 |
| CASP8 | resistor | #10, 9e-11 | #211, 0.14 |
| ATF7IP | resistor | #224, 0.31 | **#8, 4e-20** |

## Where BARCS agrees and differs

- **Positive controls separate cleanly in both arms**, confirming the screen is feasible: IFNGR1/IFNGR2 are #1-2 in both, with JAK1/2, HLA-A, TAP1, CD58 all in the top of the resistor side. Every one has all guides enriched after T-cell exposure.
- **All six validated genes are a BARCS call in at least one arm**, the same pattern the paper itself relied on (it pooled KO and CRISPRi evidence). CFLAR and IRF1 are called in both. CASP8 and CREBBP are KO calls; PRMT7 and ATF7IP are CRISPRi calls. PRMT7, the paper's lead drug target, is #38 in the CRISPRi arm (FDR 3e-6) and a borderline #119 in KO (FDR 0.16), which matches the paper's own Tcell FDR (0.01 CRISPRi, 0.54 KO).
- **BARCS calls more genes than the paper's final list** (88 KO, 175 CRISPRi vs 33 combined). Most of the extra calls carry small but guide-consistent effects; many are the proteasome, splicing and translation machinery (PSMA6, PSMB3, EIF3D, LSM6) that BARCS flags as resistors/sensitizers but the paper removed as fitness-driven via its Common term. BARCS cannot make that subtraction from a single contrast, so its longer list mixes true CTL-evasion genes with growth effects.

## Limits

- Three replicates, 2 residual df.
- Single contrast conflates the T-cell effect with any differential fitness over the extra culture days; the paper's MLE separates these. Read BARCS's calls as "changed under T-cell co-culture", not strictly "CTL-specific".
- Counts are recovered from MAGeCK-normalized tables (exact integer recovery, documented in prepare.R and recovery_scales_*.json).
