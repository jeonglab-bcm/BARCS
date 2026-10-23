# GSE177541 reanalysis with BARCS 0.2.3

**Paper.** Grodzki et al., "Genome-scale CRISPR screens identify host factors that promote human coronavirus infection", Genome Medicine (2022), PMID 35086559, doi:10.1186/s13073-022-01013-1 (PMC8792531). The same paper deposits two HEK293T-hACE2 screens as GSE177537 and GSE177543.

**Screen.** Custom Vervet (Chlorocebus sabaeus) knockout library (74,343 guides, ~4 per gene, no non-targeting guides) in Vero E6 cells infected with SARS-CoV-2 or OC43; surviving cells were sequenced. GEO holds four Day-0 libraries, four SARS-CoV-2 infected, and OC43 single/double-infected libraries, integer reads named by sample. The authors ran MAGeCK (a-RRA) on infected vs Day-0 and read the enriched side; prepare.R turns their Additional-file-4 (SARS-CoV-2) and Additional-file-5 (OC43) MAGeCK tables into the published comparison.

**Design.** ~ condition, infected vs Day 0, 4 vs 3. Separate cultures, no pairing term (5 residual df). Selection is extreme: in OC43 single-infected libraries the top 1% of guides hold 96-98% of reads, so totals are median-ratio size factors and only enrichment is read; for OC43 the median-ratio totals are capped (single guides hold most of each library), so depletion is uninterpretable.

**Checks.** No controls, so calibration and the control null could not be checked. Day-0 libraries correlate at Spearman 0.81.

## Results

| | BARCS 0.2.3 | Authors (MAGeCK positive selection) |
|---|---|---|
| SARS-CoV-2 genes at FDR 0.10 | 1,614 (1,157 enriched, 457 depleted), median-ratio | ranked list, FDR 0.25 cutoff |
| SARS-CoV-2 named hits | CDKN1A #1, TP53 #2, ACE2 #7, RAD54L2 #21, DPF2 #64, HRK #70, DYRK1A #385 | TP53, CDKN1A, ACE2, RAD54L2, HRK, DPF2, DYRK1A, CDK4 |
| SARS-CoV-2 rank corr / top-20 overlap | 0.77 / 10 of 20 | |
| OC43 single genes at FDR 0.10 | 22 enriched (depletion uninterpretable, capped) | ranked list |
| OC43 named hits | IFITM1/3 multiKO #1, TMEM41B #3, SLC35B2 #12, EXT1 #19 | TMEM41B, SLC35B2, EXT1, IFITM |

## Where BARCS agrees and differs

- **Agrees on the strong genes.** For SARS-CoV-2 BARCS puts the p53/cell-cycle axis at the top (CDKN1A #1, TP53 #2, ACE2 the receptor #7), rank correlation 0.77 and 84.6% direction agreement. For OC43 the IFITM1/3 multi-knockout is #1 and TMEM41B #3.
- **Differs below the top.** BARCS's paired-dispersion model ranks smaller, guide-consistent genes (TMEM41B #10, PSENEN) above MAGeCK's a-RRA, while a few of the authors' top genes resting on one or two guides (COL17A1, AIG1, A4GALT) fall far. DYRK1A is the weakest named hit in BARCS (#385, FDR 0.02).
- **Depletion not interpretable for OC43.** The OC43 single-infected libraries collapse to a few clones (97% of reads on 1% of guides), so median-ratio totals are capped and the depleted calls are a composition-crash artifact; only the 22 enriched genes are meaningful.

## Limits

- No non-targeting controls; calibration and the control null could not be run. Extreme post-selection bottleneck, so only enrichment is interpretable (depletion uninterpretable for OC43). Infected and Day-0 libraries are unpaired.
