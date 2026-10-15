# GSE266057 reanalysis with BARCS 0.2.3

**Paper.** "A systematic search for RNA structural switches across the human transcriptome", *Nature Methods* (2024), PMID 39014073, doi:10.1038/s41592-024-02335-1 (PMC11399106).

**Screen.** Genome-wide CRISPRi (hCRISPRi-v2, 5 guides per TSS, 104,663 guides, 1,881 non-targeting) in Jurkat cells with a GFP reporter carrying the RORC 3' UTR RNA switch. One line has the native sequence (WT), the other the 77-GA mutant that favours conformation 1. Cells were sorted into the top and bottom 25% of the GFP:mCherry ratio, two replicates per line. The authors fitted a GLM per gene (iAnalyzer), z-scored to non-targeting guides. They named SMG8, UPF1, UPF2 and UPF3B as top hits in the high-vs-low comparison across both lines (Fig. 6a), and the SURF complex (SMG1–UPF1–eRF1–eRF3) but not the exon junction complex as acting on the switch. They also compared lines with a DESeq2 "ratio of ratios" (Fig. 6b). The supplement holds the read counts (Data file S10, identical to GEO) but no gene-level table, so the comparison uses the named genes.

**Counts.** The GEO table has an unnamed guide column. `prepare.R` names it, takes the gene from the guide ID (text before the first underscore) and shortens the self-describing column names (`WT_low_1` and so on). Counts are unchanged.

**Design.**
- `high_vs_low`: all eight libraries, `~ pool + bin`. Pool (reporter × replicate) pairs the two bins sorted from one culture. 3 residual df, prior df 146.
- `GA77_vs_WT_bin_interaction`: `~ pool + bin + ga77_high`, where `ga77_high` marks the 77-GA high bin. It estimates how much more a knockdown raises the 77-GA reporter than the WT reporter. 2 residual df.

**Calibration.** In `high_vs_low`, 7.1% of non-targeting guides reach p < 0.05. That is just under the 7.5% threshold, so no calibration was applied, and the model's list is probably somewhat long. The interaction analysis has 5.6%. Composition is flat: the top 1% of guides hold 3.7–3.8% of reads. The guide correlation is 0.004.

## Results

| | high vs low (both lines) | 77-GA vs WT interaction |
|---|---|---|
| Genes at FDR 0.10 (model) | 1,480 (801 up, 679 down in GFP-high) | 2 (SMG8, CSDE1) |
| Genes at FDR 0.10 (control null) | 745 | 0 |
| UPF2 / UPF3B / SMG8 | #2 / #3 / #4 overall, FDR < 1e-80 | SMG8 #1 (FDR 3e-7); UPF3B #14 |
| UPF1 | #28 overall (#16 enriched), FDR 6e-32 | #2,418 |
| SMG5 / SMG9 / SMG7 | #33 / #85 / #145, all FDR < 1e-12 | SMG9 #4, SMG5 #5 (FDR 0.33) |
| SMG1 / SMG6 | FDR 8e-4 / 1e-4, small effects (0.05, 0.19) | n.s. |
| eRF3 (GSPT1) / eRF1 (ETF1) | depleted in GFP-high, FDR 4e-17 / 2e-7 | n.s. |
| EJC: EIF4A3 / RBM8A / MAGOH | FDR 0.008 (small) / 0.80 / 1.0 | n.s. |

## Where BARCS agrees and differs

- **Agrees.** The four NMD factors the paper names are among BARCS's 28 strongest genes, and UPF2, UPF3B and SMG8 rank second to fourth. The SMG5–SMG7–SMG9 arm follows. The exon junction core (RBM8A, MAGOH) is flat, which matches the paper's point that the switch uses EJC-independent NMD. PGK1 ranks first: knockdown of the PGK1 promoter, which most likely drives the mCherry normaliser, raises the GFP:mCherry ratio. It is a reporter artifact, not a regulator of the switch.
- **Differs in detail.** SMG1 knockdown barely moves the reporter in BARCS (effect 0.05), although the paper counts it in the SURF complex. Knockdown of eRF1 and eRF3, which are essential, lowers rather than raises the reporter. The model calls 1,480 genes, against 745 from the control null. Calibration was just under its trigger, and most of the extra calls are small effects (median |log2| 0.18). The 745 is the safer figure. In the interaction analysis, SMG8 alone is clearly stronger for the WT switch than for 77-GA, with SMG9, SMG5 and UPF3B in the same direction below the FDR threshold. This agrees with the paper's Fig. 6b, where NMD knockdown narrows the gap between the two switches. The paper's ratio-of-ratios genes are not available for a gene-level comparison.

## Limits

- Two sorted replicates per reporter line. The interaction rests on 2 residual df.
- No gene-level table was published, so only the named genes can be compared.
