# GSE328830 reanalysis with BARCS 0.2.2

**Paper.** Fenoglio et al., "Temporal control of sgRNA library activation unlocks large-scale in vivo CRISPR screens", *Cell Reports Methods* 6 (2026), PMID 42225068, doi:10.1016/j.crmeth.2026.101470 (PMC13390110, open access).

**Screen.** CRISPR-StAR (Stochastic Activation by Recombination): an inducible pooled system where Cre recombination produces, with equal frequency, an **active** sgRNA (gene knockout) and an **inactive** sgRNA (a matched internal clonal control in the same tumor). The knockout phenotype is the active/inactive (A/I) ratio. A ~30,000-sgRNA library (198 essential genes / 788 guides, 72 intron-cutting controls (ITC), 500 non-targeting controls (NTC), 6,925 other genes) was screened in A549 lung xenografts across 118 tumors (invivo_screen) and 49 tumors (invivo_validation), plus in vitro arms.

**Fetch note.** The main count file is the 633 MB UMI/clone-resolved long-format table; it was fetched with `--max-mb 800` (the reason this series was previously skipped). UMI counts were aggregated per guide, summing active and inactive counts across all tumors, separately for the 118-mouse and 49-mouse cohorts, to build a guide-level matrix (29,059 guides).

## Design and method caveat

The faithful BARCS mapping is **active vs inactive as the knockout effect**, with cohort (118-mouse screen vs 49-mouse validation) as a paired batch term, so essential-gene guides should deplete in the active state. The 500 NTC single-guide controls calibrate.

**Caveat.** The paper explicitly states that bulk-abundance tools (MAGeCK, BAGEL, JACKS) are not suited to this clone-resolved data and built a dedicated per-clone Bayesian pipeline (CSTAR-UMIBB) that normalizes active against inactive *within each clone* and weights by clone size. BARCS's bulk active-vs-inactive aggregation is the "traditional proxy" the paper shows is weaker (their Fig 2F: r = 0.43 for bulk log active counts vs r = 0.8 with per-clone weighting). This reanalysis therefore tests whether the essential-gene and tumor-suppressor signal survives at the **bulk** level; it does not reproduce the paper's per-clone wθ / Δ scores.

## Results (in vivo active vs inactive, cohort-paired)

- **298 genes at FDR 0.10.** Top depleted are canonical essentials: KPNB1, SF3B5, MYC, TRMT112, RPL8, KIF11.
- **Essential-gene recovery is strong despite the bulk aggregation:** 90/197 essential genes called depleted; median effect −0.74 (essential) vs +0.01 (non-essential); **AUC essential-vs-non-essential = 0.905**. Non-essential false-positive rate 2.4%; 0/72 ITC called.
- **PLK1** (the paper's example essential, shown dropping out across 118 tumors): depleted, estimate −0.92, FDR 0.015.

| Gene | Paper | BARCS effect | FDR |
|---|---|---|---|
| PLK1 | essential dropout example | −0.92 (depleted) | 0.015 |
| MYC / KIF11 | essential | −1.85 / −1.64 | 7e-4 |
| **KMT2D** | in vivo growth-required | **−1.61 (depleted)** | 8e-4 |
| **KMT2C** | in vivo tumor-suppressor (opposite of KMT2D) | **+1.99 (enriched)** | 0.0015 |
| PTEN | tumor-suppressor positive control | +1.95 (enriched) | 8e-4 |

## Where BARCS agrees and differs

- **Agrees on the method's core validation.** Even using only bulk active/inactive aggregation, BARCS separates essential genes from controls with AUC 0.90 and recovers PLK1, confirming the CRISPR-StAR active/inactive readout carries a strong, analyzable knockout signal.
- **Agrees on the headline biology.** The paper's key in vivo finding is that **KMT2C and KMT2D have opposite phenotypes**. BARCS reproduces this directly: KMT2D depletes (growth-required in vivo) while KMT2C enriches (tumor-suppressor-like), and PTEN enriches as a positive-control tumor suppressor.
- **Differs in resolution.** BARCS cannot reproduce the paper's per-clone wθ/Δ scores or its in-vivo-specific Δ-based hit list (173 genes at FDR 0.001 from the in vivo-vs-in vitro comparison), which depend on clone-resolved matched controls. The bulk proxy also leaves 42.9% of NTC controls at p < 0.05 before calibration (the composition/batch structure the per-clone method removes), so BARCS calibrates to the NTCs and the control-null count (centred on the targeting guides) is not quoted.

## Limits

- Bulk UMI aggregation discards the per-clone matched-control structure that is the paper's main advance; this is the weaker "traditional proxy".
- active-vs-inactive with 2 cohorts as the only replicate structure; NTCs are single-guide.
- In vivo-specific (in vivo vs in vitro Δ) analysis and the 173-gene list are not reproduced here.
