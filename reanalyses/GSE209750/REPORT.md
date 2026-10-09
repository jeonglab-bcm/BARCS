# GSE209750 reanalysis with BARCS 0.2.2

**Paper.** "Integrated multi-omics analyses identify anti-viral host factors and pathways controlling SARS-CoV-2 infection", *Nature Communications* (2024), PMID 38168026, doi:10.1038/s41467-023-44175-1 (PMC10761986).

**Screen.** Genome-wide CRISPR-Cas9 knockout survival screen in A549-ACE2 cells (92,817 guides, 133 AAVS1 safe-harbor control guides). SARS-CoV-2 (WA1) infection kills cells; guides depleted in infected versus mock libraries mark **anti-viral** host factors (their loss protects), and enriched guides mark **pro-viral** factors (ACE2, CTSL). The authors deposited a MAGeCK sgRNA/gene summary for the same infected-vs-mock comparison.

**Design.** `~ condition`, infected (C-1..3) vs mock (control1..3), 6 libraries, 4 residual df, `test = "auto"`. Replicate correlations are uniformly 0.97-0.99 and show no pairing, so no replicate/batch term. The 365 single-guide "Zhang_N" entries of uncertain identity were not used as controls (AAVS1 only). Column-to-sample mapping is from headers equal to the GSM titles; it is not inferred.

**Calibration.** 18.8% of the 133 AAVS1 guides reached p < 0.05, so the test was calibrated to them (4.5% after, control_scale 1.46).

## Results

| | Value |
|---|---|
| Genes at FDR 0.10 | 257 (93 depleted / anti-viral, 164 enriched / pro-viral); control-null 312 |
| Rank correlation with deposited MAGeCK (neg) | 0.68 |
| Top-50 overlap with MAGeCK (neg) | 38 / 50 |

| Named hit (anti-viral, depleted) | BARCS depleted rank | Effect | p | FDR | guides |
|---|---|---|---|---|---|
| DAZAP2 | 1 | -0.86 | 2.8e-21 | 2.6e-17 | 5 |
| KLF5 | 6 | -0.34 | 1.2e-12 | 1.2e-09 | 5 |
| VTA1 | 42 | -0.04 | 9.8e-05 | 0.013 | 5 |

Direction check (controls): ACE2 (#1 enriched, FDR 3.8e-32) and CTSL (FDR 2.5e-12) are the two most enriched genes, confirming the label orientation. ESCRT (VPS4A #5, VPS28, CHMP6 #46) and cohesin (SMC3 #92, FDR 0.097) are depleted, as the paper reports; V-ATPase subunits are enriched (pro-viral).

## Where BARCS agrees and differs

- **Agrees on the validated genes.** DAZAP2 is the single most depleted gene (FDR 2.6e-17) and KLF5 is #6 (FDR 1.2e-09) — both validated anti-viral factors.
- **VTA1 is weakly recovered.** It passes FDR 0.10 (0.013) but with a very small effect (-0.04); at the guide level it is only marginally depleted, so BARCS supports its direction but not as a strong hit.
- **Pathway-level agreement.** ESCRT and cohesin components are depleted and the pro-viral entry factors enriched, matching the paper's mechanistic claims; rank correlation with the deposited MAGeCK neg table is 0.68 (38/50 top genes shared).

## Limits

- A single library; three infected and three mock replicates with no pairing.
- Some gene symbols are Excel-mangled dates (1-Mar, 1-Sep) in the deposited table and were left as-is.
- The "Zhang_N" single guides were not usable as an independent control set.
