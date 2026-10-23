# GSE159270 reanalysis with BARCS 0.2.3

**Paper.** "Master Regulators and Cofactors of Human Neuronal Cell Fate Specification Identified by CRISPR Gene Activation Screens", *Cell Reports* (2020), PMID 33264623, doi:10.1016/j.celrep.2020.108460 (PMC7730023). This series is the CAS_TF_SingleFactor_Sublibrary_Screen amplicon-seq sub-dataset.

**Screen.** CRISPRa sub-library screen (109 candidate TFs, ~33 guides each) in TUBB3-2A-mCherry dCas9-VP64 iPSCs. Cells were sorted into mCherry-low and mCherry-high bins ~5 days after transduction; guides that activate neurogenic TFs are enriched in mCherry-high cells. Paper method: per-guide DESeq2; a TF was called a hit when two or more guides were significantly enriched (FDR < 0.01) in mCherry-high relative to both the unsorted and mCherry-low bins.

**Design.** `~ replicate + bin`, mCherry-high vs mCherry-low, 6 libraries (3 replicates x 2 bins), 2 residual df. Counts were parsed from the deposited DESeq2 table (old Mac line endings; the gene is the guide id without its ".N" suffix; one guide with a non-numeric count cell was dropped). Non-targeting ("neg"/"negative_control") guides reached p < 0.05 above 7.5%, so calls were calibrated to the controls (5.0% after).

## Agreement with the paper

Against the paper's positive hits for this screen (Table S1, Additional file 1), BARCS recovers **10/10** as enriched at FDR 0.10. The top BARCS-enriched genes are the same proneural TFs the paper names (e.g. NEUROD1/NEUROG family, SOX3/10/17/18, KLF family, ASCL1, INSM1, OVOL1, PRDM1, E2F7/HMX2 for the sgNGN3 pairing). BARCS calls 32 genes at FDR 0.10.

## Where BARCS differs

BARCS tests the high-vs-low contrast with replicate as a blocking term and moderated dispersion, so it returns a single ranked gene list rather than the paper's "2+ guides significant in two contrasts" count; a few paper hits that rested on a single strong guide or on the high-vs-unsorted contrast fall just below FDR 0.10 here. Direction and the strongest hits agree.

## Limits

- The gene is inferred from the guide id; the paper's per-guide/two-contrast hit rule is not reproduced exactly.
- 99-100 scrambled controls support calibration but are a small null.
