# GSE203456 — Whole-genome knockout screen for CALR-mutant-specific dependencies (BA/F3-MPL)

**Paper.** Jutzi JS et al., Whole-genome CRISPR screening identifies
N-glycosylation as a genetic and therapeutic vulnerability in CALR-mutant MPNs.
*Blood* 2022 (PMID 35763665, doi 10.1182/blood.2022015629). Companion
series GSE203455 holds the secondary pooled screen.

**Screen.** Mouse Brie library (4 guides per gene) in BA/F3-MPL cells
expressing an empty vector (EV) or CALR del52 (DEL), two independent cell
lines (A, B) per genotype. From day 7 cells grew with or without IL3; without
IL3 only CALR-mutant cells grow, through MPL. The paper's main comparison
(Fig. 1C-D, supplemental Table 1) is DEL without IL3 vs EV with IL3 at day 21,
analysed with MAGeCK; it reports 669 genes with log2 fold change below -1 and
7 of the top 10 in protein glycosylation, Dpm2 the most depleted.

**Input.** One GEO sample with a PoolQ table of raw guide counts for the eight
conditions (named "scores" but integer reads). prepare.R adds gene labels from
the deposited Brie annotation (joined on sequence; the 1000 listed
non-targeting guides become Non-Targeting-Control). No guide was unannotated.

**Design.** `~ condition`, DEL-IL3 (A, B) vs EV+IL3 (A, B), 2 residual df. A
and B are separate lines per genotype, so no pairing term. The DEL-IL3 vs
DEL+IL3 comparison is not reproduced because the deposited DEL A +IL3 library
is from day 11, not day 21. Library composition was normal (top 1% of guides
2.6-5.9% of reads), controls were calibrated (4.1% at p < 0.05), guide
correlation 0.012.

**Results.** 24 genes at FDR 0.10: 16 depleted and 8 enriched; 49 at
empirical FDR 0.10 against the control null (centred on the controls, shift
-0.13 z). The depleted list is the N-glycosylation / dolichol pathway: Dpm2
(#1), Dpm3 (#2), Mpi, Dpy19l1, Dpm1, Pmm2, Uggt1, Srd5a3, Tsta3, Tmed2, plus
Prdm4, Csnk1a1, Hmbs. The enriched calls (Jak1, Il3ra, Csf2rb2, Kdm1b) are
genes the EV cells need on IL3, matching the paper's note that Il3ra was the
most depleted gene in the EV control.

**Agreement.** Spearman 0.71 with the paper's MAGeCK `neg.score`; 9 of the top
10 and 20 of the top 25 shared; 15 of BARCS's 16 depleted calls are among the
27 genes at MAGeCK FDR 0.10. Named hits: Dpm2 #1, Dpm3 #2, Dpm1 #6 pass FDR
0.10; Calr (#19, FDR 0.13) and Mpdu1 (#20, FDR 0.14) just miss: three of
four guides each fall from 130-340 to 0-18 reads in both DEL lines, but one
guide each is flat (Calr 127/256 → 132/197; Mpdu1 500/397 → 104/522), and
with two lines per arm BARCS does not let three guides carry the gene to FDR
0.10. Both pass in the pooled validation screen (GSE203455, 8 guides, 4 lines).
MAGeCK-only genes further down (Mtif3, Dhx29, Slc2a1, Has1, Npff) have weak
effects that BARCS ranks lower.

**Limits.** Two independent lines per arm (2 residual df); no plasmid or
early time point is deposited, so depletion is relative between genotypes,
not from the start of the screen. The paper's 669-gene list uses a fold-change
cut-off without a significance filter and is not comparable to an FDR list.
