# GSE268533 reanalysis with BARCS 0.2.3

**Paper.** "Synthetic lethal CRISPR screen identifies a cancer cell-intrinsic role of PD-L1 in regulation of vulnerability to ferroptosis", *Cell Reports* 2024, PMID 38985676.

**Why it was excluded before.** Only MAGeCK-normalized counts with replicates pooled into one column per condition were deposited.

**Count recovery.** `GSE268533_CP_all.count_normalized.txt.gz` is raw reads times one constant per sample (MAGeCK median normalization, unrounded). x / s is an integer (within ~3e-6) for 100.0% of positive values in both columns at k=1. Recovered integers in `recovered_counts.tsv`; totals 20 M (sgControl) and 29.5 M (sgCD274) reads.

**Screen.** Genome-wide Brunello KO (~77.4k guides, 1000 non-targeting) in CAL27 HNSCC cells, PD-L1 knockout (sgCD274) vs control (sgControl). GEO states duplicates, but only one column per arm was deposited (duplicates pooled), so this is one library per condition and BARCS uses the no-replicate path.

**Design.** `~ condition`, sgCD274 vs sgControl, 2 libraries, 0 residual df; synthetic-lethal genes deplete in the PD-L1-KO arm.

## Results
- 0 genes at FDR 0.10. The no-replicate overdispersion pooled from controls is near-Poisson, so a single pair of pooled libraries yields an inflation factor of ~650 and no gene survives.
- Compared against the paper's own deposited MAGeCK `gene_summary`: Spearman rank correlation of gene scores **0.68**, effect-direction agreement 95%, but top-N overlap is poor (Jaccard 0.01-0.04).
- The mechanism genes the paper discusses (SOD2, GPX4, SLC7A11, ACSL4) are downstream biology, not screen hits, and rank in the middle of the list.

## BARCS vs paper
The paper's own deposited MAGeCK table has **no gene passing FDR** (minimum neg|fdr ~0.92); its ferroptosis conclusion rests on pathway-level enrichment and orthogonal experiments, not single-gene screen calls. BARCS reproduces that null (0 genes) and its gene scores correlate moderately (0.68) with the paper's MAGeCK. Neither method calls individual genes from this single pooled pair.

## Limits
One pooled library per condition (screening-level, no replicate variation measured). With 0 residual df no single-gene inference is possible; this screen cannot be used to confirm or refute specific genes.
