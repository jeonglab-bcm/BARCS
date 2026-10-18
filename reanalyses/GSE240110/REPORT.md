# GSE240110 reanalysis with BARCS 0.2.3

**Paper.** "Genome-Wide CRISPR Screens Identify Multiple Synthetic Lethal Targets That Enhance KRAS(G12C) Inhibitor Efficacy", *Cancer Research* (2023), PMID 37729426, doi:10.1158/0008-5472.can-23-2729 (not open access).

**Screen.** Genome-wide knockout library (71,090 guides, ~4 per gene, 142 LacZ/luciferase/EGFP control guides) in four KRAS-G12C-mutant NSCLC lines (H2030, H2122, H23, HCC44). Each line was treated with the G12C inhibitor MRTX849, the SHP2 inhibitor TNO155, their combination (COMBO), or DMSO for eight doublings, in two replicate cultures. Per-sample count files (guide id + count, gene embedded in the id) are merged by `prepare.R`.

**Design.** Primary analysis `~ cell_line + treatment`, MRTX vs DMSO pooled over the four lines (8 vs 8, cell line as a paired term, 11 residual df). Resistance genes (whose knockout lets cells survive MRTX) are enriched; synthetic-lethal genes are depleted. A secondary `COMBO vs DMSO` analysis (H2030, H2122, H23; HCC44 has no COMBO arm) is also run.

**Checks.** Non-targeting controls reach p < 0.05 at 48.6% before calibration, so `run_barcs.R` calibrated to the controls (scale 2.45, 4.9% after); the report quotes the calibrated model. The guide correlation is 0.127, elevated, from pooling four cell lines whose libraries carry line-specific structure; the paired cell_line term absorbs the means but not all of it. Composition is flat (top 1% of guides 3-6%). The controls sit −0.85 z from the targeting guides, so the control null is centred on the targeting guides and reports 676 genes; because that is far above the calibrated model (25) with offset controls, it is not quoted as a hit count.

## Results

| | BARCS 0.2.3 (MRTX vs DMSO) | Paper |
|---|---|---|
| Genes at FDR 0.10 | 25 (8 resistance / 17 synthetic-lethal), calibrated | Hippo pathway highlighted among MRTX hits |
| NF2 | #1 resistance, FDR 4e-7 | Hippo, lead finding |
| KIRREL / LATS2 | #2 / #3, FDR 4e-6 / 2e-4 | Hippo |
| NRP1 / TAOK1 / AMOTL2 | #4 / #5 / #7, all FDR < 0.10 | Hippo/related |
| WWTR1 (TAZ) | #11, depleted, FDR 0.05 | Hippo effector |
| COMBO vs DMSO | 1,882 genes (combination far more cytotoxic); NF2 #39, LATS2 #127 | — |

## Where BARCS agrees with the paper

- **Hippo pathway recovered as the top signal.** The paper's headline is that Hippo-pathway genes come out of the MRTX screen and motivate a KRAS-G12C + TEAD inhibitor combination. BARCS puts NF2 (#1), KIRREL (#2), LATS2 (#3), NRP1 (#4), TAOK1 (#5) and AMOTL2 (#7) at the very top as resistance genes, all at FDR 0.10, with the YAP/TAZ effector WWTR1 depleted. Loss of NF2/LATS2 activates YAP/TAZ-TEAD and blunts G12Ci, exactly the mechanism the paper proposes.
- The combination screen is dominated by general essentiality (1,882 genes) because MRTX+SHP2i kills much harder; NF2 and LATS2 remain enriched there too.

## Limits

- Four cell lines pooled; the guide correlation (0.127) is higher than a clean single-line screen, so the exact FDR count is approximate. Control calibration (needed because 49% of controls were significant raw) shortens the list.
- The paper is not open access and its supplement was not retrievable, so the comparison uses its named Hippo-pathway finding rather than a gene-level table.
- Per-cell-line synthetic-lethal differences are not broken out; only the pooled MRTX and COMBO contrasts are run.
