# GSE240870 reanalysis with BARCS 0.2.2

**Paper.** "Derepressing nuclear pyruvate dehydrogenase induces therapeutic cancer cell reprogramming", *Cell Metabolism* (2025), PMID 40505660, doi:10.1016/j.cmet.2025.05.009. The paper is not open access. Its full text and supplementary tables could not be retrieved, so the comparison rests on the abstract, the GEO record and the one named hit.

**Screen.** A genome-wide CRISPR activation (CRISPRa) screen in 143B osteosarcoma cells, looking for genes whose activation blunts the effect of ISX9. There are two DMSO and two ISX9 libraries. The deposited count table has 201,530 guides, but about half (one sub-library) have no reads in any sample. After the count filter, 99,342 targeting guides (about 5 or 10 per gene, 18,534 genes) and 1,897 non-targeting guides were tested. Column names come from the table's second header row (DMSO-1, DMSO-2, ISX9-1, ISX9-2), which matches the GSM titles. Two further columns ("M+I") have no GEO sample and are not used. GEO says the authors used MAGeCK 0.5 RRA.

**Design.** `~ condition`, ISX9 vs DMSO, 4 libraries, 2 residual df. All four libraries correlate 0.97–0.98, so replicate pairing cannot be read from the data and no pairing term is used. Library totals include every guide, including the empty sub-library.

**Calibration.** 19.9% of non-targeting guides reached p < 0.05 before calibration, so the test was calibrated to them (scale 1.45; 5.0% after). This shortens the hit list.

## Results

| | Value |
|---|---|
| Genes at FDR 0.10 | 86 (38 enriched in ISX9, 48 depleted); 46 against the control-guide null |
| ELMSAN1 (MIDEAS) | **#1 of 18,534, enriched, FDR 7 × 10⁻²⁶** (control null FDR 0.02) |
| Next enriched | DUSP9, KDM1B, CFLAR, AHR |
| Strongest depleted | MYC, PDGFRB, TNF, GPR132, PDGFRA |

## Where BARCS agrees and differs

- **Agrees.** ELMSAN1, the only gene the paper names from this screen, is the strongest gene in BARCS in either direction. After adjusting for library depth, all ten of its guides with reads go up in both ISX9 libraries: four rise 2.9- to 4.6-fold (for example 123/128 → 464/284 reads, where ISX9-2 is the shallowest library), and six rise 1.2- to 1.9-fold.
- **Weak screen otherwise.** Selection is mild: the libraries correlate 0.97–0.98, and the non-targeting guides were over-dispersed until calibration. Apart from ELMSAN1, the enriched genes have effects of 1.3- to 1.7-fold, and the paper's ranked list could not be checked against them. The depleted side (MYC, PDGFRB, TNF) may reflect activation that sensitizes cells to ISX9 or that slows growth. The paper does not discuss it.

## Limits

- No access to the paper's gene table or methods beyond GEO; only the named hit is compared.
- Two libraries per arm, unpaired (2 residual df).
- About half of the deposited library is empty, so library totals carry no reads from those guides but count them; this does not affect the ratios.
