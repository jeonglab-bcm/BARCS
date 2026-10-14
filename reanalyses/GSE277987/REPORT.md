# GSE277987 reanalysis with BARCS 0.2.3

**Paper.** "Molecular recording of cellular protein kinase activity with chemical labeling", *Nature Chemical Biology* 21:1818-1827 (2025), PMID 40640555, doi:10.1038/s41589-025-01949-6, PMC12568631 (open access). The authors labeled RKO cells with the Kinprola PKA activity recorder, sorted them into high, basal ("medium") and low labeling bins, and ran two independent genome-wide KO screens (Heidelberg HD CRISPR library A). Fig. 3b compares high vs low with limma on log-normalized counts (FDR 0.05). Canonical regulators (PRKACA, GNAS, ADCY7) score, and five new hits were validated: PES1, NOP2 and VPRBP/DCAF1 knockouts lower PKA activity, while TRIM33 and FZR1 knockouts raise it. The Fig. 3 Source Data (sheet "Fig.3b") holds the paper's gene table for all 18,659 genes. `prepare.R` downloads it unchanged.

**Series and counts.** `GSE277987_mapped.count.txt.gz` has one integer column per sample and sequencing lane (R{2,3}_{B,H,L,T0}_L1-4; each lane is its own GSM) plus `unassigned_L*`. The lanes are technical re-reads of one library (r = 0.98), so `prepare.R` sums them per sample and drops the unassigned columns. This gives 8 libraries of 23-32 M reads for 74,987 guides, with 159 `NONTARG` controls. Genes are Ensembl IDs; symbols below come from the paper's table. The top 1% of guides hold at most 4.3% of reads.

## Design

The primary analysis is **high vs low, `~ bin`, fitted on the high, basal and low bins of both screens** (6 libraries, residual df 3; basal contributes to the dispersion). There is no screen term: bins correlate more across screens (high-high 0.95, low-low 0.95) than with the other bins of the same screen (0.91-0.94). The paper's Extended Data comparisons, high vs basal and low vs basal, are in `design_vs_basal.json`.

| Analysis | Raw control p<0.05 | Genes FDR 0.10 | up / down | Control null | Control shift |
|---|---|---|---|---|---|
| high vs low | 5.7% | 2,272 | 1,253 / 1,019 | 2,495 (centred on targets) | +0.43 z |
| high vs basal | 6.3% | 776 | 654 / 122 | 777 (centred on targets) | +0.37 z |
| low vs basal | 3.1% | 872 | 439 / 433 | 992 (centred on controls) | -0.06 z |

No calibration was needed. The non-targeting guides sit 0.43 z towards the high bin compared with targeting guides, which is typical of non-cutting controls, so the control null is centred on the targeting guides. It agrees with the model (2,495 vs 2,272).

## Agreement with the paper

Every named gene is called at FDR < 1e-9, in the paper's direction (rank by p, both directions, of 18,658 genes):

- **FZR1** #8, up in high
- **ADCY7** #53, down
- **PRKACA** #62, down
- **TRIM33** #181, up
- **GNAS** #185, down
- **VPRBP/DCAF1** #239, down
- **NOP2** #268, down
- **PES1** #420, down

PRKAR1A, the PKA regulatory subunit, comes up as expected for a negative regulator (#118, up in high).

The paper's table has 2,310 genes at FDR 0.10 (1,711 at FDR 0.05). Its highlighted set of 340 genes passes FDR 0.05 and a fold-change cut (|log2 FC| > about 1.1), and every one of those 340 is called by BARCS. At FDR 0.10 the two lists are about the same size and share 1,613 genes. Gene effects correlate at r = 0.98 with the paper's mean log2 fold change, and the top-500 overlap is 372. The rank differences are modest. BARCS puts first genes whose four guides move together with high counts, such as RNGTT, TADA2B, ENO1, GINS4, TADA1, THAP11 and FECH (paper ranks 53-213). The paper's #1, CPSF3, is BARCS #124.

## Limits

There are two screens, analyzed without a screen term. Many genes move between bins, including core-essential genes (the paper's table flags 646 genes as dependencies and its authors removed core-essentials from the hit list), so the FDR 0.10 list is long. Calls should be read as "changes the recorder signal", which can include effects on cell state, not only direct PKA regulation.
