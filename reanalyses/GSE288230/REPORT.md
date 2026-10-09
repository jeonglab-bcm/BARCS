# GSE288230 reanalysis with BARCS 0.2.2

**Paper.** "A genome-wide screen identifies genes required for erythroid differentiation", *Nature Communications* (2025), PMID 40221460, doi:10.1038/s41467-025-58739-w (PMC11993733).

**Screen.** CRISPR-Cas9 knockout screens in HUDEP-2 cells comparing proerythroblasts (day 0) with orthochromatic erythroblasts (day 12): genes required for terminal erythroid differentiation drop out (**depleted**) at D12. A genome-scale GeCKOv2 library (119,461 guides, 1,000 non-targeting controls) is the **primary** screen (the authors call 277 genes at LFC < -1, FDR < 0.01 and name NHLRC2 and VAC14; VAC14 validated in vivo). A focused **secondary** library (12,444 guides, 500 non-targeting controls) revalidates candidates; VAC14 is in it, NHLRC2 is not. Counts were read from the `*_noBOM.tsv.gz` copies (the deposited CSVs carry a BOM on the first header cell). No deposited gene-level table, so the comparison uses named hits only.

**Design.** Both: `~ replicate + condition`, D12 vs D0, 6 libraries, `test = "auto"`. Three replicates paired by infection (replicate is a blocking term, 2 residual df). Column-to-sample mapping is from headers equal to the GSM titles; it is not inferred.

**Calibration.** Genome-scale: **46.6%** of the 1,000 non-targeting guides reached p < 0.05 — the control null is badly inflated (only 2 residual df against a large, bottlenecked, clonally structured population). The test was calibrated to the controls (control_scale 2.42), which collapses the model hit list. Secondary: 14.8% at p < 0.05, calibrated to 5.0% (control_scale 1.39).

## Results — genome-scale (primary)

| | Value |
|---|---|
| Genes at FDR 0.10 (model, after calibration) | 0 |
| Genes at FDR 0.10 (control null, centred on targeting guides) | 0 |

| Named / reference gene | BARCS depleted rank | Effect | raw p | model FDR | empirical FDR |
|---|---|---|---|---|---|
| NHLRC2 | 78 | -1.30 | 0.055 | 1 | 1 |
| VAC14 | 2,343 | -0.28 | 0.50 | 1 | 1 |
| KLF1 | 521 | -0.93 | 0.22 | 1 | 1 |
| GATA1 | 3,250 | -0.27 | 0.57 | 1 | 1 |
| ALAS2 | 4 | -1.13 | 0.0015 | 1 | 0.18 |

Top depleted (by effect/p): LDHB, NDUFA5/A4, ALAS2, NCEH1, NDUFS6, UROD, HMBS — erythroid/heme and respiratory genes in the right direction.

## Results — secondary (focused validation library)

| | Value |
|---|---|
| Genes at FDR 0.10 | 729 (485 depleted); control-null 940 |

| Named gene | BARCS depleted rank | Effect | p | FDR | guides |
|---|---|---|---|---|---|
| VAC14 | 67 | -0.43 | 2.0e-11 | 2.6e-10 | 10 |
| GATA1 | 273 | -0.52 | 6.2e-05 | 2.4e-04 | 10 |
| ALAS2 | 3 | -1.36 | 6.6e-30 | 1.0e-27 | 10 |
| NHLRC2 | not in library | | | | |

## Where BARCS agrees and differs

- **The validated gene VAC14 is recovered in the secondary library** at FDR 2.6e-10 (#67 depleted), with the expected direction, matching the paper's in-vivo validation.
- **The genome-scale screen's hit list collapses under control calibration.** Nearly half the non-targeting guides reach p < 0.05, so calibrating to them drives every gene to model FDR 1 — including known erythroid genes ALAS2 (#4) and UROD (#7). BARCS calls 0 genes where the paper calls 277. This is a power/calibration failure on a noisy, lowly-replicated genome-scale screen, **not a contradiction**: NHLRC2 is depleted at the guide level (effect -1.30, raw p 0.055) and simply does not clear the calibrated threshold; VAC14 is weak in the genome-scale library but strong in the cleaner secondary one.
- **Control null.** The non-targeting guides sit away from the targeting guides (+0.59 z genome-scale, −0.75 z secondary; they make no cut), so the null is centred on the targeting guides. It agrees with the calibrated model in the genome-scale screen (0 genes; NHLRC2 and VAC14 at FDR 1) and gives 940 genes in the secondary library, VAC14, GATA1 and ALAS2 among them (FDR 7e-5). An earlier, uncentred version of this null reported 3,733 genome-scale genes; that count was an artifact of the offset.

## Limits

- Three replicates, 2 residual df, against a genome-scale library with a badly inflated control null (46.6% at p < 0.05).
- No deposited gene-level table; comparison is named hits only.
- The genome-scale depletion calls should not be trusted after the calibration flattening; the secondary library is the reliable BARCS result here.
