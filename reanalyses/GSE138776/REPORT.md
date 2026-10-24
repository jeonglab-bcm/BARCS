# GSE138776 reanalysis with BARCS 0.2.3

**Paper.** "Stabilization of ERK-Phosphorylated METTL3 by USP5 Increases m6A Methylation", *Molecular Cell* (2020), PMID 33217317, doi:10.1016/j.molcel.2020.10.026 (PMC7720844).

**Screen.** Genome-wide GeCKO knockout screen in HeLa cells carrying a circular-RNA m6A-GFP reporter: m6A on the GGACU reporter drives GFP translation, so knockouts of positive m6A regulators give low GFP. Cells in the top and bottom 5% of GFP were sequenced (one library each). Paper method: ranked gene lists per bin plus RAS/MAPK pathway (GSEA) enrichment; the paper validated USP5 and the ERK pathway biochemically. (The rest of this series is mouse-ESC m6A-seq/RNA-seq, a companion assay not used here.)

**Design.** `~ bin`, low-GFP vs high-GFP, 2 libraries, 0 residual df. One library per condition, so the no-replicate path pools overdispersion across the 994 dummyguide controls; calls are screening-level.

## Results

BARCS calls **0 genes at FDR 0.10**. The guides are highly overdispersed relative to Poisson (77x inflation at rho = 0 across a single pair of libraries), so no gene reaches significance. The genes the paper highlights rank randomly and far from significant: METTL3 #16771, WTAP #4602, MAPK1 #3708, USP5 #20137 of 20,677 (all FDR = 1).

## Agreement with the paper

This is a **differ** result, but it is consistent with the paper's own data: the named individual genes (METTL3, WTAP, USP5, ERK/MAPK) do not appear in the paper's top-1000 ranked gene lists either (Table S1). The paper drew its conclusions from pathway-level GSEA and biochemical validation, not gene-level screen significance. With a single library per bin there is no replicate variance to separate signal from noise, and BARCS, which models that overdispersion, calls nothing.

## Limits

- One library per condition: no biological replicates, screening-level at best, and here uninformative at the gene level.
- The reporter screen was a discovery tool for pathways, not a calibrated gene-level screen.
