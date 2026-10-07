# GSE333513 reanalysis with BARCS 0.2.1

**Paper.** Acero-Riaguas et al., "Genome-wide CRISPR screen identifies AMBRA1 as a potential biomarker of response to platinum-based therapies in oral squamous cell carcinomas", *iScience* (2026), PMID 42548798, doi:10.1016/j.isci.2026.116959 (PMC13429904).

**Screen.** OSC20 clone 3 with a genome-wide library (19,050 genes, 3 guides per gene; 55,478 guides including 979 non-targeting controls). Samples: T0, untreated day 7, and cisplatin 50 µM (IC80) day 7, three replicates each. The paper describes these as "technical triplicates". The paper used MAGeCK-RRA via MAGeCKFlute and called 903 resistance and 909 sensitivity candidates at nominal p < 0.05, then selected 10 genes by |L2FC| > 3, rank and function.

**Test.** `test = "auto"`: 14% of guides (heavy dropout under IC80 selection) used the likelihood-ratio test.

**Design (inferred).** Count columns S1–S9 follow GSM order (GSM9766663–71). Log-count correlations cluster as S1–3, S4–6 and S7–9, which supports this mapping, but it is not stated in GEO. Primary contrast: cisplatin vs untreated, `~ condition`, 6 libraries, 4 residual df, no replicate term. Sanity contrast: day 7 vs T0.

## Results

| Contrast | Genes at FDR 0.10 | Fraction of genes with p < 0.05 | Guide correlation | Prior df |
|---|---|---|---|---|
| Cisplatin vs untreated | 0 | 0.034 | 0.001 | Inf |
| Day 7 vs T0 | 0 | 0.019 | 0.000 | Inf |

The paper's 10 named genes (its "resistance" set has knockouts expected to sensitize; its "sensitivity" set has knockouts expected to resist):

| Gene | Paper set | BARCS effect (log odds) | p | Rank (of 18,783) |
|---|---|---|---|---|
| AMBRA1 | resistance (KO sensitizes) | −1.43 | 0.0018 | 27 |
| KEAP1 | resistance | −1.57 | 0.025 | 303 |
| MRFAP1 | resistance | −6.24 | 0.00095 | 12 |
| TGFBR2 | resistance | −3.08 | 0.047 | 585 |
| PDGFD | resistance | −1.22 | 0.026 | 326 |
| GSK3B | sensitivity | +0.88 | 0.29 | 5,240 |
| MORF4L1 | sensitivity | +1.77 | 0.024 | 294 |
| FAT2 | sensitivity | +0.99 | 0.096 | 1,426 |
| MED17 | sensitivity | +0.91 | 0.16 | 2,591 |
| CDK8 | sensitivity | +1.05 | 0.053 | 700 |

## Where BARCS agrees and differs

- **Direction agrees for all 10 genes.** The BARCS effect signs match the paper's labels.
- **No gene is significant.** BARCS finds no gene at FDR 0.10 in either contrast.
  - The best gene p-value (4.4 × 10⁻⁵) is in the range expected for the minimum of about 18,800 null p-values.
  - The paper's 1,812 candidates at nominal p < 0.05 are 9.5% of genes. That is close to the share expected by chance from two one-sided tests at 0.05, and the paper applied no FDR control.
- **Large fold changes are not reproducible across replicates.**
  - 23% of guides have |log2 fold change| > 3 in cisplatin vs untreated; only 1.1% of those reach guide-level p < 0.05.
  - This pattern is consistent with a strong bottleneck under IC80 selection, where random guide dropout produces large fold changes that replicates do not share.
  - Selecting genes by |L2FC| > 3, as the paper did, picks up this noise. BARCS's overdispersion estimate absorbs it.
- **The positive control is weak.** In day 7 vs T0, ribosomal and proteasome guides are depleted by only about 0.15 log2 relative to other guides, and no gene passes FDR 0.10. Selection over 7 days was weak, so the screen had low power from the start.
- **Named sensitizers rank high but do not pass FDR.** With the likelihood-ratio test for heavy-dropout guides, AMBRA1 ranks 27th and MRFAP1 12th, with p near 0.001. That is suggestive, but not separable from noise at genome scale. The paper's own follow-up confirmed AMBRA1.

## Limits and uncertainty

- The column-to-sample mapping is inferred from GSM order and correlations.
- Technical triplicates may share one infection. If so, the replicates understate biological variance, and even BARCS's null-like result is optimistic.
- BARCS gene p-values are somewhat conservative here: 3.4% of genes have p < 0.05, where 5% is expected under the null. With the Wald test alone it was 1.3%.
- There is no published gene-level screen table (the supplements contain only RNA-seq DE tables), so rank correlation with MAGeCK could not be computed. Running MAGeCK on the same counts would allow that.
