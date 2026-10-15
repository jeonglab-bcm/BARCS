# GSE252651 reanalysis with BARCS 0.2.3

**Paper.** Pauzaite, Wit, Seear and Nathan, "Deubiquitinating enzyme mutagenesis screens identify a USP43-dependent HIF-1 transcriptional response", *The EMBO Journal* (2024), PMID 39009674, doi:10.1038/s44318-024-00166-6 (PMC11377827).

**Screen.** A DUB sub-library of a "ubiquitome" knockout library (93 DUBs, 10 guides each, plus 10 non-targeting guides) in HeLa cells carrying a HIF-ODD-GFP reporter driven by a triple HRE. Two opposing FACS screens were run at day 8, each with one sorted library and one unsorted library taken at the same time:
- **Activator screen:** cells in 1% oxygen, sorted for GFP-low (files S7 sorted, L7 unsorted).
- **Suppressor screen:** cells in 21% oxygen, sorted for GFP-high (files S8 sorted, L8 unsorted).

The authors' MAGeCK gene summaries are in Dataset EV1. In the activator screen USP52 (FDR 5e-4), USP43 (0.007) and JOSD1 (0.08) are enriched. In the suppressor screen OTUD5 (0.02) and USP45 (0.07) are enriched. USP43 is the paper's subject.

**Counts and mapping.** GEO holds one headerless `<count> <guide>` file per sample. `prepare.R` merges the four files by guide name, fills absent guides with 0 and takes the gene as the guide-name prefix. GEO attaches the files to the opposite GSMs: the "FACS" GSMs hold L7/L8 and the "no FACS" GSMs hold S7/S8. The authors' own MAGeCK configuration on Zenodo (doi 10.5281/zenodo.10229339) sets `test S7, control L7` and `test S8, control L8`, so S is the sorted library. This is also the only assignment under which USP43, USP52 and OTUD5 come out enriched, so the GEO sample labels are a swap. The S7/S8 sorted libraries hold 3.8 M reads against 8.5–9.0 M for the unsorted ones, and S7 has the most guides below 10 reads.

**Design.** Sorted vs unsorted, `~ population`, one library each, for each screen. There are no replicates, so `run_barcs.R` uses the no-replicate path and the calls are screening-level. There are only 10 non-targeting guides, too few to estimate the overdispersion. BARCS therefore pooled it over all guides, a conservative choice because real hits inflate it: ρ = 7.6e-5 (activator) and 1.0e-4 (suppressor), 350–470-fold the Poisson variance. Control calibration and the control null could not be checked. Composition: the top 1% of guides hold 8% of reads (a small library with 10 guides per gene).

## Results

| | BARCS | Paper (MAGeCK, Dataset EV1) |
|---|---|---|
| Activator, GFP-low vs unsorted | 2 genes at FDR 0.10: USP52 (FDR 0.008), JOSD1 (0.088) | USP52, USP43, JOSD1 at FDR 0.10 |
| USP43 | #4 enriched of 93; all 10 guides higher in the sorted library; estimate +0.35; FDR 0.16 | #2, FDR 0.007 |
| Top-5 overlap (activator, enriched) | 5 of 5 | |
| Rank correlation (activator) | 0.77 | |
| Suppressor, GFP-high vs unsorted | 2 genes: OTUD5 (FDR 2e-5), EIF3H (0.008) | OTUD5, USP45 at FDR 0.10 |
| USP45 | #3, FDR 0.47 | #2, FDR 0.07 |
| Top-5 overlap (suppressor) | 5 of 5 | |
| Rank correlation (suppressor) | 0.69 | |

All 10 USP43 guides read higher in the GFP-low sort relative to library size. The ratios are modest (e.g. 9,727 → 6,722 raw reads against a 2.2-fold smaller sorted library), so its effect is consistent but small. EIF3H, a JAMM-domain protein in the DUB library, is one of BARCS's calls. It is depleted from the GFP-low sort (rank 3 two-sided) and enriched in the GFP-high sort, so its knockout raises reporter GFP in both screens. Nine of its ten guides agree in each screen. The paper does not discuss it, and it may act on reporter translation rather than on HIF.

## Where BARCS agrees and differs

- **Agrees.** The two methods rank the same top five DUBs in each screen. BARCS calls the strongest hit of each screen: USP52 in the activator screen and OTUD5 in the suppressor screen. Per-gene directions agree for 91–96% of DUBs.
- **Differs.** USP43, the paper's headline gene, ranks fourth but misses FDR 0.10 (0.16), and USP45 drops out. MAGeCK's RRA ranks guides within one library pair and takes its null from all genes. BARCS instead tests each guide against a sampling variance pooled over all guides. Without replicates, that variance cannot be separated from real effects, so it is inflated and conservative. With only 93 genes, the Benjamini–Hochberg correction also leaves little room. The paper's own validation (individual knockouts, RNA-seq, HIF target expression) supports USP43 beyond the screen.

## Limits

- One library per population and no replicate sorts: the calls are screening-level.
- With 10 non-targeting guides, calibration cannot be checked and there is no control null.
- The GEO sample labels for the sorted and unsorted files are swapped. The mapping here follows the file names and the authors' code, not the GSM titles.
