# GSE183348 reanalysis with BARCS 0.2.3

**Paper.** Kellman LN et al. "Functional analysis of cancer-associated germline risk variants", *Nat Genet* 2025, PMID 39962238 (doi:10.1038/s41588-024-02070-5). The CRISPR knockout screen is a minor part of an MPRA study. The MPRA itself is the companion series GSE183301, which is not a screen.

**Screen.** A focused Cas9 knockout library: 178 genes with 6 guides each, plus 100 safe-targeting guides, 1,140 guides in all. The genes are colon-cancer MPRA putative target genes (ptGenes), some of which are common-essential, plus 4 added common-essential controls. It was screened in DLD1, HCT116 and SW948 colorectal cancer cells. Each line has 2 day-0 libraries, 2 libraries after 2D culture and 10 subcutaneous xenograft tumours. The abstract states the conclusion: "a subset of germline putative risk genes also enables the growth of established cancers".

**Counts.** There is one raw-count file per cell line. Each has a first column "gene" holding guide IDs `sgNNN-<gene>` and columns `sample_N`, which map to GSMs through the GSM titles. The row order differs between files, so `prepare.R` merges them by guide ID and adds a Gene column. It also splits the paper's MAGeCK gene summaries (Supplementary Table 6: DLD1 2D/Tumor, HCT116 2D/Tumor, SW948 Tumor) into one table per contrast, converting text-stored numbers.

**Design.** `~ condition` per cell line, each condition against day 0:
- main: DLD1 tumour vs day 0 (10 vs 2);
- also HCT116 and SW948 tumour vs day 0, and 2D vs day 0 for each line (2 vs 2).

The reference is not stated in the accessible text, so it was checked against the published log fold changes. For DLD1 and HCT116, the published MAGeCK LFCs correlate 0.98 with median-normalized tumour-vs-day-0 LFCs and about 0 with tumour-vs-2D.

SW948 tumour rep 2 (sample_42) is left out. 27% of its guides have zero reads, consistent with a bottlenecked tumour, and its Spearman correlation with day 0 is 0.26. The published SW948 LFCs match a calculation without it (r = 0.96) but not one with it (r = 0.74), so the paper evidently excluded it as well.

Tumours are independent xenografts, so there is no pairing term. The controls are the 100 safe-targeting guides, which make cuts.

**Checks.**
- Composition is normal: the top 1% of guides hold 2-7% of reads.
- Tumour contrasts have 9-10 residual df and guide correlation 0-0.03. No control guide reaches p < 0.05, so the model is conservative there; tumour-to-tumour variation is larger for targeting guides than for safe guides.
- In the 2D contrasts (2 residual df), HCT116 needed control calibration (15% of controls at p < 0.05 before, 5% after).
- The control null gives:

| Contrast | Genes at FDR 0.10 (control null) | Null centred on |
|---|---|---|
| DLD1 tumour | 43 | controls |
| HCT116 tumour | 71 | targeting guides (controls offset -0.37 z) |
| SW948 tumour | 46 | controls |

- The enriched calls (CDH1 in DLD1 and SW948 tumours, UBE2Z in SW948, CDH3 in HCT116) are consistent across guides and tumours. They have no jackpots.

## Results (genes at FDR 0.10, depleted / enriched)
| Contrast | BARCS | MAGeCK neg FDR < 0.1 | Spearman | Top-25 overlap |
|---|---|---|---|---|
| DLD1 tumour vs day 0 | 26 (25 / 1) | 46 | 0.87 | 23 |
| HCT116 tumour vs day 0 | 29 (28 / 1) | 80 | 0.83 | 22 |
| SW948 tumour vs day 0 (without sample_42) | 28 (26 / 2) | 67 | 0.81 | 22 |
| DLD1 2D vs day 0 | 44 (32 / 12) | 38 | 0.91 | 22 |
| HCT116 2D vs day 0 | 37 (34 / 3) | 145 | 0.91 | 23 |
| SW948 2D vs day 0 | 16 (13 / 3) | no published table | | |

Every BARCS depleted call in the tumour contrasts is also a MAGeCK call; BARCS's lists are subsets of the paper's. The paper names no individual CRISPR hit in the accessible text. The "named hits" are therefore the five strongest non-control ptGene calls in the published DLD1 tumour table: PCBP1, ATP5SL, CDC42, CIRH1A and CNOT9. All five pass FDR 0.10 in BARCS's DLD1 tumour contrast (ranks 7-24). In HCT116 tumours only PCBP1 and CIRH1A pass; in SW948 tumours PCBP1, CIRH1A and CNOT9 pass. The strongest depleted genes in all lines are the same in both analyses: GAPDH, PGK1, NCAPD2, TANGO6, PCBP1, MRPL51 and TFRC.

## BARCS vs paper
BARCS ranks genes almost as MAGeCK does (Spearman 0.81-0.91) but calls fewer of them, especially where MAGeCK's lists are long. HCT116 2D is the extreme case: MAGeCK calls 145 of 177 genes depleted at FDR 0.1, BARCS 34. MAGeCK with median normalization and a mean-variance model fitted across the library can call most genes of a small focused library that is mainly essential and ptGenes. BARCS fits each guide's dispersion from its replicates, moderated across guides, and tests against non-targeting expectations. With only 2 day-0 and 2 2D libraries (2 residual df), and 10 heterogeneous tumours, it needs larger effects. BARCS also reports enrichment of the tumour-suppressor-like CDH1 (DLD1, SW948) and CDH3 (HCT116) in tumours, which MAGeCK's positive tests did not flag at FDR 0.1.

## Limits
- 1,140-guide focused library, so library-total normalization rests on mostly targeting guides.
- Day 0 has two libraries per line.
- Xenograft tumours are bottlenecked; one SW948 tumour is excluded.
- The comparison reference (day 0) was inferred from the published LFCs; it is not stated.
