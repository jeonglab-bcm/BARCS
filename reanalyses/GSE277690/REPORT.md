# GSE277690 reanalysis with BARCS 0.2.3

**Paper.** "Genome-wide CRISPR/Cas9 screen reveals factors that influence the susceptibility of tumor cells to NK cell-mediated killing", *J Immunother Cancer* 2025, PMID 40164474 (PMC11962812, doi:10.1136/jitc-2024-010699).

**Screen.** HCT-116-Cas9 cells with the Brunello KO library (77,441 guides, 1,000 non-targeting controls). The collection of mutants (a02) was co-cultured with KHYG-1 NK cells (condition 1), KHYG-1 plus anti-NKp44 mAb (condition 2) or NKp44-deficient KHYG-1 (condition 3); survivors of round 1 (a03, a04, a05) and of a second challenge of the round-1 KHYG-1 survivors (a07, a08, a09) were sequenced. Column names are given in the GSM descriptions. Raw integer counts (`GSE277690_Comparison_all.count.txt.gz`), used as deposited.

**Design.** One library per condition, so every analysis has no residual df and `run_barcs.R` uses the no-replicate path (overdispersion pooled over ~1,000 non-targeting guides). **Calls are screening-level: variation between replicate co-cultures was not measured.** Analyses (`~ condition` or `~ nk`, enrichment = resistance to NK killing):
1. KHYG-1 round 1 vs collection (a03 vs a02) - main;
2. KHYG-1 round 2 vs collection (a07 vs a02) - cumulative selection; round 2 is a re-challenge of round-1 survivors, not a replicate;
3. KHYG-1 vs NKp44-KO KHYG-1, round 1 (a03 vs a05) - NKp44-dependent killing.

**Checks.** Composition unremarkable (top 1% of guides hold 3.4-4.3% of reads). Control calibration applied in analyses 1-2 (raw control p<0.05 rate 11.8% and 12.2%, 4.9% after); analysis 3 has 6.1%. Non-targeting controls sit 0.67-0.73 z away from targeting guides in analyses 1-2, so the control null is centred on the targeting guides. No jackpot guides behind the top calls: CASP8, FADD, KHDRBS1, SPPL3 and RPRD2 are enriched on 4 of 4 guides with consistent counts.

## Results
- **Round 1 vs collection:** 265 genes at FDR 0.10 (816 against the centred control null), but only 9 enriched; most calls are depletions of fitness genes between the collection and the surviving cells. Enriched: CASP8 (#1, FDR 1.5e-4), FADD (#2), KHDRBS1, FAF1 (#4), RPRD2, SPPL3, PDCD10, IFNGR1 (#8, FDR 0.085), ZNF17.
- **Round 2 vs collection:** 178 genes at FDR 0.10 (49 enriched; 773 against the centred control null). All ten apoptosis and IFN-gamma genes the paper names are in the top 16 and pass FDR 0.10: CASP8 (#1), FADD, JAK2, IFNGR1, JAK1, BID, FAF1, STAT1, FAS (#13), IFNGR2 (#16), with FDR 3e-38 to 1.5e-4.
- **KHYG-1 vs NKp44-KO KHYG-1:** 92 genes at FDR 0.10 (34 enriched; 131 against the control null): again FADD, CASP8, KHDRBS1, BID, JAK1, IFNGR2, JAK2, STAT1, IFNGR1. NKp44-KO NK cells kill less (3.5- vs 1.8-fold reduction in round 1), so this contrast mostly measures weaker selection, not an NKp44-specific mechanism.
- **ICAM1**, the paper's headline NKp44-synapse gene, is not enriched in any analysis (round 1 rank 5,934, FDR 1; round 2 rank 229, FDR 0.51; KHYG-1 vs NKp44-KO rank 446, FDR 0.6). Raw counts show only mild enrichment of its four guides.

## BARCS vs paper
The paper ran MAGeCK with default settings per condition, took genes with FDR < 0.5 and found 119 "NKp44-dependent" hits by subtracting the hits of conditions 2 and 3 from condition 1; ICAM1 came from that list and was then validated experimentally. BARCS agrees on the screen's main pathway result: loss of extrinsic-apoptosis (CASP8, FADD, BID, FAS, FAF1) and IFN-gamma-signalling (IFNGR1/2, JAK1/2, STAT1) genes protects HCT-116 cells, strongly after two rounds and partly after one. BARCS does not support ICAM1 as a screen hit at any reasonable FDR; the paper's FDR < 0.5 threshold and set subtraction are far more permissive. BARCS-only strong enriched genes: KHDRBS1, SPPL3, RPRD2, PDCD10.

The paper's supplementary tables 1-4 (MAGeCK results) are image-only PDFs with no extractable text, so no gene-level table comparison was made; the comparison is to the genes the paper names.

## Limits
One library per condition (screening-level calls); round 2 is serial selection of the round-1 survivors; the collection was not sequenced at the time of each co-culture, so depletion calls mix NK selection with culture drift.
