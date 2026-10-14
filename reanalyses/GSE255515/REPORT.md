# GSE255515 reanalysis with BARCS 0.2.3

**Paper.** "Rational Design of Immune Gene Therapy Combinations via In Vivo CRISPR Activation Screen of Tumor Microenvironment Modulators", *Cancer Discovery* (2026), PMID 41747251, doi:10.1158/2159-8290.CD-25-0545. The paper is not open access; what it reports is taken from the abstract and the GEO summary.

**Screen.** A focused CRISPRa library (APCM: 107 guides, three per gene for 35 genes and two for Tnfsf4) against antigen-presentation, cytokine and co-stimulation genes, in E0771 breast cancer cells injected intravenously into C57BL/6J mice. GEO holds raw integer counts for 14 lung tumor samples from five mice (GAA21.4 and GAT4.1-4.4; the suffixes L, R, LR and NC are not explained) and two libraries of the injected cell pool. The count file has no gene column; `prepare.R` adds it from the deposited library file without changing the counts. The deposited log2-normalized table was not used.

**Design.** `~ condition`, lung tumor vs cell pool, 16 libraries, 14 residual df. Activating an immunostimulatory gene should expose cells to immune rejection, so the paper's candidates should be depleted in tumors. The two cell-pool libraries correlate at 0.99 but differ far beyond Poisson (variance of the binomial z about 80 at 25,000 reads per guide), so they are kept as two libraries rather than summed. Several tumor samples come from the same mouse (up to five from GAT4.3) and are not independent; a mouse term is not possible because the cell pool has no mouse. GAT4.1L has only 28,000 reads; it was kept, since its guide profile correlates normally with the others (0.8-0.9).

**Calibration.** **The library has no non-targeting guides**, so calibration against controls and the control null could not be checked. The FDR rests on the model alone, across only 36 genes. Composition is unremarkable for a 107-guide library (top two guides hold 7-10% of reads) except GAT4.2L, where one B2m guide holds 16% of reads; no library has collapsed to a few clones. Guide correlation 0.073, somewhat high, consistent with the shared-mouse structure.

## Results

| Gene | BARCS depletion rank (of 36) | FDR | Guides |
|---|---|---|---|
| Cd80 | **#1** | 1.5 × 10⁻⁴ | all three down; Cd80.2 down 6.8-fold |
| Tnfsf18 | **#2** | 0.002 | all three down, 1.4- to 2-fold |
| Tnfsf14 | **#3** | 0.002 | all three down; two about 2.7-fold |
| Cxcl10 | #4 | 0.30 | one guide down 2.4-fold (p = 0.008), two flat |
| Tnfsf9 | #6 | 0.80 | all three down but noisy; Tnfsf9.1 has about 100 CPM |
| Ifng | #7 | 0.80 | one guide down 2.5-fold (p = 0.009), two flat |

BARCS calls 3 genes at FDR 0.10, all depleted: Cd80, Tnfsf18 and Tnfsf14.

## Where BARCS agrees and differs

- **Agrees.** The six genes the paper names as its top immunostimulatory candidates are six of BARCS's seven most depleted genes, and the three strongest (Cd80, Tnfsf18, Tnfsf14) pass FDR 0.01 with all guides falling.
- **Differs.** Cxcl10, Tnfsf9 and Ifng do not pass FDR 0.10. Each has one or two clearly depleted guides and one that does not move, and tumor-to-tumor variation is large. Tnfsf9 and Ifng are two of the three genes in the paper's final 4II combination; their selection rests on the follow-up experiments more than on this screen.
- The paper's own statistical method could not be checked (not open access; no gene-level table deposited), so only the named candidates are compared.

## Limits

- No non-targeting controls: the FDR could not be calibrated.
- Tumors from the same mouse share the mouse's immune environment, so the 14 tumor libraries carry fewer than 14 independent observations; the FDR is likely optimistic. With five mice, a per-mouse analysis would have too few libraries to be useful.
- The meaning of the tumor sample suffixes is not given in GEO.
