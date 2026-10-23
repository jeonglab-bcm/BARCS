# GSE203455 — Secondary pooled knockout screen for CALR-mutant dependencies (BA/F3-MPL)

**Paper.** Jutzi JS et al., Whole-genome CRISPR screening identifies
N-glycosylation as a genetic and therapeutic vulnerability in CALR-mutant MPNs.
*Blood* 2022 (PMID 35763665, doi 10.1182/blood.2022015629). Companion series
GSE203456 holds the whole-genome screen.

**Screen.** Focused library CP1547: about 245 murine genes picked from the
whole-genome screen with 8 guides each, guides against human CALR and MPL
(the transgenes), 100 non-targeting (NO_SITE) and 100 intergenic cutting
(ONE_INTERGENIC_SITE) controls. Four independent EV and four CALR del52
BA/F3-MPL lines. The paper (Fig. 2D-F, supplemental Table 3) compared DEL
without IL3 against EV with IL3 at day 21 with MAGeCK and labelled 64 genes
"more depleted in DEL-" and 8 "more depleted in EV+" at corrected p < 0.05;
MPL, CALR, Jak2 and Stat5b (controls) and the dolichol-phosphate mannose
synthase genes Dpm1, Dpm2, Dpm3 and Mpdu1 are named.

**Input.** One GEO sample with a PoolQ count table (raw integer reads, 13
conditions plus a trailing column of unassigned reads, which is dropped).
prepare.R adds genes from the deposited chip file; controls keep their
library labels.

**Design.** `~ condition`, DEL-IL3 (4 lines) vs EV+IL3 (4 lines), 6 residual
df, library totals. The single EV-IL3 library (a viability control: those
cells die) is not used. Composition is normal (top 1% of guides 3.7-6.5% of
reads), controls are well calibrated without adjustment (5.5% at p < 0.05),
guide correlation 0.011, prior df 16.

**Results.** 81 genes at FDR 0.10 (54 depleted, 27 enriched); 84 against the
control null (centred on the targeting guides; controls sit -0.34 z). Top
depleted: Dpm3, Uggt1, Dpm2, Pmm2, Dpy19l1, Mpi, Dpm1, MPL, CALR, Mpdu1. Top
enriched: Pten, Il3ra, Jak1, Nf1 and other genes the EV+IL3 cells need or
whose loss boosts MPL signalling.

**Agreement.** Spearman 0.89 with the paper's MAGeCK `neg.score`; 8 of the top
10, 22 of the top 25 and 62 of the top 64 shared. All 8 named hits pass FDR
0.10 (Dpm3 #1, Dpm2 #3, Dpm1 #7, MPL #8, CALR #9, Mpdu1 #10, Stat5b #17, Jak2
#28). 45 of the paper's 64 DEL-depleted genes are among BARCS's 54, and all 8
of its EV-depleted genes are among BARCS's 27 enriched calls. The 19
paper-only genes are mostly pan-essential (Banf1, Eef1a1, Exosc1/5, Riok1,
Arf1, Hspa5, H2afz): their guides swing between near zero and thousands of
reads across the four lines of both arms (e.g. one Eef1a1 guide 29-299 reads
in EV, 14-724 in DEL), which MAGeCK's pooled variance tolerates but BARCS's
per-guide overdispersion does not. BARCS adds weaker glycosylation and
secretory genes (Srd5a3, Alg6, B4galt1, Fut8) and murine Calr.

**Limits.** The library is focused on expected hits, so a large share of the
genes are true positives and library totals are slightly shifted (controls sit
0.34 z off the targeting guides); the control null agrees with the model
count. Human CALR/MPL and murine Calr/Mpl are separate genes in the table.
