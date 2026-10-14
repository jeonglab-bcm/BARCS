# GSE302546 reanalysis with BARCS 0.2.3

**Paper.** "TRAPPC4 Promotes GPX4 Stability to Drive Ferroptosis Resistance and Tumor Progression in Head and Neck Squamous Cell Carcinoma", *Cancer Research* (2026), PMID 41974002, doi:10.1158/0008-5472.CAN-25-3654 (PMC13370119).

**Screen.** GeCKO v2 library A (63,950 guides in the count file: 3 per gene, 4 per miRNA, 1,000 non-targeting) in LIU-LSC-1 HNSCC cells. After 7 days of puromycin selection the pool was split and treated for 7 days with DMSO or RSL3 at IC20 (2.5 µM), three libraries each (columns `DMSO-1..3`, `R20-1..3`, matching GSM titles DMSO-1..3 and RSL3-1..3). Integer counts, 22-34 M reads per library; the GEO file was used as deposited. The authors ran MAGeCK RRA (median normalization) and deposited the gene-level negative-selection summary as Supplementary Table S8.

**Design.** `~ treatment`, RSL3 vs DMSO, 6 libraries, 4 residual df. No pairing across arms is described and the correlations do not pair replicates, so there is no replicate term. Library totals.

**Calibration.** 14.9% of non-targeting guides reached p < 0.05 before calibration, so `run_barcs.R` calibrated to the controls (scale 1.31; 5.0% after), which shortens the list. Composition is unremarkable (top 1% of guides hold 3.1% of reads in every library). Guide correlation 0.007. Non-targeting guides sit 0.53 z above the targeting guides (they make no cut), so the control null is centred on the targeting guides.

## Results

| | BARCS 0.2.3 | Authors' MAGeCK RRA (Table S8) |
|---|---|---|
| Genes at FDR 0.10 | 261 (257 depleted under RSL3); 601 against the control null centred on targeting guides | 2,046 depleted (1,348 at FDR 0.05) |
| Top five | TRAPPC4, LSM11, POLR3H, PSMG4, LONP1 | POLR3H, TRAPPC4, PSMG4, LSM11, LONP1 |
| TRAPPC4 | **#1**, FDR 1 × 10⁻¹² | #2, FDR 6 × 10⁻⁵ |
| GINS4 / USP5 / TPI1 (known ferroptosis regulators the paper cites) | #19 / #28 / #87, FDR ≤ 0.002 | #11 / #18 / #21 |
| Rank correlation (depletion score) | 0.77 | |
| Top-5 / top-50 / top-200 overlap | 5 / 37 / 135 | |

## Where BARCS agrees and differs

- **Agrees.** The paper's five prioritized candidates are exactly BARCS's top five, in a slightly different order, and TRAPPC4 is the strongest call. All three TRAPPC4 guides fall in every RSL3 replicate (e.g. 425/422/288 → 131/252/153 and 273/240/189 → 55/85/81 reads). The three ferroptosis regulators the paper uses to validate the screen also pass FDR 0.01.
- **List length.** MAGeCK RRA calls about 2,000 depleted genes at FDR 0.10; BARCS calls 257. Nearly all BARCS calls (99%) are in the MAGeCK list. The difference comes from the replicate-aware dispersion and the control calibration (raw non-targeting false-positive rate 15%): MAGeCK's per-guide variance, fitted across all guides, does not absorb the extra replicate-to-replicate spread that the controls show.
- **What the depleted list contains.** Many of the strongest BARCS calls are core-essential genes (ATP6V0C, GAPDH, EIF6, GINS4, snRNP and Pol III subunits), as in the paper's table. RSL3 at IC20 slows growth, so part of the depletion reflects fitness genes dropping further under drug rather than ferroptosis-specific sensitizers. Neither analysis separates the two; the paper's validation experiments address this for TRAPPC4.

## Limits

- Three libraries per arm from one split pool; arm differences cannot be separated from culture-to-culture variation beyond what the replicates show.
- No T0 or plasmid library is deposited, so fitness effects cannot be removed.
