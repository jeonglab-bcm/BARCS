# GSE167481 reanalysis with BARCS 0.2.3

**Paper.** Chafe et al., "Genome-wide synthetic lethal screen unveils novel CAIX-NFS1/xCT axis as a targetable vulnerability in hypoxic solid tumors", Science Advances (2021), PMID 34452919, doi:10.1126/sciadv.abj0364 (PMC8397268).

**Screen.** GeCKO library A (about 65,000 guides, 1,000 dummyguide controls) in hypoxic SUM159PT breast cancer cells, control (NTC) and CA9-knockout (KO-B4), each at T0 and T11 in duplicate; integer counts as deposited. The authors used loess normalization and a differential cumulative change (DCC) score between NTC and CA9-KO; NFS1 was a top synthetic-lethal gene, with ISCU, ISCA2, ABCB7, GLRX5 and redox genes (TXN, GSTM2, GSTM5, GSR, MOCS3). No gene-level table is deposited, so named genes are the comparison.

**Design.** `~ genotype + time + genotype:time`; the interaction term is the extra change in CA9-KO over 11 days beyond NTC, which is what DCC measures. Depleted = synthetic lethal. 8 libraries, 4 residual df (prior df 4.8); replicates are separate infections, so no pairing term.

**Checks.** 7.5% of controls reached p < 0.05, so run_barcs.R calibrated to the controls (5.0% after). Controls sit at the targeting guides (shift -0.03); the control null calls 15 genes, close to the model's 10. Depth is uneven: KO-B4_T11_Rep02 has 2.8 M reads against 12-23 M for most libraries.

## Results

| | BARCS 0.2.3 | Authors (DCC) |
|---|---|---|
| Genes at FDR 0.10 | 10 (5 depleted, 5 enriched); 15 against the control null | ranked by fitness score |
| NFS1 | #753 depleted, interaction -1.03, p 0.046, FDR 0.67 | top synthetic-lethal gene |
| ISCA2 / GLRX5 | #120 / #202, FDR about 0.5 | iron-sulfur set |
| ISCU / ABCB7 / TXN / GSR / MOCS3 | not depleted (ranks 2,845-14,360) | named hits |
| Top BARCS synthetic-lethal calls | PFN1, NDUFA6, NDUFS7, CS, PDHX (mitochondrial metabolism) | not highlighted |

## Where BARCS agrees and differs

- **NFS1 is not specific to CA9 loss in these counts.** NFS1 guides fall over 11 days in both genotypes (for example 801 to 132 reads in NTC replicate 2 and 486 to 11 in CA9-KO replicate 2), so most of its loss is general essentiality. The extra loss in CA9-KO (interaction -1.0) leans the right way but does not separate from replicate noise with 2 libraries per cell, partly because the weakest library (2.8 M reads) carries much of the CA9-KO T11 signal.
- **The iron-sulfur and redox set is mostly flat.** ISCA2 and GLRX5 lean depleted (ranks 120 and 202); ISCU, ABCB7, TXN, GSR and MOCS3 show no CA9-specific depletion. The paper's follow-up on NFS1 rests on siRNA and drug experiments, not on this screen alone.
- **BARCS's own calls** are mitochondrial and central-metabolism genes (NDUFA6, NDUFS7, CS, PDHX, MECR) whose loss hurts CA9-KO cells more; this fits the paper's theme of altered redox and pH metabolism without CAIX, but these are not the genes the authors named.

## Limits

- Two replicates per cell with uneven depth; the DCC used loess normalization and low-count filtering, which BARCS does not reproduce exactly.
