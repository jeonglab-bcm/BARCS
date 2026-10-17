# GSE192827 — BTN3A surface-expression CRISPR screen (companion of GSE192828)

**Paper.** Mamedov et al., *CRISPR screens decode cancer cell pathways that
trigger gamma-delta T cell detection*, Nature 2023 (PMID 37648854, doi
10.1038/s41586-023-06482-x). GSE192827 is the BTN3A arm of the same study whose
killing arm is GSE192828 (already analysed); it is a different screen, so it is
analysed on its own.

**Screen.** Daudi-Cas9 cells carrying the same genome-wide knockout library
(90,709 guides, no non-targeting controls) were FACS-sorted into the top (high)
and bottom (low) 25% of surface BTN3A. Three replicate infections, each sorted
into both bins.

**Design.** `~ replicate + condition`, coefficient `conditionlow` (low vs high),
pairing the two bins within each infection (2 residual df). Positive BTN3A
regulators are enriched in the low bin (positive estimate); negative regulators
enriched in the high bin (negative estimate). No control guides.

**Results.** 3,244 genes at FDR 0.10 (1,350 up in low, 1,894 up in high); guide
correlation 0.004. Top enriched-in-low: BTN3A1, IRF1, NLRC5, SPIB, RFXAP, IRF8,
BTN3A2, FBXW7, ECSIT, plus an OXPHOS/NDUF block. Top enriched-in-high: CTBP1,
CMAS, ZNF217, RING1, RUNX1.

**Agreement.** Against the authors' MAGeCK table (MOESM8, sheet "BTN3A Screen"):
rank correlation 0.76 (positive) and 0.75 (negative). Of the paper's 497
positive-direction calls at FDR 0.10 BARCS recovers 494; of 754 negative, 748.
All named positive regulators pass FDR 0.10 (BTN3A1 #1, IRF1 #2, NLRC5 #3,
SPIB #4, IRF8 #6, BTN3A2 #7, FBXW7 #8, ECSIT #9); named negative regulators
recovered (CTBP1 #1, RING1 #4, ZNF217 #3, RUNX1 #13, CBFB #29). Top-200 Jaccard
0.72 / 0.65. agree.

**Limits.** BARCS calls a longer list than the paper's RRA hits (replicate-aware
dispersion vs RRA). No non-targeting guides, so no calibration or control null.
Count file used as deposited; prepare.R only fetches the paper's MAGeCK table.
