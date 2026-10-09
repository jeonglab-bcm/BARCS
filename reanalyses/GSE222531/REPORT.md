# GSE222531 reanalysis with BARCS 0.2.2

**Paper.** "Compact CRISPR genetic screens enabled by improved guide RNA library cloning", *Genome Biology* (2024), PMID 38243310, doi:10.1186/s13059-023-03132-3 (PMC10797759).

**Screen.** A methods paper. The authors re-cloned the hCRISPRi-v2 library (top 5 guides per TSS; 103,074 guides, 1,895 non-targeting) with a low-skew protocol ("LGR") and screened K562 dCas9-KRAB cells. GEO holds one headerless count file per sample. The 38 K562 files share an identical guide set; they were merged by guide id, with the gene taken as the guide id up to the first "_" (multi-TSS genes' P1/P2 guides share one label). The paper names no hit genes. Its claims are about screen quality:
- the LGR library at 100-fold cell coverage finds essential genes as well as at 1000-fold: 1,489 essential genes by ScreenProcessing, BAGEL2 precision-recall AUC 0.949;
- a 100-fold dasatinib screen finds more hits than the legacy library (MAGeCK-VISPR: 734 genes at FDR 0.25, 105 at FDR 0.001), enriched for Mediator-complex knockdowns (resistance; 7 of 40 Mediator genes at FDR 0.001) and depleted for oxidative phosphorylation (sensitization).

The supplements hold count tables, not gene-level results, so there is no published gene table to compare with. The growth screen is benchmarked against reference gene sets instead.

**Reference sets.** Hart et al. core-essential genes CEGv2 (684 genes) and non-essential genes NEGv1 (927 genes), downloaded from the BAGEL repository (`https://raw.githubusercontent.com/hart-lab/bagel/master/CEGv2.txt` and `NEGv1.txt`, saved in `paper/`). These are the gold standards BAGEL2 uses, so they match the paper's own precision-recall analysis. 658 CEGv2 and 846 NEGv1 genes are in the library under the same symbol.

**Design.**
1. *Primary:* LGR 100X end point vs T0, `~ condition`, 4 Tf vs 2 T0 libraries, 4 residual df. Replicates are not paired across time points.
2. *Second:* LGR dasatinib vs DMSO, `~ condition`, 2 vs 2, 2 residual df.

Library totals; composition is flat (top 1% of guides hold 2.1–2.5% of reads).

**Calibration.**
- *Growth screen:* 4.4% of non-targeting guides reach p < 0.05, so no calibration was needed. The control null, centred on the controls (shift −0.14 z), calls 2,290 genes against the model's 2,333.
- *Dasatinib:* 12.3% of controls reached p < 0.05 with only 2 residual df, so the test was calibrated to them (5.0% after; scale 1.24). The control null calls 329 genes against the model's 326.

## Results: growth screen (LGR 100X, Tf vs T0)

| | BARCS (library totals) | BARCS (control totals, sensitivity) | Paper |
|---|---|---|---|
| Genes at FDR 0.10 | 2,333 (2,025 depleted, 308 enriched*) | 2,754 (2,728 depleted, 26 enriched) | 1,489 essential genes (ScreenProcessing) |
| Against the control null | 2,290 | 2,314 | |
| CEGv2 recall (depleted, FDR 0.10) | 533/658 = 81% | 572/658 = 87% | |
| NEGv1 called depleted | 5/846 | 26/846 | |
| Precision, CEG / (CEG + NEG) | 0.991 | 0.957 | |
| Average precision, CEG vs NEG ranked by depletion | 0.962 | 0.962 | BAGEL2 PR-AUC 0.949 |

\*Direction from the gene statistic. `run_info.json` counts 1,962/371 by the sign of the median guide estimate, which can disagree when only some of a gene's guides (e.g. one TSS) work. With library totals, the 308 "enriched" genes have small effects (+0.15 to +0.45 log fold change) and include genes not expressed in K562 (FOXL2, TAT, KRTAP16-1). Strong dropout of essential guides inflates every other guide's share. Normalizing to the non-targeting guides removes them (26 remain), so they are a composition artifact, not proliferation suppressors.

K562-specific dependencies are called: GATA1 (#119 depleted, FDR 5 × 10⁻³²) and BCR (#301, FDR 10⁻²⁴; the BCR promoter drives BCR-ABL1). ABL1 is not depleted (guides at the ABL1 TSS cannot reach the fusion transcript).

## Results: dasatinib vs DMSO

| | BARCS | Paper (MAGeCK-VISPR) |
|---|---|---|
| Genes at FDR 0.10 | 326 (149 enriched / resistant, 177 depleted / sensitizing); 329 against the control null | 734 at FDR 0.25; 105 at FDR 0.001 |
| Genes at FDR 0.25 / 0.001 | 811 / 47 | |
| Mediator complex (MED*, CCNC, CDK8; 31 in library) | 17 enriched at FDR 0.10, none depleted (MED23 #3, CCNC #4, CDK8 #6, MED8 #11, MED31 #13, MED24 #14, MED1 #21; MED12 #127, FDR 0.054) | 7 of 40 at FDR 0.001 (incl. MED8, MED12, MED31) |
| Oxidative phosphorylation (NDUF*, COX, UQCR, ATP5; 96 in library) | 19 depleted at FDR 0.10 (NDUFB6, NDUFS4, NDUFS8, NDUFA3, ...), none enriched | depleted, enriched pathway |
| Known TKI-resistance genes | NF1 #9 enriched (FDR 2 × 10⁻⁵), GFI1B #27, LZTR1 #30, PTPN1 #17, INPPL1 #7 | |

Top enriched: KLF1, DPY30, MED23, CCNC, SUPT20H, CDK8, INPPL1, KDM1A, NF1. Their guides move consistently: all five KLF1 guides go from 33–73 reads in DMSO to 348–812 in dasatinib, and all five NF1 guides from 38–146 to 482–7,655. No jackpot drives a top call. Top depleted: PPOX, PDHA1, ALAS2, TPK1, IGF2BP1, MCL1.

## Where BARCS agrees and differs

- **Agrees.** The paper's claim that a 100X LGR screen recovers essential genes with high precision holds under BARCS:
  - 99% precision and 81% recall of core-essential genes at FDR 0.10;
  - average precision 0.962 (the paper's BAGEL2 AUC is 0.949; not identical metrics).

  The dasatinib arm reproduces the paper's biology: Mediator knockdown confers resistance (17 subunits at FDR 0.10) and oxidative-phosphorylation knockdown sensitizes. The known resistance genes NF1, LZTR1 and GFI1B are in the top 30.
- **Differs.** BARCS calls more genes in the growth screen than ScreenProcessing (2,025 depleted vs 1,489 essential). Most CEGv2 genes BARCS misses have one working guide among several, typically one TSS of a multi-TSS gene (e.g. USPL1: one of five guides at −5.5 log2). In the dasatinib arm BARCS calls a similar number of genes at FDR 0.25 (811 vs 734) but fewer at FDR 0.001 (47 vs 105) than MAGeCK-VISPR. With 2 residual df and calibration to the controls, BARCS's null is wider at the extreme tail.

## Limits

- No published gene table: agreement is judged against reference gene sets and the pathways and genes the paper names.
- The dasatinib arm has 2 vs 2 libraries (2 residual df) and needed control calibration.
- Only the LGR 100X growth screen and LGR dasatinib arm were reanalyzed; the 1000X, coverage-titration and legacy-library arms were not.
