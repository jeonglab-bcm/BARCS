# GSE171674 reanalysis with BARCS 0.2.3

**Paper.** Freimer et al., "Systematic discovery and perturbation of regulatory genes in human T cells reveals the architecture of immune networks", *Nature Genetics* (2022), PMID 35817986, doi:10.1038/s41588-022-01106-y (PMC10035359). GEO also lists PMIDs 39395408 and 41237776 (a 2025 *Immunity* paper on FOXP3 regulation). Those later papers reuse the series. The screen itself and its hit list are from Freimer et al. 2022, so that paper is the reference here.

**Screen.** A knockout library of about 1,350 transcription factors and immune regulators (5,998 guides, 4 per gene, 593 non-targeting) in primary human CD4+ T cells. The edited cells were FACS-sorted into CD25 (IL2RA) high and low bins. Three donors were sorted on CD25, and two of them also on IL-2 and CTLA4. The counts are the GEO file as deposited (integer reads, columns named by donor and bin). The authors ran MAGeCK on low versus high bins. Their gene-level results are in Supplementary Table 2. `prepare.R` extracts the IL2RA screen from that table and flips the sign of the log fold change so that it reads high versus low.

**Design.** `~ donor + sort`, CD25 high vs CD25 low, 6 libraries, 2 residual df (prior df 14.8 after moderation). Both bins come from the same donor's edited pool, so donor is paired. The IL-2 and CTLA4 sorts have only two donors each and are not analyzed.

**Calibration.** 5.4% of non-targeting guides reach p < 0.05, so no calibration was needed. Composition is flat: the top 1% of guides hold 2.4–2.8% of reads. The guide correlation is 0.025. Non-targeting guides sit +0.29 z from the targeting guides, so the control null was centred on the targeting guides. It calls 133 genes, close to the model's 126.

## Results

| | BARCS 0.2.3 | Authors' MAGeCK (Supp. Table 2, IL2RA screen) |
|---|---|---|
| Genes at FDR 0.10 | 126 (65 higher in CD25-high, 61 lower); 133 against the centred control null | 58 (25 / 33); the text reports 51 significant hits |
| IL2RA (positive control, KO lowers CD25) | #6, FDR 2e-23 | rank-1 tier (p at the permutation floor) |
| STAT5B / STAT5A / JAK3 (known positive regulators) | #5 / #19 / #26, all FDR < 1e-7 | all hits |
| MED12, CBFB, HIVEP2, KLF2 (negative regulators) | #1, #2, #3, #7 | all at the permutation floor |
| FOXK1, ZNF217, TNFAIP3 | #9, #11, #12 | hits |
| IRF4, ATXN7L3 | #64, #68 (FDR 0.003, 0.004) | hits |
| Rank correlation (two-sided score) | 0.61 | |
| Top-25 / top-50 overlap | 23 / 43 | |
| Effect direction agreement | 82% of all genes | |

## Where BARCS agrees and differs

- **Agrees.** All 58 genes the authors' MAGeCK calls at FDR 0.10 are BARCS calls at FDR 0.10, and every named hit is called. IL2RA, the built-in positive control, separates cleanly (#6 of 1,350; all four guides lower in every donor's CD25-high bin). The top-25 lists share 23 genes.
- **BARCS calls more.** BARCS calls another 68 genes. They have smaller effects (|estimate| 0.13–0.45) but consistent guides: for the strongest, RUNX3, BCL11B, LEF1, GABPA, SATB1 and STAT1, all four guides move in the same direction. Several are well-known T-cell regulators. MAGeCK's RRA with permutation p-values sits at its floor (p = 3.7e-6) for its top 30 genes and has little power for moderate, consistent effects. BARCS's paired donor term and moderated dispersion do. The centred control null agrees (133 genes), but these extra calls are less certain than the shared 58.

## Limits

- Three donors, 2 residual df. Moderation stabilises the dispersion, but donor-to-donor variation is estimated from three pairs.
- Only the IL2RA (CD25) screen is reanalyzed. The IL-2 and CTLA4 screens, and the network and RNA-seq and ATAC-seq analyses built on them, are not.
