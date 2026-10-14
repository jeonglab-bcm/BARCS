# GSE236257 reanalysis with BARCS 0.2.3

**Paper.** Spisak et al., "Identifying regulators of aberrant stem cell and differentiation activity in colorectal cancer using a dual endogenous reporter system", *Nature Communications* 15 (2024), PMID 38472198, doi:10.1038/s41467-024-46285-w (PMC10933491, open access).

**Screen.** A focused CRISPR knockout screen of 542 sgRNAs on 78 epigenetic regulators (plus reporter guides SOX9, KRT20, EGFP, mKate2 and 30 safe-harbor negative controls: AAVS1, CCR5, ROSA26) in HT29 SOX9-mKate2 / KRT20-GFP dual endogenous reporter CRC cells. SOX9-mKate2 marks aberrant stem-cell activity, KRT20-GFP marks differentiation. Cells were FACS-sorted and sgRNA abundance compared between fractions; the paper scored genes with MAGeCK-MLE beta on **3 technical replicates** and a rank-sum method, and nominated **SMARCB1** (BAF/SWI-SNF) as a negative regulator of differentiation, plus HDAC3, SET, AEBP2, RBBP4, DNMT3B, SETD1A/B (differentiation inducers) and SUZ12, SMARCD2, DNMT1, KMT2A (SOX9 suppressors).

## Caveats for this series

- **Only 2 replicates are deposited** (Gate1 Rep1/Rep2, Gate2 Rep1/Rep2), although the paper reports 3 technical replicates. Each contrast therefore has 2 residual degrees of freedom at most.
- **Only 30 negative-control guides.** That is far below the ~100 needed for a control null, and — critically — in the extreme-fraction contrasts the controls are not a stable baseline (see below), so gene-level FDRs there cannot be calibrated.
- The deposited count matrix is transposed (guides in columns). It was transposed back and the fraction labels recovered from the `Epigenetic_Screen_Design` sheet (Gate2 L3/L6 map to the GFP, DP/++, DN/--, mCh dual sort; Gate1 L1/L4 are KRT20-GFP quartiles, L2/L5 SOX9-mKate2 quartiles).

## Design and results

| Contrast | Libraries | Control p<0.05 (raw/calibrated) | Genes at FDR 0.10 | Calibration |
|---|---|---|---|---|
| **GFPhigh vs mKate2high** (dual, Fig 3d-e) | 2 vs 2 | 0% / 0% | 9 | clean |
| KRT20-GFP high vs low quartile (Fig 2f) | 2 vs 2 | 100% / 100% | 89 | uncalibratable |
| SOX9-mKate2 high vs low quartile (Fig 1h) | 2 vs 2 | 100% / 100% | 82 | uncalibratable |
| DN/-- vs DP/++ | 2 vs 2 | 100% / 100% | 92 | uncalibratable |

The three extreme-fraction contrasts compare the tails of a sort, where the whole library composition shifts; all 30 safe-harbor controls reach p < 0.05, so their FDRs are inflated and their long hit lists cannot be trusted. Only the **dual GFP-high vs mKate2-high** contrast is calibrated (0% of controls at p < 0.05).

## Where BARCS agrees and differs

- **Positive controls are textbook-correct in the clean contrast.** In GFP-high vs mKate2-high, mKate2 and SOX9 sgRNAs are the top enriched genes (losing the SOX9-mKate2 stem reporter / knocking out SOX9 pushes cells into the differentiated GFP-high fraction), while EGFP and KRT20 sgRNAs are the most depleted (they destroy the GFP reporter). This is strong validation that the mapping and the data are right.
- **The paper's named differentiation inducers appear only in the uncalibratable quartile contrast.** In KRT20-GFP high vs low, SMARCB1 (the headline gene), HDAC3, SET, RBBP4 and DNMT3B are all enriched at nominal FDR < 0.01 — matching the paper. But that contrast has 100% of controls at p < 0.05, so those FDRs are not trustworthy; the same list includes ~85 other genes.
- **In the one calibrated contrast, SMARCB1 is not significant** (estimate +0.065, p 0.63, rank 12). The calibrated contrast's own calls (EP300, KMT2D, KMT2C, SETDB2 depleted in GFP-high) are not the paper's headline genes.
- **Why.** The paper's beta scores used 3 replicates and MAGeCK-MLE across all fractions jointly, and its rank-sum method does not depend on a control null. BARCS, given 2 deposited replicates and 30 controls, can either (a) use the clean dual contrast, where SMARCB1's small effect does not clear the noise, or (b) use the extreme-quartile contrasts, where SMARCB1 is recovered but nothing can be calibrated. Neither reproduces the paper's confidence in SMARCB1 from the deposited data.

## Limits

- 2 replicates deposited vs 3 reported; 30 negative controls, too few for a control null.
- Extreme-fraction contrasts are uncalibratable (controls all shift), so their FDRs are nominal only.
- SMARCB1 is recovered by direction and nominal rank but is not confirmable at a trustworthy FDR from the deposited counts; the paper's MLE/rank-sum pipeline on 3 replicates is more powered.
