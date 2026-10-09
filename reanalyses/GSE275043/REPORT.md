# GSE275043 reanalysis with BARCS 0.2.2

**Paper.** "Genome-wide CRISPR screen identifies IRF1 and TFAP4 as transcriptional regulators of Galectin-9 in T cell acute lymphoblastic leukemia", *Science Advances* (2025), PMID 40106574, doi:10.1126/sciadv.ads8351 (PMC11922064).

**Screen.** A Brunello knockout library (77,441 guides, 1,000 non-targeting) in Jurkat T-ALL cells. Cells were stained for Galectin-9 (LGALS9) and sorted into the top and bottom 20%, in two replicate infections; unsorted cells were also sequenced. GEO holds one count file per sample, which were joined on guide sequence. Bin and replicate come from the file names and GSM titles. The authors ran MAGeCK on each replicate separately and took genes at FDR < 0.15 in both replicates (41 genes enriched in the Galectin-9-low bin) into a validation screen. That screen confirmed IRF1, TFAP4 and ADD1, with LGALS9 itself as the positive control. No genome-wide gene table was published; the supplementary tables S1–S3 hold cancer-type abbreviations, regulons and primers.

**Design.** `~ replicate + bin`, Galectin-9-high vs -low, 4 libraries, 1 residual df. Both bins of a replicate were sorted from one infected population. Positive regulators of Galectin-9 are depleted in the high bin.

**Calibration.** 4.1% of non-targeting guides reached p < 0.05, so no calibration was needed. Composition is unremarkable: the top 1% of guides hold 3% of reads in every library.

## Results

| | BARCS 0.2.2 | Paper (MAGeCK per replicate, then validation) |
|---|---|---|
| Genes at FDR 0.10 | 489 (358 depleted in high, 131 enriched); 681 against the control-guide null | 41 low-bin genes at FDR < 0.15 in both replicates |
| LGALS9 (positive control) | **#2, FDR 2 × 10⁻¹²** | top hit in both replicates |
| TFAP4 | **#3, FDR 2 × 10⁻¹²** | validated |
| ADD1 | **#4, FDR 2 × 10⁻¹²** | validated |
| IRF1 | **#13, FDR 2 × 10⁻⁸** | top-scoring transcription factor, validated |
| #1 | GATA3 | |

## Where BARCS agrees and differs

- **Agrees.** The target gene and all three validated regulators are in the BARCS top 13 of 19,114 genes. IRF1 has the second-largest effect after LGALS9, but only three of its four guides pass the count filter (one has 16 reads in total), which costs it rank.
- **More calls.** BARCS calls many more genes than the paper's FDR < 0.15-in-both-replicates rule. Many of the extra genes affect fitness rather than Galectin-9 levels: 75 of the 489 calls are ribosomal or translation-initiation genes (RPL, RPS, EIF), and MYB, HSPA5 and FAU, which the paper's validation screen flagged as essential-gene artifacts, pass FDR 0.10 too. The paper removed such genes using the unsorted sample and DepMap. BARCS's FDR is valid for "differs between bins", not for "regulates Galectin-9", so a fitness filter is still needed. GATA3, the BARCS #1, is a Jurkat lineage factor; whether it acts directly on LGALS9 or through fitness cannot be told from this sort.

## Limits

- Two replicates (1 residual df); the dispersion prior carries most of the variance estimate.
- No published gene table, so only the named hits can be compared.
- The sort compares bins, so fitness effects on sorted cells contaminate the hit list.
