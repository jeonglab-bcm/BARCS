# GSE233401 — UHRF1 minipool tumour-suppressor CRISPR screen

**Paper.** Kostyrko et al., *UHRF1 is a mediator of KRAS driven oncogenesis in
lung adenocarcinoma*, Nat Commun 2023 (PMID 37407562, doi
10.1038/s41467-023-39591-2). GSE233401 is the CRISPR arm; GSE209923 is the
shRNA arm of the same study.

**Screen.** KRAS-mutant A549-Cas9 cells carrying a minipool of 483 sgRNAs (80
lung-cancer tumour-suppressor genes, 12 positive-control essentials, 26
negative "safe" sgRNAs) were given either a non-targeting guide (sgNeg) or a
guide against UHRF1 (sgUHRF1), then passaged; DNA was taken at T0 (split) and
T1 (18 days). The paper reports a depletion z-score per gene separately in each
background (Supplementary Data 10) to find TSG knockouts whose fitness effect
depends on UHRF1.

**Design.** Two analyses, each `~ time`, coefficient `timeT1` (T1 vs T0): the
sgNeg background (two reps per timepoint) and the sgUHRF1 background (two reps).
The A549TSGlibT0 plasmid column is not part of either contrast.
`control_gene_pattern` `^safe$`.

**Results.** sgNeg: 66 genes at FDR 0.10 (58 enriched — TSG knockouts give a
growth advantage in this KRAS line). sgUHRF1: 5 at FDR 0.10. PTEN and TSC1 are
the top enriched genes in both, as in the paper. Only 26 safe controls, below
the 100 needed for a control null; raw control p05 was 0.15/0.19 but
calibration did not trigger with so few controls, so the hit list is not
calibrated.

**Agreement.** Against Supplementary Data 10 (sgNeg_z / sgUHRF1_z, higher =
more enriched): rank correlation 0.96 (sgNeg) and 0.90 (sgUHRF1). Named hits
PTEN #1, TSC1 #2, MAP3K4 #3, MAP2K4 #10 all enriched at FDR 0.10 in sgNeg; in
sgUHRF1, TSC1 #1 and PTEN (rank 5, FDR 0.11). Top-50 Jaccard 0.85 / 0.79.
agree.

**Limits.** The focused 92-gene library has only 26 "safe" controls, too few
for a control null or reliable calibration. BARCS calls more genes than the
authors' z-score cutoff. The count file is used as deposited; prepare.R builds
the paper's gene table from Supplementary Data 10 (header below a one-line
title, read with skip = 1).
