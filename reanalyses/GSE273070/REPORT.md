# GSE273070 reanalysis with BARCS 0.2.1

**Paper.** "Reporter CRISPR screens decipher cis-regulatory and trans-regulatory principles at the Xist locus", *Nature Structural & Molecular Biology* (2025), PMID 41053217, doi:10.1038/s41594-025-01686-3 (PMC12700789).

**Screen.** Female mouse ES cells with a CRISPRi library against transcription-factor promoters (11,058 guides, 911 promoters, 300 non-targeting). At day 2 of differentiation the cells were sorted by Xist RNA level (RNA FlowFISH) into negative, low and high bins, in two replicates. The authors deposited MAGeCK MLE results for High vs Negative.

**Design.** `~ replicate + bin`, Xist-high vs Xist-negative, 4 libraries, 1 residual df. Each replicate is one transduction sorted into all bins, so replicate is a blocking term. Gene labels are promoter-level (`_p1`, `_p2`).

## Results

| | BARCS | Authors' MAGeCK MLE |
|---|---|---|
| Promoters at FDR 0.10 | 101 (53 depleted, 48 enriched) | 13 |
| Xist_p1 (positive control) | #1, depleted | top |
| Tsix_p2 (Xist antisense repressor) | #2, enriched | #29 |
| Zic3_p1 | #4, depleted, FDR 3 × 10⁻²³ | top 10 |
| Rlim_p1 | #5, depleted | top 10 |
| Rank correlation | 0.95 | |
| Top-10 / top-25 overlap | 8 / 20 shared | |

## Where BARCS agrees and differs

- **Agrees.** The known regulators come out as expected, with the right signs:
  - knocking down Xist's own promoter lowers Xist;
  - knocking down the antisense repressor Tsix raises it;
  - knocking down Zic3 and the X-linked activator Rlim lowers it.
- **Longer list.** BARCS calls about eight times as many promoters at FDR 0.10. With one residual degree of freedom, each guide's variance comes almost entirely from the library-wide prior (moderation), and about 12 guides per promoter add power in the Stouffer summary. The top of the list matches MLE; the tail is where the two methods differ and where independent validation matters.

## Limits

- Two replicates (1 residual df).
- The Low bin and the follow-up TFiMini library were not reanalyzed.
