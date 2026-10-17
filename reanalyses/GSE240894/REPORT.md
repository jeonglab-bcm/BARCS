# GSE240894 — Latency HIV-CRISPR dependency-factor screen

**Paper.** Hafer et al., bioRxiv 2023 (PMID 37546973, PMC10402164, doi
10.1101/2023.07.28.551016). A targeted screen for host genes required to
reactivate HIV-1 from latency.

**Screen.** Two latently infected Jurkat lines (J-Lat 10.6 and 5A8) were
transduced with an 8-guide-per-gene library of 526 HIV dependency factors plus
210 non-targeting controls, treated with latency-reversal agents, and the
guides captured in the viral-particle RNA (vRNA) supernatant were compared with
the genomic-DNA knockout pool (gDNA). A gene whose knockout blocks reactivation
is depleted in the vRNA. The authors' MAGeCK tables are the combination
(AZD5582 + I-BET151, COMBO) vRNA sort against the gDNA pool, per cell line.

**Design.** `~ condition`, coefficient `conditionvRNA_COMBO` (vRNA COMBO vs
gDNA), analysed separately per line. Each line has one DMSO and one AZD gDNA
library and two COMBO vRNA replicates (2 residual df). `control_gene_pattern`
`^NTC_`.

**Results.** Raw control p05 was high (0.25 in 10.6, 0.17 in 5A8), so BARCS
calibrated to the 210 controls (control_scale 2.2 / 1.5). J-Lat 10.6: 92 genes
at FDR 0.10 (65 depleted); the control null is centred on the targeting guides
(controls offset -0.26 z) and gives 131 genes. J-Lat 5A8: 49 genes at FDR 0.10
(46 depleted); control null centred on the controls gives 21. CCNT1 is the top
depleted gene in both lines (estimate -0.92 / -0.86).

**Agreement.** Against Supplementary File S1 (JLat106/JLat5A8 gene summaries):
rank correlation 0.83 (10.6) and 0.77 (5A8). All named hits pass FDR 0.10 —
J-Lat 10.6: CCNT1 #1, UBE2M #3, ELL #4, OGT #5, NFKB1 #6, MBNL1 #10, HDAC3 #13,
TBL1XR1 #18, AMBRA1 #25, ALYREF #31; J-Lat 5A8: CCNT1 #1, ELL #2, OTUD5 #4,
MED7 #5, TBL1XR1 #6, NFKB1 #7, HDAC3 #8, AMBRA1 #12, UBE2M #16. agree.

**Limits.** The gDNA "replicates" are one DMSO and one AZD library, not true
replicate cultures, so the 2 df come from treatment plus the two COMBO vRNA
reps. BARCS calls more genes than the paper's MAGeCK FDR 0.10 list (63 / 13).
The count file is used as deposited; prepare.R fetches the paper's Supplementary
File S1 from the Europe PMC supplementary archive.
