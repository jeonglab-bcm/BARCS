# GSE325129 reanalysis with BARCS 0.2.3

**Paper.** "A multi-subunit autophagic capture complex facilitates degradation of ER-stalled MHC class I in pancreatic cancer", *Molecular Cell* 2026, PMID 42214332 (PMC13380935, doi 10.1016/j.molcel.2026.05.005).

**Screen.** Genome-wide CRISPRi (hCRISPRi-v2, ~104.5k guides, 1895 non-targeting) in PaTu8902 PDAC cells stably expressing dCas9-KRAB. Cells were stained for surface MHC-I and the top and bottom 30% sorted (one library per bin, about 143 M and 153 M reads; no unsorted sample deposited).

**Counts.** `GSE325129_ACV_Patu_MHCI_CRISPRi_rawcountstable.txt.gz` (ScreenProcessing raw counts, integers). `prepare.R` drops the four header lines (condition, replicate, source file, `sgId`) and takes the gene from the sgId prefix, so guides for alternative promoters (-P1/-P2) are pooled per gene. Column mapping is certain: the header names the source fastq files (Patu8902_High / Patu8902_Low), and B2M, TAP1 and HLA-A guides are higher in the MHC-I low bin as expected.

**Paper's analysis.** ScreenProcessing (Horlbeck): guides with <10 reads in both bins removed, phenotype = log2 high/low, gene scores from the strongest guides with Mann-Whitney p-values. No gene table is published; the abstract names the ER E3 ligase NFXL1 as the screen hit, and TEX264-NBR1 as the capture complex (established mainly by other experiments).

**Design.** MHC-I high vs low bin, `~ bin`, library totals (composition is similar: top 1% of guides hold 3.9% of reads in both). **One library per bin, no replicates**: BARCS uses the no-replicate path (overdispersion pooled over 1875 non-targeting guides, rho = 3e-7); calls are screening-level and the FDR does not include variation between replicate sorts.

## Results
- Controls are calibrated (4.4% of non-targeting guides at p < 0.05; control shift 0.04 z, null centred on controls).
- **165 genes at FDR 0.10** (69 higher in the MHC-I-high bin, 96 higher in the low bin); 216 against the control null.
- The MHC-I low bin recovers the antigen-presentation pathway with several concordant guides each: **NLRC5 #1** (MHC-I transactivator, all five guides 4-11x), TAP1 #8, B2M #16, HLA-A #35, plus ER-to-Golgi trafficking genes (TMED2). This is a strong positive control for the mapping and the analysis.
- MHC-I high bin (candidate MHC-I suppressors): B3GNT2, FAM3A, JUNB, SCFD1, CAD, COPB2, FBXO42 at the top.

## Named hits
- **NFXL1**: rank 455 among genes enriched in the high bin (by p), p = 0.025, FDR 0.52. Only one of five guides moves (257 -> 876 reads, 3.4x, guide p = 0.007); the other four are within 1.25x. ScreenProcessing scores a gene by its strongest guides, which can lift a one-guide gene; BARCS combines all guides and does not call it.
- **TEX264** (rank 3882, FDR 0.94) and **NBR1** (rank 2440, FDR 0.87): no signal in the screen; the paper's support for them comes from other experiments.

## BARCS vs paper
BARCS does not reproduce the screen's named hit: NFXL1 rests on one guide and is not significant once all five guides are combined. The screen itself is sound (the MHC-I pathway dominates the low bin), so the difference is in how a single strong guide is weighed, not in data quality.

## Limits
One library per bin and no replicate sorts or unsorted reference: screening-level calls. The published gene scores are not deposited, so the comparison rests on the named genes only.
