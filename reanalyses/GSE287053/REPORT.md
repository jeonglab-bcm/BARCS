# GSE287053 reanalysis with BARCS 0.2.1

**Paper.** "CDK10 suppresses nucleic acid sensors-mediated antitumor immunity", *Nature Cancer* (2026), PMID 41507536, doi:10.1038/s43018-025-01100-3. The paper is not open access, so the comparison uses the abstract's named gene only.

**Screen.** CT26 cells with a mouse kinome library (2,952 guides, 714 genes, 100 non-targeting). The cells were grown in vitro, in nude mice, and in immunocompetent BALB/c mice, with 3 tumors or replicates each.

**Design.** Immune-dependent selection is WT vs nude, `~ host`, 6 libraries, 4 residual df. Knockouts that make tumors more visible to the immune system should be depleted in WT mice.

## Results

| | Value |
|---|---|
| Genes at FDR 0.10 | 43 |
| Cdk10 | depleted, effect −1.0, p = 0.0016, FDR 0.054, rank 18 of 713 |
| Top depleted | Sgk1, Stk11, Jak2, Ephb6, Ern1, Cdk13 |

## Where BARCS agrees and differs

- **Direction agrees.** Cdk10 knockouts are depleted in immunocompetent mice, as the paper reports.
- **Cdk10 is not the strongest hit.** Cdk10 is in the top 3% of genes but only borderline significant.
- **Plausible stronger hits.** Stk11 (LKB1) loss in tumor cells is linked to immune changes in other studies, and Jak2 is needed for interferon-γ signaling, so Jak2 knockouts would be expected to *escape* immunity, not deplete. Jak2's depletion here is therefore unexpected and worth checking against the paper.
- **WT tumors vary more than nude tumors.** WT_1 correlates only 0.6–0.67 with the other tumors, consistent with immune bottlenecks, which BARCS's overdispersion absorbs.

## Limits

- No published gene table was available.
- The tumors are independent animals; one outlier tumor (WT_1) widens the variance.
