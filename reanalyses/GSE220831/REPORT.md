# GSE220831 reanalysis with BARCS 0.2.2

**Paper.** "Metabolic reprogramming by histone deacetylase inhibition preferentially targets NRF2-activated tumors", *Cell Reports* (2024), PMID 38165806, doi:10.1016/j.celrep.2023.113629 (PMC10853943).

**Screen.** A chromatin-focused knockout library (3,695 guides, 611 genes, about 6 guides per gene, 36 non-targeting guides) in two KP (Kras G12D; p53-null) and two KPK (also Keap1-null, so NRF2-active) mouse lung adenocarcinoma lines. Each line was sampled at T0 and after 14 population doublings in three replicates. The authors ran MAGeCK-MLE and ranked genes by the difference in beta score (KPK − KP); that gene summary is deposited on GEO. The paper also has a CB-839 arm, but GEO holds raw counts only for the vehicle arm, so only that arm is reanalyzed.

**Design.** `~ pair + time + kpk_t1`, all 24 libraries, 10 residual df. `pair` (12 levels) pairs each T1 library with the T0 of the same line and replicate. `time` is the dropout shared by all lines. `kpk_t1` is "yes" only for KPK libraries at T1, so its coefficient is the extra dropout in KPK lines, i.e. the genotype-by-time interaction the paper's KPK − KP beta measures. Columns P1–P4 were mapped to KP1, KP2, KPK1, KPK2 from GSM order. That mapping is **inferred**, but it is backed by the data: dropout in P1/P2 correlates best with the deposited KP betas and dropout in P3/P4 with the KPK betas.

**Calibration.** 2.8% of the 36 non-targeting guides reached p < 0.05, so no calibration was applied. That is too few controls for the automatic calibration or the control-guide null, so the FDR rests on the model alone. The estimated guide correlation (0.16) is high for a screen. It reflects a focused library with about six guides per gene, and the gene-level combination accounts for it.

## Results

| | BARCS 0.2.2 | Authors' MAGeCK-MLE (KPK − KP beta) |
|---|---|---|
| Genes at FDR 0.10 | 84 (44 more depleted in KPK, 40 less) | no FDR for the difference |
| Hdac1 | **#7, FDR 1.5 × 10⁻⁴** | #19 |
| Hdac3 | **#13, FDR 8 × 10⁻⁴** | #4 |
| Hdac2 | **#27, FDR 0.018** | #14 |
| Top depleted | Kdm1a, Setd5, Setdb1, Actr5, H2afz, Sirt6 | Mtr, Setd5, Kdm1a, Hdac3, H2afz, Chd4 |
| Rank correlation (KPK-specific depletion) | 0.94 | |
| Top-25 / top-50 overlap | 17 / 38 | |

## Where BARCS agrees and differs

- **Agrees.** All three class I HDACs the paper names pass FDR 0.02 as KPK-specific dependencies. The ordering of the whole library closely follows the authors' MLE beta difference (Spearman 0.94). The paper notes that Hdac1/2 loss had a weaker effect than Hdac3 loss, and BARCS shows the same thing in its effect sizes (−0.31 for both Hdac1 and Hdac2, −0.54 for Hdac3).
- **Differs in ordering.** BARCS ranks Hdac1 above Hdac3. Hdac3's guides drop out strongly in every line (it is a common dependency), so its KPK-specific difference carries more guide-to-guide variance. The MLE beta difference has no error term and ranks by size alone. Mtr, the authors' strongest KPK-specific gene, is #9 in BARCS (FDR 2 × 10⁻⁴).
- **More calls.** BARCS gives the interaction an FDR, which the deposited MLE difference does not. 84 genes pass FDR 0.10, including 40 that drop out less in KPK lines (for example Ube2m and Setd1b).

## Limits

- Only 36 non-targeting guides, so calibration could not be checked against a control null.
- Only two independent lines per genotype. Line-specific effects can be read as genotype effects, because the model treats the three replicates of a line as independent.
- The CB-839 arm cannot be reanalyzed from GEO (only MLE-normalized tables are deposited).
- The published comparison uses the KPK|beta − KP|beta difference computed from the deposited gene summary, which matches the score the paper plots (Fig. 1C).
