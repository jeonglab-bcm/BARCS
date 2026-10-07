# GSE243760 reanalysis with BARCS 0.2.1

**Paper.** "Mechanosensitive genomic enhancers potentiate the cellular response to matrix stiffness", *Science* (2025), PMID 40997217 (PMC13005951). This is the migration screen from the same study as GSE243761.

**Screen.** CRISPRi of promoters and putative mechanoenhancers (21,459 guides, 1,053 elements, about 1,000 non-targeting) in a transwell migration assay, two replicates. The per-sample files were merged on the shared library. A series-level supplementary table has shifted columns and was not used.

**Design.** `~ replicate + fraction`, migrated vs non-migrated, 4 libraries, 1 residual df. Migrated and non-migrated cells of a replicate come from one population.

**Calibration.** Non-targeting guides were already well behaved (3.5% at p < 0.05), so no calibration was applied.

## Results

| Gene | BARCS rank (of 1,053) | Effect | FDR |
|---|---|---|---|
| ACTG1 | 2 | depleted from migrated | 0.046 |
| CDC42 | 3 | depleted | 0.075 |
| ITGAV | 6 | depleted | 0.075 |
| TPM3 | 809 | none | 1.0 |

The top element is DHS_625, an unannotated candidate enhancer. Six elements pass FDR 0.10.

## Where BARCS agrees and differs

- **Agrees.** Three of the paper's four migration genes are in the top six.
- **Differs.** TPM3 shows no effect here.
- **Unmapped claim.** The paper's strongest migration mechanoenhancer (pRE#62 near CYR61) could not be mapped to a DHS number, so it was not checked.

## Limits

- One residual degree of freedom.
- The CYR61 element is unmapped.
