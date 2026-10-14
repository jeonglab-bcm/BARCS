# GSE318876 reanalysis with BARCS 0.2.3

**Paper.** Rathore, Dugan et al., "Systematic discovery of pro- and anti-HIV host factors in primary human CD4+ T cells", *Cell* 2026, PMID 42013838 (doi 10.1016/j.cell.2026.03.046, PMC13105272).

**Screens.** Genome-wide sort screens with an HIV-GFP reporter in primary human CD4+ T cells from three donors, each donor's infected culture sorted into reporter-negative and reporter-positive cells:
- CRISPRa, Calabrese pool A (56,762 guides, 3 per gene, 496 `NO-TARGET` controls; donors D11a-D13a) and pool B (56,476 guides; donors D11b-D13b). The two pools cover the same genes with different guides and were screened as separate cultures.
- CRISPRn, Brunello (77,441 guides, 1000 controls; donors D8-D10).

Counts are the deposited integer tables (`GSE318876_HIV-calA.count.txt.gz`, `..._HIV-calB.count.txt.gz`, `..._crisprn_gw.count.txt.gz`); column names are self-describing and match the GSM titles. GFP-Total and Uninfected columns are not used. The paper's MAGeCK RRA gene summaries are deposited in GEO (`GSE318876_All_screens_MAGeCK_gene_summaries.xlsx`); its genome-wide CRISPRa sheet combines pools A and B. In the paper's tables antiviral (CRISPRa) and proviral (CRISPRn) factors are negative selection (GFP-positive over GFP-negative).

**Design.** For each screen, reporter-negative vs reporter-positive, `~ donor + bin` (each donor's two sorts are paired), 3 vs 3, 2 residual df, moderation applied (prior df 25-30). Antiviral factors in CRISPRa and proviral dependencies in CRISPRn are enriched in the reporter-negative sort (positive estimate). Library totals; composition is unselected (top 1% of guides hold at most 4% of reads), no likelihood-ratio switches, guide correlation 0.009-0.018. Pool A (`design.json`) is the primary analysis; pool B (`design_calB.json`) and CRISPRn (`design_crisprn.json`) are run the same way.

**Calibration.** CRISPRa pools: 12.7% (A) and 13.9% (B) of control guides at p < 0.05 before calibration, calibrated to 5%, which shortens the lists. CRISPRn: 5.2%, no calibration. Controls sit close to the targeting guides (shift -0.25, +0.02, -0.11 z), so the control null is centred on the controls. For pool A the control-null count (956) is far above the model's 366 while the null is still centred on the controls, which points to offset controls, so it is not quoted; pool B gives 163 and CRISPRn 352.

## Results
| Screen | FDR 0.10 (model) | enriched in GFP-neg | depleted | control null |
|---|---|---|---|---|
| CRISPRa pool A | 366 | 126 | 240 | not quoted (offset controls) |
| CRISPRa pool B | 178 | 79 | 99 | 163 |
| CRISPRn | 342 | 173 | 169 | 352 |

- **CRISPRa named antiviral factors** are at the top of both pools: pool A PPID #1, PI16 #4, SHISA3 #7, ITM2A #8 (FDR <= 7e-6); pool B PPID #1, SHISA3 #3, PI16 #4, ITM2A #6 (FDR <= 1e-9). MX2 ranks #6 (A) and #34 (B). IFITM1, a known restriction factor the paper's table ranks #48, is #149 in A (FDR 0.12) and #38 in B (FDR 0.01).
- **CRISPRn:** CXCR4 #1 and CD4 #2 (the HIV receptor and co-receptor), as in the paper.
- **Rank agreement with the paper's MAGeCK tables:** CRISPRa pool A vs the combined A+B table, Spearman 0.53, 33 of the top 50 shared; pool B 0.48, 38 of 50; CRISPRn 0.74, 43 of 50 (`comparison.md`, `comparison_calB.md`, `comparison_crisprn.md`). The MAGeCK tables call 226 CRISPRa and 112 CRISPRn genes negative-selected at FDR 0.10.
- The top calls rest on all three or four guides in all three donors; no jackpot guides.

## BARCS vs paper
BARCS reproduces the paper's headline: the four antiviral factors it highlights are among the eight strongest CRISPRa hits in each pool, called independently from pools A and B, and the CRISPRn screen recovers CXCR4 and CD4 first. Differences are in list length and order below the top: BARCS analyses each pool separately with donor pairing and calibrates the CRISPRa pools to their non-targeting guides, whereas the paper pooled both CRISPRa libraries in MAGeCK RRA. The many depleted calls (genes whose activation or loss raises the reporter) were not the paper's focus.

## Limits
Three donors per screen (2 residual df). CRISPRa controls needed calibration (raw false-positive rate 13-14%), and pool A's control null is not interpretable. The paper's combined CRISPRa table is compared against each pool separately.
