# GSE291338 reanalysis with BARCS 0.2.1

**Paper.** "CDK4/6 inhibition overcomes venetoclax resistance mechanisms with enhanced combination activity in acute myeloid leukemia", *Cell Reports Medicine* (2026), PMID 41468895, doi:10.1016/j.xcrm.2025.102526 (PMC12866115).

**Screen.** OCI-AML2 cells, genome-wide library (90,709 guides, about 5 per gene). Arms: day 0, DMSO, palbociclib, venetoclax, and ven+palbo, with 2 replicates per treated arm. The paper's supplementary table (mmc2) gives gene-level results per arm versus DMSO.

**Design.** Each drug arm vs DMSO, `~ treatment`, 4 libraries, 2 residual df, `test = "auto"`. Library totals for palbo; median-ratio totals for ven and combo.

## Library composition

| Library | Top 1% of guides: share of reads |
|---|---|
| DMSO, day 0 | 2–3% |
| Palbociclib | about 8% |
| Venetoclax | 90–94% |
| Ven+palbo | 60–84% |

Venetoclax killed nearly every clone. The five BAX guides alone hold about half of each ven library.

## Results

| Arm | Genes at FDR 0.10 | Named genes (rank among enriched or all, FDR) |
|---|---|---|
| Palbo vs DMSO | 1,437 | HNRNPU #4 (1e-5), CEBPE #6 (2e-5), IKZF1 #115 (0.009), RB1 #380 (0.03) |
| Ven vs DMSO | 103 enriched | **BAX #3 (3e-4)**, IKZF1 #6 (0.001), PMAIP1 #57 (0.051) |
| Combo vs DMSO | 78 enriched | IKZF1 #37 (0.057) |

- **Palbociclib** (no bottleneck): 8 of the paper's top 25 genes are in BARCS's top 25. RB1, the paper's palbo resistance gene, passes FDR 0.05.
- **Venetoclax:** BAX, the paper's headline ven resistance gene, ranks third among enriched genes.
- **Combination:** IKZF1, the paper's ven+palbo resistance gene, is borderline (FDR 0.057).

## What changed in BARCS to get here

1. **Wald test failure.** Every BAX guide rises from about 20,000 to 2–10 million reads in both ven replicates. Under BARCS 0.2.0's Wald test, BAX still scored gene p = 0.79.
   - With one dispersion per guide, a change of this size implies a huge logit-scale variance at the low-abundance (DMSO) end.
   - The Wald standard error then grows faster than the estimate (the Hauck–Donner effect).
2. **The fix.** BARCS 0.2.1 adds `test = "lr"` / `"auto"`. `"auto"` uses the fixed-dispersion likelihood ratio only for guides whose fitted proportions span more than 100-fold: here 3,243 guides in the ven arm and 995 in the combo arm.
   - On the CRISPulator benchmark, `"auto"` switches 0.1% of guides and gives the same ranking and calls as Wald.
   - In null simulations it is no more liberal than Wald.
3. **Normalization.** Median-ratio totals are needed in the collapsed arms. With library totals, almost every gene is called depleted.

## Limits

- Two replicates per arm give 2 residual degrees of freedom.
- In the ven and combo arms only enrichment is interpretable. Depletion calls there (thousands of genes) reflect the population collapse, not gene-specific dropout.
