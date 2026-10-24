# GSE146841 reanalysis with BARCS 0.2.3

**Paper.** You et al., "QRICH1 dictates the outcome of ER stress through transcriptional control of proteostasis", Science (2021), PMID 33384352, doi:10.1126/science.abb6896 (PMC8315080).

**Screen.** Genome-wide knockout library (about 4 guides per gene, 1,000 non-targeting) in HT29 cells with an endogenous XBP1s-GFP reporter, treated with tunicamycin (Tm) or DMSO and sorted into GFP-high and GFP-low bins, three replicates. GEO puts everything under one GSM; prepare.R downloads the count matrix and the authors' MAGeCK-MLE result for the Tm sort (Tm_H-Tm_L), the published comparison. Only the abstract of the paper was accessible, which names QRICH1; the reporter's own pathway genes (XBP1, ERN1) serve as positive controls.

**Design.** `~ rep + sort`, Tm GFP-high vs GFP-low, 3 vs 3, replicate paired (each replicate's bins correlate most strongly with each other). 2 residual df; moderation gave infinite prior df. Depleted in GFP-high = needed for the XBP1s reporter.

**Checks.** 5.5% of controls at p < 0.05, no calibration needed. Controls sit at the targeting guides (shift -0.08); the control null calls 149 genes, against the model's 91.

## Results

| | BARCS 0.2.3 | Authors (MAGeCK-MLE, Tm_H-Tm_L) |
|---|---|---|
| Genes at FDR 0.10 | 91 (79 lower in GFP-high, 12 higher); 149 against the control null | 51 at Wald FDR 0.10 |
| XBP1 / ERN1 (reporter pathway) | #17 / #15, FDR 0.009 | FDR 0.002 / 0.04 |
| QRICH1 (headline) | #126, estimate -0.89, FDR 0.17 | FDR 0.38 |
| MFSD2A | #1 | #1 |
| Rank correlation / top-100 overlap | 0.14 / 56 of 100 | |
| Direction agreement | 84.7% of genes | |

## Where BARCS agrees and differs

- **Agrees on the core of the screen.** The reporter's own pathway, ERN1 (IRE1) and XBP1, is called at FDR 0.01, and MFSD2A is #1 in both analyses. More than half of the top-100 lists are shared, and most of the shared genes are translation, tRNA-synthetase and ER-translocation genes.
- **QRICH1 is not called.** QRICH1 is lower in GFP-high (estimate -0.89, rank 126) but stays at FDR 0.17. The authors' own MLE table puts it at FDR 0.38, so neither analysis calls it from this screen alone; the paper's case for QRICH1 rests on integrating single-cell RNA-seq and follow-up experiments.
- **Single-guide jackpots.** ITPK1 (#4), CLEC12A and EXO1 rank high in BARCS on one guide each with 18,000-35,000 reads in a single library, and their effect estimates disagree in sign with their test statistics. They are artifacts and should be discounted. The rank correlation of 0.14 reflects such noise in the long tail of a sort screen.

## Limits

- Three replicates and 2 residual df; one sort per replicate. Only the abstract of the paper could be read, so named hits beyond QRICH1 come from the deposited MLE table and the reporter design.
