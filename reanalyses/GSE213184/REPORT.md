# GSE213184 reanalysis with BARCS 0.2.3

**Paper.** "A shear stress-responsive pathway in monocytes drives cardiopulmonary bypass-induced inflammation via spectrin/RAF1/store-operated calcium entry", *Cell Reports* (2026), PMID 41579376, doi:10.1016/j.celrep.2025.116903 (open access author manuscript, PMC13034653).

**Screen.** Brunello genome-wide library (77,441 guides, 4 per gene, 1,000 non-targeting) in IL8-GFP THP-1 monocytic cells. The guides are Brunello knockout guides in lentiCRISPRv2, although GEO and parts of the paper call it CRISPRi. Cells were sheared for 2 h in an in-vitro bypass circuit, fixed and FACS-sorted on GFP into the top 10% (LH2) and the next 25% (LH3); transduced unsheared cells (LH1) are the static baseline. One library per population, no replicates. The GEO workbook `GSE213184_S6612_summary.xlsx` holds integer counts for the three libraries and is used as served. Its "Input" column is the Entrez gene ID, not a library.

**Paper's analysis.** MAGeCK MLE (Data S1, built into `paper/mageck_mle.tsv` by `prepare.R`): one beta for the top-10% bin against a baseline made of the next-25% and static libraries together. The text's "1,628 candidate genes with adjusted p < 0.05" matches the table's Wald p-value < 0.05 with negative beta (1,627 genes). The quoted "adjusted p = 7.88e-15" for RAF1 and p = 3e-17 for SPTAN1 are the Wald p-values. The Wald FDR gives 150 genes at 0.05; MAGeCK's permutation FDR is at least 0.72 for every gene. Named hits: SPTAN1 (focus, "lowest p value"), RAF1 (validated), STIM2, MYL2, ACTA1, and KRAS (adjusted p 0.06).

**Designs.**
1. `top10_vs_next25` (headline): the two sorted bins of the same sheared population, 1 vs 1. No residual df, so the overdispersion is pooled over the non-targeting guides.
2. `top10_vs_static_and_next25`: the paper's design, top 10% vs the static and next-25% libraries as two reference libraries. Its 1 residual df comes only from the difference between two biologically different references.

**These are screening-level calls: no replicate cultures or sorts were measured.**

## The top-10% bin is sampled sparsely

The top-10% library has 10,202 guides with zero reads (13%), against 489 and 1,333 in the other two. Dropout follows abundance alone, and the non-targeting guides show it as well:

| Guide abundance in next 25% (reads) | 100-300 | 300-600 | 600-1,000 | 1,000-2,000 |
|---|---|---|---|---|
| zero in top 10%, all guides | 31% | 21% | 14% | 7% |
| zero in top 10%, non-targeting guides | 50% | 13% | 9% | 2% |

That is what sorting too few cells for the library produces. From each guide's abundance, about 11.6 genes are expected to lose all four guides by chance. Twelve did, including OR4D9 (MAGeCK's #1, an olfactory receptor), RAF1 and MAP3K2. SPTAN1 has 0, 1 and 3 reads in three guides (31 in the fourth), against 350-1,450 in the next-25% bin. The paper's top genes are therefore exactly the genes the sort's sampling noise would empty, and MAGeCK MLE's Wald test treats each zero as strong evidence. The pooled overdispersion BARCS estimates from the non-targeting guides is 474 times binomial.

## Results

| Analysis | BARCS FDR 0.10 | Control null | Notes |
|---|---|---|---|
| top 10% vs next 25% (1 vs 1) | 0 | 0 | controls at p < 0.05: 1.5% |
| top 10% vs static + next 25% (paper's design) | 91 (83 depleted) | 0 | 23% of controls at p < 0.05 before calibration, 4.9% after |

| Named gene | MAGeCK Wald p | BARCS 1 vs 1: p, FDR | Paper design: rank, FDR |
|---|---|---|---|
| SPTAN1 | 3e-17 | 0.32, 1 | 26, 0.047 |
| RAF1 | 8e-15 | 0.68, 1 | not tested (all four guides 0 in top 10%: no finite fit) |
| STIM2 | 6e-6 | 0.013, 1 | 400, 0.29 |
| MYL2 | 3e-4 | 0.59, 1 | 232, 0.22 |
| ACTA1 | 1e-3 | 0.56, 1 | 4,152, 0.85 |
| KRAS | 0.06 | 0.26, 1 | 1,002, 0.47 |

In the paper's design, BARCS calls 91 genes. Of these, 29 are among the 150 MAGeCK Wald-FDR 0.05 genes and 73 among its 1,627 "candidates"; SPTAN1 is #26 at FDR 0.047. The control null confirms none of them. In 69 of the 83 depleted calls, at least half the guides have 5 reads or fewer in the top-10% bin, the dropout pattern above (top calls APBA2, OR8H3 and AADAC have 0-3 reads per guide there). The controls are about twice as abundant as the targeting guides (median 6,400 vs 2,900 reads over three libraries), so they understate the noise of sparse guides. Raising `min_total_count` to 1,500 still gives 112 calls of the same kind (APBA2, EXOSC7, LDLRAD4) and 0 against the control null. Rank agreement with the MAGeCK table is low: Spearman 0.18 in the paper's design, 0.08 for the 1 vs 1 analysis.

## Verdict

BARCS does not reproduce the screen's hits. The two sorted bins differ by no more than sampling noise once the overdispersion seen in the non-targeting guides is allowed for. The paper-design calls, SPTAN1 among them, look like dropout of guides in an under-sampled sort, and the control null confirms none. RAF1 and SPTAN1 may still be real effectors (the paper validates them by knockout, qPCR and imaging), but this screen does not single them out.

## Limits

- One library per population, no replicate cultures or sorts: screening-level calls only.
- The paper's design treats two different reference populations as replicates. Its 1 residual df needed a 1.6-fold control calibration, and genes whose guides are all zero in one bin cannot be fitted.
