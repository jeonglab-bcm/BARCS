# GSE199603 reanalysis with BARCS 0.2.3

**Paper.** Wang et al., "CD300ld on neutrophils is required for tumour-driven immune suppression", *Nature* (2023), PMID 37674079, doi:10.1038/s41586-023-06511-9.

**Screen.** An in vivo knockout library of 355 transmembrane-protein genes with a high myeloid/lymphoid expression ratio (3,547 guides, about 10 per gene, no non-targeting controls) was transduced into Cas9 fetal-liver haematopoietic progenitors and transplanted into irradiated mice; after B16-F10 tumours grew, CD45+ cells from tumour and bone marrow were sequenced. GEO holds one pooled library per tissue (integer reads, xlsx as deposited). The authors ran MAGeCK (bone marrow vs tumour); `prepare.R` turns their Supplementary Table 1 into a table with the "pos" side (depleted in tumour) and the lfc sign flipped to tumour vs bone marrow.

**Design.** `~ tissue`, tumour vs bone marrow, 1 vs 1 library. No residual df, so run_barcs.R uses the no-replicate path. With no control guides, the overdispersion is pooled over all guides (rho 3.3e-5), which is conservative: real effects inflate it. The calls are screening-level, because variation between mice was not measured (the libraries pool the mice).

**Checks.** Calibration and the control null could not be checked (no controls). Composition is flat. Tumour and bone marrow correlate at Spearman 0.68.

## Results

| | BARCS 0.2.3 | Authors' MAGeCK (Supp. Table 1) |
|---|---|---|
| Genes at FDR 0.10 | 1 (Cd300ld) | 0 at FDR 0.10 on either side; Cd300ld is top-ranked (pos FDR 0.069) |
| Cd300ld | #1 depleted in tumour, estimate −0.57, FDR 0.006, 9 of 10 guides down | #1 |
| Rank correlation (depletion score) | 0.69 | |
| Top-10 / top-25 overlap | 3 / 10 | |

## Where BARCS agrees and differs

- **Agrees.** Both methods put Cd300ld first by a wide margin, and it is the gene the paper follows up. BARCS calls it at FDR 0.006 from 9 of 10 concordant guides. MAGeCK places it just above 0.05.
- **Differs below the top.** Neither method calls anything else. The next ranks differ: MAGeCK's #2, Ext1, has a positive mean lfc (enriched in tumour), so its RRA rank rests on a few guides, and BARCS puts it at #246. BARCS's next genes (Kit, Itgam, Slc43a2) are far from significance.

## Limits

- There is one library per tissue, no replicate mice and no control guides. The FDR comes from an overdispersion pooled over all guides, so the single call is screening-level.
