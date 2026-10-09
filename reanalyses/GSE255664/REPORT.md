# GSE255664 reanalysis with BARCS 0.2.2

**Paper.** "EXO1 as a therapeutic target for Fanconi Anaemia, ZRSR2 and BRCA1-A complex deficient cancers", *Nature Communications* (2025), PMID 41006228, doi:10.1038/s41467-025-63349-7 (PMC12475092). The dropout screen is SubSeries GSE255664 of SuperSeries GSE255665. The rescue screens in the other SubSeries, GSE255579, are not reanalyzed here.

**Screen.** A Brunello knockout library (77,441 guides, 1,000 non-targeting) in eHAP iCas9 wild-type and EXO1-knockout cells. Each genotype had three separately passaged infections, sampled at day 6 and day 16 of Cas9 induction. GEO holds two count files per sample, one per read strand; the two were summed (the "−" strand adds 14–198 reads to libraries of 28–43 M). The authors ran MAGeCK `test` and deposited the gene summaries as Supplementary Data 1 (day 6) and 2 (day 16). Those tables are labeled "WT vs EXO1 KO", so their **positive** side is depletion in EXO1 KO. Reading it that way puts EXO1 itself on the negative side, because the KO line has no EXO1 cutting phenotype. Supplementary Data 2 is used as the published table here.

**Design.** `~ genotype`, EXO1 KO vs WT at day 16, 6 libraries, 4 residual df. The genotypes are separate infections, so there is no replicate pairing.

**Calibration.** 6.7% of non-targeting guides reached p < 0.05, below the 7.5% threshold, so no calibration was applied. Composition is unremarkable: the top 1% of guides hold about 4% of reads in each library.

## Results

| | BARCS 0.2.2 | Authors' MAGeCK (Supplementary Data 2) |
|---|---|---|
| Genes at FDR 0.10 | 10 (6 depleted in KO); 13 against the control null centred on targeting guides (see below) | 2 KO-depleted genes (ACAD10, RMI2); 5 at FDR 0.25 |
| RMI2 | **#1, FDR 2 × 10⁻⁴** | #2, FDR 0.04 |
| STRA13 (CENPX, FANCM complex) | **#2, FDR 5 × 10⁻⁴** | #4, FDR 0.13 |
| FAM175A (ABRAXAS1, BRCA1-A) | **#3, FDR 5 × 10⁻⁴** | #5, FDR 0.13 |
| ACAD10 | **#4, FDR 0.03** | #1, FDR 0.04 |
| APITD1 (CENPS, FANCM complex) | #11, FDR 0.13 | #21 |
| ZRSR2 | #16, FDR 0.16 | #3, FDR 0.10 |
| BRCC3 (BRCA1-A) | #25, FDR 0.24 | #24 |
| C19orf40 (FAAP24) | #53, FDR 0.33 | #68 |
| CDK11B | #346, FDR 0.49 | #50 |
| FANCG | #2,349, FDR 0.76 | #42 |
| BABAM1, FANCM, FANCD2, FANCL | #3,700–9,600 | #1,098–9,378 |
| Rank correlation (KO depletion) | 0.67 | |
| Top-25 / top-100 overlap | 10 / 33 | |

## Where BARCS agrees and differs

- **Agrees.** BARCS reproduces the authors' own ranking at the top: their five strongest KO-depleted genes (ACAD10, RMI2, ZRSR2, STRA13, FAM175A) are all in the BARCS top 16. The two genes their MAGeCK calls at FDR 0.10 are BARCS #1 and #4. FAM175A and STRA13 are among BARCS's six depleted calls at FDR 0.10.
- **Same weakness as the paper's table.** ZRSR2, BRCC3, APITD1 and FAAP24 rank high in both analyses but miss FDR 0.10 in BARCS (0.13–0.33), as they do in MAGeCK. For ZRSR2, two of four guides fall 2- to 3-fold in every KO replicate and two do not move.
- **FANCG and the wider FA pathway.** The paper names the whole FA core complex. Neither analysis supports most of those genes on its own: FANCG is #42 in MAGeCK (FDR 0.68) and #2,349 in BARCS. Its guides have only 25–450 reads. Two guides fall in KO (FANCG_1: 86–166 → 26–60 reads; FANCG_3: 35–83 → 6–35) and two do not, so with three replicates the gene is not significant. FANCD2, FANCM and BABAM1 are not depleted in either analysis. The paper's FA-pathway claims rest on the validation experiments (clonogenic and viability assays, rescue screens), not on this screen alone.
- **Control null.** Non-targeting guides do not cut, and in EXO1 KO they sit above the targeting guides (−0.35 z offset). Centred on the controls, the pseudo-gene null called 170 genes, 166 of them depleted, an artifact of that offset. Centred on the targeting guides it calls 13, close to the model's 10: RMI2, STRA13, FAM175A and ACAD10 at FDR 0.088, APITD1 0.10, ZRSR2 0.14.

## Limits

- Three replicates per genotype, from separate infections; a genotype effect cannot be separated from infection-to-infection differences.
- The paper's synthetic-lethal list also draws on the day-6 comparison and on validation experiments. Only the day-16 contrast is reanalyzed.
- Brunello uses old gene symbols (FAM175A, STRA13, APITD1, C19orf40).
