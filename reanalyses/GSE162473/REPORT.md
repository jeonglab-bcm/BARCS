# GSE162473 reanalysis with BARCS 0.2.3

**Paper.** Zhang et al., "Targeting DNA Damage Repair Functions of Two Histone Deacetylases, HDAC8 and SIRT6, Sensitizes Acute Myeloid Leukemia to NAMPT Inhibition", *Clinical Cancer Research* (2021), PMID 33542077, doi:10.1158/1078-0432.CCR-20-3724 (PMC8054771).

**Screen.** Genome-wide GeCKOv2 knockout library (about 119,000 guides, 1,000 non-targeting controls) in MOLM-13 AML cells, treated 3 days with a sublethal dose of the NAMPT inhibitor KPT-9274 or DMSO, 7 days after infection (Zhang et al. 2021). GEO deposits only a MAGeCK `count_normalized` table; `prepare.R` recovers the integer reads (every column 100% integer-valued; scales in `recovery_scales.json`). The authors ran MAGeCK VISPR on negatively selected guides (synthetic lethal with KPT-9274) and prioritized HDAC8 and SIRT6, which they validated with inhibitors.

**Design.** `~ condition`, KPT-9274 vs DMSO, 1 vs 1 library (Day 0 is the pre-treatment reference, not in the contrast). No residual df, so `run_barcs.R` used the no-replicate path with the overdispersion pooled over the non-targeting guides (inflation 36 at rho = 0). The calls are screening-level. Depletion marks sensitizers.

**Checks.** Control calibration is clean (4.3% of non-targeting guides at p < 0.05, no calibration needed). Composition is flat.

## Results

| | BARCS 0.2.3 | Authors (MAGeCK VISPR, Table 1) |
|---|---|---|
| Genes at FDR 0.10 | 0 (conservative no-replicate dispersion, 1 library per arm) | top-ranked by VISPR score, FDR not applied |
| SIRT6 (validated) | #3 of 20,687 by depletion, estimate -0.51, p 0.0011 | #7 |
| HDAC8 (validated) | #25, estimate -0.81, p 0.0045 | #17 |
| HEXA / IMPA2 / DCPS / PTGS1 | #53 / #89 / #357 / #435 | #15 / #6 / top-ranked |

## Where BARCS agrees and differs

- **Agrees on ranking.** SIRT6 is the #3 most-depleted gene and HDAC8 #25, both from six guides moving down consistently, so BARCS puts the paper's two validated genes near the top of the sensitizer list, close to their MAGeCK ranks (#7 and #17). HEXA and IMPA2 are also in the top ~90.
- **Differs on calling.** With one library per arm and the overdispersion pooled over controls, no gene reaches FDR 0.10; the paper likewise reported a ranked list, not an FDR-controlled set, and selected hits with available inhibitors. So the methods agree on the ranking but neither certifies individual genes from this one-replicate design.

## Limits

- One library per condition; the calls are screening-level. Counts were recovered from the MAGeCK-normalized table (exact, every column integer-valued).
