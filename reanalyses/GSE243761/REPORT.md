# GSE243761 reanalysis with BARCS 0.2.1

**Paper.** "Mechanosensitive genomic enhancers potentiate the cellular response to matrix stiffness", *Science* (2025), PMID 40997217, doi:10.1126/science.adl1988 (PMC13005951).

**Screen.** CRISPRi tiling of 114 DNase-hypersensitive sites (DHS) around MYH9 (5,191 guides, 500 non-targeting). The cells were sorted on MYH9 protein into low and high bins, in two replicates. The deposited file has only a guide column, so the element was taken from each guide label.

**Design.** `~ replicate + bin`, MYH9-low vs MYH9-high, 4 libraries, 1 residual df.

**Calibration.** 56% of non-targeting guides reached p < 0.05 before calibration. That is a very strong excess, consistent with shared clonal structure between the sorted bins of one replicate. After calibration it was 5%.

## Results

| Element | Paper | BARCS rank (of 114) | FDR |
|---|---|---|---|
| DHS_45 (pRE#1, intron 3) | top mechanoenhancer | 1 | 2 × 10⁻⁵⁸ |
| DHS_47 (intron 3) | named | 2 | 2 × 10⁻²⁹ |
| DHS_46 (intron 3) | named | 3 | 1 × 10⁻²¹ |
| DHS_72 (promoter) | named | 5 | 2 × 10⁻¹⁵ |
| DHS_71 (promoter) | named | 34 | 5 × 10⁻⁷ |

## Where BARCS agrees and differs

- **Agrees.** All five named elements are enriched in MYH9-low cells, and four are in the top five.
- **Long hit list.** 99 of 114 elements pass FDR 0.10 even after calibration. Many DHS near a strongly expressed gene can lower it slightly, but the length also reflects how much the two replicates share. Read the ranking rather than the count.

## Limits

- One residual degree of freedom.
- The element labels were parsed from guide names.
