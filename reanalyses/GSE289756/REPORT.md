# GSE289756 reanalysis with BARCS 0.2.3

**Paper.** "The essential clathrin adapter protein complex-2 is tumor suppressive specifically in vivo", *Nat Commun* 2025, PMID 40050266 (PMC11885535, doi:10.1038/s41467-025-57521-2).

**Screen.** Targeted KO library (660 sgRNAs: 5 per gene for 112 PtdIns-metabolism genes, 10 ribosomal-protein positive controls, 50 control sgRNAs) in five pancreatic cancer lines (BXPC-3, CFPAC-1, HPAF-II, MIAPACA-2, PANC-1). Per line: 4 initial cultures, the same 4 cultures after two weeks of passaging (final), and 8 xenograft tumors (4 male, 4 female mice). Raw integer counts from `GSE289756_RawsgRNACounts.xlsx` (sheet NoMismatches_Counts, 80 libraries).

**Counts.** `prepare.R` writes `raw_counts.tsv`: gene = sgRNA name without its `-N` suffix; ribosomal positive controls (`sgRPL11_1` ..) get their gene (RPL11); the 50 control sgRNAs keep their group (ControlA..ControlJ, pattern `^Control`). The controls behave as non-targeting (their share rises in final cultures as targeting guides deplete). Fewer than 100 controls, so the control null is not available.

**Design.** The paper scores each gene as the mean of its five guides' fold changes against the paired initial culture, z-scores them on the control guides, and compares in vivo with in vitro by t-test per line (Fig. 1b; Source Data sheet Figure1B). The BARCS equivalent per line is tumors vs final cultures (`~ site`, 8 vs 4 libraries, 10 residual df, moderation applied, prior df 4-6, guide correlation 0-0.03). Tumors are not tied to particular cultures in the deposit, so the contrast is unpaired. Tumors are strongly clonal (top 1% of guides = up to 94% of a library's reads, usually PTEN or AP2 guides), so the tumor analyses use median-ratio totals (capped at the largest count in four MIAPACA-2 tumors and one PANC-1 tumor). A second analysis, final vs initial cultures in all lines, paired by culture (`~ culture + stage`, control totals, 19 residual df), checks in vitro essentiality.

**Positive controls.** In culture all ten ribosomal-protein genes are among the 13 most depleted genes (FDR < 1e-13), with AP2M1, AP2S1, AP2A1, AP2B1 and AP2A2 also strongly depleted (FDR 1e-21 to 1e-6), reproducing the paper's in vitro essentiality of AP2. With control totals, 121 of 132 genes are depleted relative to the controls (cutting toxicity in cancer lines); the ranks, not the count, are informative there.

## Results: tumor vs culture (enrichment = in vivo tumor suppressor)

| Line | BARCS FDR<0.10 | Paper FDR<0.10 | AP2M1 / AP2S1 / AP2A1 / AP2B1 / PTEN BARCS rank (enriched, of 122) | Spearman vs paper |
|---|---|---|---|---|
| BXPC-3 | 0 | 39 | 1 / 5 / 2 / 8 / 9 (FDR 0.11-0.15) | 0.64 |
| CFPAC-1 | 4 (all depleted) | 16 | 13 / 102 / 5 / 14 / 89 | 0.52 |
| HPAF-II | 14 (9 enriched) | 25 | 2 / 1 / 5 / 44 / 9 (AP2S1 FDR 0.004, AP2M1 0.010, AP2A1 0.094, PTEN 0.094) | 0.71 |
| MIAPACA-2 | 3 (all depleted) | 19 | 9 / 7 / 87 / 54 / 6 | 0.38 |
| PANC-1 | 0 | 14 | 4 / 3 / 40 / 1 / 2 (FDR 0.23) | 0.62 |

- BARCS ranks the paper's genes at the top in the lines the paper calls most sensitive: in BXPC-3 the top 5 enriched genes include AP2M1, AP2A1 and AP2S1 (8 of the paper's top 10 are in BARCS's top 10); in PANC-1 the top 4 are AP2B1, PTEN, AP2S1, AP2M1.
- But only in HPAF-II do AP2 subunits (AP2S1, AP2M1, AP2A1) and PTEN pass FDR 0.10. In BXPC-3 and PANC-1 the same genes sit at FDR 0.11-0.23.
- In CFPAC-1 and MIAPACA-2 (which the paper also ranks as weaker) the AP2 signal is weak or inconsistent across tumors.
- Paper-only significant genes include PTPMT1 (PANC-1, MIAPACA-2) and DPM1 (HPAF-II), mostly genes whose in vitro depletion drives the paper's vivo-minus-vitro t-test.

## Why BARCS differs
The paper's t-test compares 8 tumor z-scores with 4 culture z-scores of gene means; the culture replicates are nearly identical, so the test has a small variance and calls 14-39 genes per line. BARCS models each guide's counts with the tumor-to-tumor overdispersion, which is very large: each xenograft is dominated by a few clones (PTEN guides alone take up to 20% of reads in some tumors). Directions agree (Spearman 0.38-0.71 with the paper's signed scores; 54-85% sign agreement), but BARCS needs more consistency across the 8 tumors before it calls a gene. 

## Limits
Unpaired tumor vs culture contrast; xenografts are bottlenecked, so tumor libraries are clonal and median-ratio totals were capped in five tumors. Fewer than 100 controls, so no control-null count. The comparison table (`paper/fig1b_<line>.csv`) is the paper's Figure 1B source data; `signed_log10p` and `vivo_minus_vitro` were added by `prepare.R` for ranking.
