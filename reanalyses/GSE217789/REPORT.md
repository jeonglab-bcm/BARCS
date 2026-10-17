# GSE217789 reanalysis with BARCS 0.2.3

**Paper.** Lin et al., "HNRNPH1 regulates the neuroprotective cold-shock protein RBM3 expression through poison exon exclusion", *The EMBO Journal* (2023), PMID 37248947, doi:10.15252/embj.2022113168 (PMC10350819).

**Screen.** The cells are human iPSC-derived NGN2 neurons carrying a GFP-RBM3 knock-in reporter, from two Cas9 clones (N8, N9), transduced with a custom genome-wide library (91,536 guides, about 5 per gene, 399 non-targeting). They were cooled to 32 C for 72 h and FACS-sorted into the top and bottom GFP quartiles on three days per clone (6 high/low pairs). The GEO count table is raw integers, and its columns equal the bracketed labels in the GSM titles. `prepare.R` only adds a gene-symbol column (the table names genes `<Ensembl>_<symbol>`). RABGEF1 and STPG4 each map to two Ensembl IDs, so they keep the full name; counts are unchanged. GEO lists "treatment: Tunicamycin" for every sample, and the file is named `rbm3-tun-library`. Both contradict the series design and the paper (cooling, no drug), and probably come from the same group's tunicamycin screen pipeline. The data behave like the RBM3 reporter sort: RBM3's own guides are a top low-GFP enrichment.

**Design.** `~ pair + gfp`, low-GFP vs high-GFP, 12 libraries, 5 residual df, strongly moderated (prior df 69). This follows the authors' paired MAGeCK. Positive estimates mean the gene's knockout lowers RBM3, i.e. a positive regulator.

**Calibration and checks.** Before calibration, 8.0% of non-targeting guides reached p < 0.05, so `run_barcs.R` calibrated to the controls (scale 1.11). This shortens the list. Composition is flat (top 1% of guides hold 3.2-3.8% of reads). Guide correlation is about 0. Controls sit -0.27 z from the targeting guides, so the control null was centred on the targeting guides. It calls 93 genes, against 57 from the model. Replicate libraries correlate poorly (Spearman about 0.5): neurons are sorted from limited cell numbers, so guide counts are noisy. The top calls are supported by all or most of their guides across the six pairs.

## Results

| | BARCS 0.2.3 | Authors' paired MAGeCK-RRA (Appendix Table S2) |
|---|---|---|
| Genes at FDR cut-off | 57 at FDR 0.10 (26 positive, 31 negative); 93 by centred control null | 110 at FDR 0.05 (15 positive, 95 negative) |
| HNRNPH1 (strongest positive regulator, mechanism of the paper) | #1, FDR 2e-12 | positive #1 |
| RBM3 (reporter's own gene) | #6 | positive #2 |
| TNPO3, PNISR, SNRNP70 (validated positive, splicing) | #7, #5, #13 | positive #3, #4, #6 |
| HTATSF1, YPEL5, WDR26, WTAP (validated negative) | #3, #2, #10, #9 | negative #1, #2, #4, #5 |
| UBE2H (validated negative) | #159, FDR 0.54 | called |
| Paper positives (FDR 0.05) called by BARCS (FDR 0.10, same sign) | 14 / 15 (not ADAM8) | |
| Paper negatives (FDR 0.05) called by BARCS | 28 / 95 | |

Appendix Table S2 is only in a PDF, so it is not used as a machine-readable comparison table. The counts above come from reading that table. `compare.json` uses the named hits only.

## Where BARCS agrees and differs

- **Agrees.** BARCS and MAGeCK have the same top tier: HNRNPH1 first, then RBM3, the splicing factors TNPO3, PNISR, SNRNP70 and PUF60, plus HUWE1, KLF7 and EIF3G/B on the positive side. HTATSF1, YPEL5, KPNB1, WDR26, WTAP, SOX11, SMU1, ECD and ILF3 are on the negative side. Nine of the ten genes the authors validated by arrayed knockout are BARCS calls at FDR 0.10.
- **Differs.** BARCS confirms only 28 of the paper's 95 negative regulators. The others (for example SRSF2, PAN2, ARGLU1, TAF5L and the validated UBE2H) have weaker or inconsistent guides across the six noisy pairs. RRA can rank a gene highly from one or two strongly enriched guides in pooled counts. BARCS weighs each guide's replicate variation and was calibrated to the controls here. Against the control null, BARCS calls 93 genes, which narrows the gap.

## Limits

The sorted neuron populations are small, so replicate libraries correlate poorly. Calibration to the non-targeting guides was needed. The paper's full gene table is a PDF and is compared only through its listed calls.
