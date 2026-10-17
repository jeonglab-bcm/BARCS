# GSE225878 reanalysis with BARCS 0.2.3

**Paper.** Baronas et al., "Genome-wide CRISPR screening of chondrocyte maturation newly implicates genes in skeletal growth and height-associated GWAS loci", *Cell Genomics* (2023), PMID 37228756, doi:10.1016/j.xgen.2023.100299 (PMC10203046).

**Screen.** The cells are a mouse growth-plate-like chondrocyte line (GPLC) with Cas9, transduced with the Brie genome-wide knockout library (78,633 targeting guides, 4 per gene, plus 1,000 non-targeting). At day 4 and day 15 they were sorted into the top 10% (CD200-high, mature) and bottom 10% (CD200-low, immature), in three biological replicates each. GEO has no series count matrix. Each primary-screen GSM carries one Excel count file per replicate and day. In it, each sort is spread over many PCR/sequencing barcodes (4 to 38 columns). `prepare.R` downloads the six primary files and sums the columns per sort; the sums equal the authors' own "High Counts"/"Low Counts" columns. It then maps guide sequences to genes with the Broad GPP Brie annotation from Addgene. Every guide matches either a targeting guide or one of the 1,000 controls. Guides map to one gene each, so gene families that the authors' GPP output scores together (histone H2ac cluster, Gm paralogs) are not tested as such. The authors' gene results are the series-level GPP hypergeometric files (average LFC and average -log10 p over three replicates). `prepare.R` writes them to `paper/primary_d{4,15}.tsv`. The secondary screen (sub-library; replicates 1 and 2 pooled in one GSM) is not analysed.

**Design.** `~ rep + bin`, CD200-high vs CD200-low, paired by replicate, 6 libraries, 2 residual df, for each day. A positive estimate means the knockout drives maturation (Sufu, Ptch1). Cd200 itself is the positive control and has a negative estimate.

**Day 4 checks.** Before calibration, 14.9% of non-targeting guides reached p < 0.05, so the analysis was calibrated to the controls (scale 1.46). Composition is flat (top 1% of guides hold 2.5-2.9% of reads). Controls sit -0.34 z from the targeting guides, so the control null was centred on the targeting guides. It gives 681 genes against the model's 359. Guide correlation is 0.002.

**Day 15 checks.** The day-15 CD200-low libraries are bottlenecked. Replicate correlation is about 0.3-0.5. Their top 1% of guides hold 11-16% of reads, and 4% of guides are zero. Before calibration, 29% of controls reached p < 0.05. Even after calibration the model calls 1,488 genes (1,450 toward CD200-high), but the control null, centred on the controls, supports only 29. Control-normalised totals (1,541 vs 34 by the null) and median-ratio totals (231 vs 9) do not reconcile the two. The day-15 model list is therefore not credible; only its top ranks are interpretable.

## Results, day 4

| | BARCS 0.2.3 | Authors' GPP hypergeometric |
|---|---|---|
| Genes called | 359 at FDR 0.10 (85 mature, 274 immature); 681 by centred control null | 110 (p < 0.001 and LFC threshold) |
| Cd200 (positive control) | #4, estimate -1.72, FDR 1e-17 | #1 |
| Sufu, Eed, Ptch1, Ezh2, Strap, Dot1l, Arrb2 (Table 1 top) | #1, #2, #3, #5, #6, #7, #8 | #2-#9 |
| OMIM skeletal genes Gnas, Prkar1a, Runx2, Sox9, Ptpn11 | #23, #27, #31, #62, #140 (all FDR < 0.05) | day-4 hits (Table 2) |
| Genes meeting the authors' threshold that BARCS calls (same sign) | 130 / 142 testable (68 more are multi-gene families not tested) | |
| Rank correlation (two-sided) | 0.88 | |
| Top-25 / top-100 overlap | 15 / 46 | |

## Day 15

BARCS's top day-15 calls are the paper's: Sufu #1, Ptch1 #2, Fkbp1a #3, Mib1 #4, Smad6 #6, Wdpcp #8, Fuz #11, Csnk2b #13. All 22 testable genes that meet the authors' day-15 threshold are BARCS calls, and 16 of them pass the control null. The rank correlation over all genes is only 0.26. This reflects the bottleneck noise and the model's inflated tail, not disagreement on the hits.

## Where BARCS agrees and differs

- **Agrees.** At day 4 the two methods rank the same genes at the top. The Cd200 positive control, the hedgehog repressors Sufu and Ptch1, and PRC2 (Eed, Ezh2, Suz12) lead both lists. Every highlighted day-4 gene is a BARCS call.
- **Differs.** BARCS calls more genes at day 4 (359 against 110). It also ranks some moderate-effect genes higher than the authors do: Smad6, Trp53, Cic and Gnas toward maturation, and Rab7, Pdcd10, Med26 and Kdm1a toward immaturity. The likely reason is that BARCS models all three replicates jointly, while the authors average per-replicate hypergeometric p-values. The authors' top lists include multi-copy families (Gm4724, the H2ac cluster, Vmn1r, Mup). There, guides that hit several paralogs are scored together. BARCS assigns each guide to its annotated gene, so these are not comparable.

## Limits

Counts are rebuilt from per-sample Excel files and a public library annotation. Calibration to the controls was needed at both days. Day 15 is bottlenecked: report only its top-ranked genes and the control-null count (29), not the model count.

**Not part of this record.** The day-15 libraries are bottlenecked (the top 1% of guides hold 11-16% of reads and 29% of controls reach p < 0.05), so the day-15 analyses described above are not archived or shown on the website; only day 4 is reported.
