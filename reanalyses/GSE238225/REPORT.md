# GSE238225 reanalysis with BARCS 0.2.3

**Paper.** "CRISPR GENome and epigenome engineering (CRISPRgenee) improves loss-of-function genetic-screening approaches", *Cell Reports Methods* 2025, PMID 40499551 (PMC12272254).

**Why it was excluded before.** Only normalized, non-integer guide counts were deposited for the CRISPRgenee dropout screen.

**Count recovery.** `GSE238225_Normalized_Counts_CRISPRgate.tabular.txt.gz` is raw reads times one constant per sample (unrounded). x / s is an integer (within ~1e-5) for 100.0% of positive values in all six columns (biological replicates recover at k=1; the three plasmid-pool columns at k=2 or k=4, i.e. v_min is a small integer multiple of the read scale). Recovered integers in `recovered_counts.tsv`; totals 3.2-7.2 M reads. Verified against the paper's Table S7 CRISPRgenee sheet: the deposited "biological replicate" columns correlate >0.95 with the paper's SCC1-3 and the "sgRNA pool" columns with P1-3.

**Screen.** Dual-sgRNA CRISPRgenee dropout screen, 3,686 guides targeting 1,137 chromatin-regulatory genes plus 10 neutral controls, in three ZIM3-Cas9 TF-1 clones; day 14 vs the plasmid/E. coli sgRNA pool, 3 vs 3.

**Design.** `~ condition`, day14 vs pool, 6 libraries, 4 residual df. The 10 "Control" guides are the library's neutral controls. (The deposited pool-column order differs from Table S7; it does not matter for this unpaired design.)

## Results
- 728 genes at FDR 0.10 (422 up, 306 down). Guide correlation 0.09.
- The paper's internal positive controls all deplete strongly: **CSF2RA** (#20 depleted, FDR 2e-12), **ADAR** (FDR 6e-10), **MYC** (FDR 6e-10), **KDM1A** (FDR 1e-8), **RPA3** (FDR 5e-7), **SETD8** (FDR 4e-5). The top depleted genes are canonical essentials (DDX46, CHAF1B, NOP2, MCM2, NDC80...).
- BUB1, validated separately in the paper, is not in this chromatin-focused library.

## BARCS vs paper
This is a methods paper, not a hit-discovery screen; the benchmark is whether the designed positive controls and known essentials drop out. BARCS recovers every named positive control and the essential-gene signal, confirming the screen behaves as intended.

## Limits
No published single-gene FDR table to rank against (the paper reports ROC/AUC against gold-standard essentials); comparison is to the positive controls and essential genes the paper names.
