# GSE229584 reanalysis with BARCS 0.2.2

**Paper.** "Unbiased transcription factor CRISPR screen identifies ZNF800 as master repressor of enteroendocrine differentiation", *Science* (2023), PMID 37883554, doi:10.1126/science.adi2246. The paper is not open access. Its supplementary tables could not be downloaded (HTTP 403), so the comparison uses only the genes the paper names. Those names come from the abstract and the authors' own summary of the screen (Lin & Clevers, PMC10819080).

**Screen.** A knockout library against the human transcription factors (7,294 guides, 1,800 genes, 96 non-targeting) in adult human small-intestinal organoids. The organoids carry a CHGA-iRFP reporter for enteroendocrine cells (EECs) and a MUC2-mNeonGreen reporter for goblet cells. After differentiation, cells were sorted into iRFP+ (EEC), mNeonGreen+ and double-negative fractions, in two biological replicates. GEO has one count file per sample; the triage step merged them by guide. Depth is low, about 2–3 M reads per library, or roughly 300 reads per guide.

**Design.** iRFP+ vs double-negative, `~ replicate + condition`, 4 libraries, 1 residual df. Within a replicate the three sorted fractions correlate 0.89–0.94, against 0.77–0.81 across replicates. They therefore come from one transduced culture, and replicate is a blocking term. The paper's exact comparison could not be checked. iRFP+ vs double-negative is *inferred* as the one that answers its question.

**Composition and normalization.** In the double-negative fraction the top 1% of guides hold 56–59% of reads; in iRFP+ they hold 29–33%. Most of those reads are on four guides against IRF2 and NFKB1, which take 20–29% of the reads in each sorted library. Non-targeting guides make up 0.7% of double-negative reads and 1.3% of iRFP+ reads. With library totals, 65% of control guides reached p < 0.05. Of the 642 genes called, 640 were "enriched", which is the dilution and not biology. The headline run therefore normalizes to the 96 non-targeting guides (`totals = "control"`). After that, 7.3% of control guides reach p < 0.05, below the 7.5% threshold, so no calibration was applied. A median-ratio run gives the same answer: 65 genes, all 58 control-normalized calls among them, and a gene p-value rank correlation of 0.99. There are fewer than 100 control guides, so the control-pseudo-gene null was not computed.

## Results

| | BARCS (control totals) |
|---|---|
| Genes at FDR 0.10 | 58 (8 enriched, 50 depleted in iRFP+) |
| ZNF800 (repressor of EEC fate) | **#1 enriched** (#6 overall), FDR 0.0004 |
| SOX4 (required for EECs) | depleted, #3, FDR 6 × 10⁻⁶ |
| NEUROG3 (required for EECs) | depleted, #23, FDR 0.014 |
| INSM1 (required for EECs) | #361, FDR 0.43 |
| ZHX2 / NFIC / TEF (new modulators) | FDR 0.07 / 0.11 / 0.37, all depleted |
| Other enriched calls | ATOH1, RBM10, GFI1, RGS7, BCL11B, SMAD9, ZNF174 |
| Strongest depleted | IRF2, ASCL2, SOX4, BCL6, ESRRA |

## Where BARCS agrees and differs

- **Agrees.** ZNF800 is the most enriched knockout in EECs. In raw counts, all four of its guides are higher in iRFP+ than in double-negative cells in both replicates (ratios 1.8–13, median about 5). The pooled controls have ratios of 1.4–2.3. The classical EEC transcription factors SOX4 and NEUROG3 are depleted, as expected for genes needed to make EECs.
- **INSM1 is not a contradiction.** Three of its four guides track the controls. The fourth has 0 reads in both iRFP+ libraries and 16 and 53 reads in the double-negative ones. At this depth, one guide cannot carry the gene.
- **IRF2.** IRF2 is the strongest depleted gene. Its guides dominate every sorted library. Their share of reads is 3–4× higher in double-negative than in iRFP+ cells, against about 2× for the controls. IRF2 knockout probably expands organoid growth rather than steering cell fate. The paper does not discuss it.

## Limits

- The paper's own gene table is not accessible. The contrast and the list of named genes are inferred from the abstract and the authors' review.
- Two replicates (1 residual df) and about 300 reads per guide.
- Strong composition skew in the sorted libraries. Library-total normalization fails here, and the result depends on the non-targeting guides being neutral.
- Only 96 controls, so no control-pseudo-gene null.
