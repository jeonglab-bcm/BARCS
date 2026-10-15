# GSE243882 reanalysis with BARCS 0.2.3

**Paper.** "CRISPR screens in 3D tumourspheres identified miR-4787-3p as a transcriptional start site miRNA essential for breast tumour-initiating cell growth", *Communications Biology* (2024), PMID 39003349, doi:10.1038/s42003-024-06555-1 (PMC11246431).

**Screen.** GeCKO v2 genome-wide knockout library (119,461 guides, including about 1,800 miRNAs and 1,000 non-targeting guides) in MCF-7 (ER+) and HCC1395 (triple-negative) breast cancer cells. After selection, cells were collected at T0, then grown for 3–4 weeks in 2D culture or as 3D tumourspheres. Each cell line has one library per arm. The GEO count files are used as deposited (integer reads; column names match the GSM titles).

The authors ran MAGeCK-MLE (2D and 3D each against T0) and selected genes with FDR < 0.05 in 3D vs T0 and a 3D−2D beta difference beyond ±0.4:
- MCF-7: 235 depleted and 17 enriched protein-coding genes;
- HCC1395: 320 depleted and 24 enriched.

The headline hit is miR-4787-3p (depleted in tumourspheres). Its targets ARHGAP17, FOXO3 and PDCD4 are among the positively selected genes and were validated by 3′-UTR reporter assays. `prepare.R` builds the paper's table from Supplementary Data 1 (betas, FDRs and the 3D−2D difference; genes and miRNAs combined per cell line).

**Design.** 3D vs 2D, `~ culture`, one library each. With no replicates, `run_barcs.R` uses the no-replicate path (overdispersion pooled over the non-targeting guides), so the calls are screening-level. BARCS tests 3D against 2D directly; this is the same log-ratio contrast as the paper's 3D−2D beta difference. A second analysis per cell line, 2D vs T0, checks that the screen selected at all.

**Quality checks.**
- *MCF-7:*
  - Core-essential genes (Hart CEGv2) drop out weakly in 2D vs T0: median log fold change −0.35, against 0.0 for non-essential genes (NEGv1). Average precision is 0.76 (base rate 0.43). So the screen selected, but weakly.
  - Composition is moderate (the top 1% of guides hold 8–10% of reads).
  - Controls are calibrated: 3.8% of non-targeting guides reach p < 0.05.
  - The 3D library carries single-guide jackpots of up to 296,000 reads, from guides that held a few thousand at T0 and in 2D.
- *HCC1395:* The libraries are bottlenecked. The top 1% of guides hold 15% of T0, 31% of 2D and 37% of 3D reads, and the top guides hold 2.4–3.7 million reads. Core-essential genes do not separate from non-essential genes (average precision 0.53 against a base rate of 0.43). Following the skill, median-ratio totals were used, but the HCC1395 calls are not trusted.

## Results (MCF-7, 3D vs 2D)

| | BARCS | Paper (MAGeCK-MLE) |
|---|---|---|
| Calls | 14 genes at FDR 0.10 (5 enriched, 9 depleted in 3D); 6 against the control null | 252 protein-coding genes (235 depleted, 17 enriched) plus miRNAs, by FDR in 3D vs T0 and a beta-difference cut-off |
| hsa-mir-4787 | rank 2,814, estimate −0.89, p 0.21 | 3D−2D beta −0.76; FDR 0.044 in 3D vs T0 |
| ARHGAP17 | rank 1,153, +0.42, p 0.11 | +0.71 |
| FOXO3 | rank 2,236, −0.94, p 0.18 | −0.50 (negative, although the paper reports it as positively selected) |
| PDCD4 | rank 7,790, +0.05, p 0.46 | +0.55 |
| Rank correlation of \|effect\| | 0.49 | |
| Top-50 / 100 / 200 overlap | 2 / 13 / 40 | |
| Direction agreement | 70% of genes | |

**Jackpot guides behind the BARCS calls.** Most of the 14 calls rest on one guide that exploded or collapsed in one library:
- B3GNT5 (one guide 8,439 → 295,809), PHF6 (5,621 → 144,753), SLC30A8 (3,877 → 89,516), TMEFF1 (7,750 → 37,803) and NMU (4,857 → 56,172) each rest on one guide;
- PTGES3L-AARSD1, OMP, MAPK7, C1QTNF2 and ZNF544 rest on one guide with a 2D jackpot that falls in 3D.

These are clonal expansions in single tumourspheres and should be discounted. Only SLC44A5 (all six guides up 2–6-fold), ATP8B1 and LRRC37B move consistently across guides.

**HCC1395.** BARCS calls 99 genes (median-ratio totals), led by AARD, FAM9B, CT47A1 and TAS2R7, genes not expressed in breast cancer cells. These are bottleneck artifacts. The named hits rank 812 (FOXO3) to 18,341 (PDCD4). In the paper's own HCC1395 table, the miR-4787 3D−2D difference is only −0.16. Because the libraries are bottlenecked, the HCC1395 analysis is not part of this record or the website; only MCF-7 is reported.

## Where BARCS agrees and differs

- **Differs.** None of the named hits approaches significance in either cell line. The paper's own table is weak for them too:
  - miR-4787's FDR in 3D vs T0 is 0.044 in MCF-7 and 0.098 in HCC1395;
  - FOXO3's MCF-7 3D−2D beta is negative.

  The paper's gene lists use a beta-difference cut-off with no test of the 3D−2D difference. They are therefore much longer than any list a test that accounts for clonal drift between single libraries can support. BARCS pools the overdispersion of the non-targeting guides. That overdispersion is large in tumoursphere libraries (inflation 200-fold over Poisson in MCF-7), so few genes pass.
- **Agrees.** At the level of ranks the two methods are moderately correlated (Spearman 0.49 in MCF-7, 0.75 in HCC1395 on |effect|), but their top lists barely overlap.

## Limits

- One library per arm, with no replicate tumoursphere cultures. Clonal drift and gene effects cannot be told apart beyond what the non-targeting guides show, so the calls are screening-level.
- The HCC1395 libraries are bottlenecked from T0 onward.
- The positive control (core-essential dropout in 2D) works only weakly in MCF-7.
- The paper's ranking (a beta difference without a p-value) is compared by |effect|, not by significance.
