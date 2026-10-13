# GSE280666 reanalysis with BARCS 0.2.2

**Paper.** Zirman et al., "Pooled CRISPR screens identifies key regulators of bovine stem cell expansion for cultured meat", *Communications Biology* 8 (2025), PMID 40885801, doi:10.1038/s42003-025-08760-y (PMC12398484, open access). This series is the **long-term (100-day) screen**; the short-term (30-day) screen is GSE280676 (already reanalyzed, agrees). The paper's long-term analysis is a clustering of guide trajectories (Fig. 3) plus the Fig. 4D narrative; no gene-level MaGeCK table for the long-term screen is deposited (the supplement's "MaGeCK Results" sheet covers only the short-term days 3-30). The paper's long-term conclusion is that **TP53 is "the dominant and most robust candidate for enhancing proliferation following knockout,"** and that the co-enrichment of OSR2 (replicate B) and the non-cutting control nc_guide2480 (replicate A) is a **passenger artifact of co-inheritance at high MOI**, not a real effect.

**Screen.** AD-bMSCs were pre-cultured ~75 days (~100 doublings), transduced at high MOI with the same 3,000-guide library as GSE280676 (2,564 guides on 603 genes, 436 nc_guide non-cutting controls, each with its own label), and cultured 200 days with DNA sampling every ~5 days; GEO holds days 1-100, 3 replicate cultures. The count file is the GEO UTF-16 table converted unchanged to UTF-8 (`counts_utf8.tsv.gz`); columns match the GSM titles. All counts are integers.

## Passenger-guide caveat (this series)

This is a high-MOI long-term screen: each cell carries several guides, so a guide that rides inside a clone expanding for another reason rises with it. The paper states this directly for OSR2 and nc_guide2480. The raw counts confirm it: at day 15, nc_guide2480 guide 1 goes from 621 reads (day 1) to 315,180 / 154,930 / 137,674 across the three replicates, and one OSR2 guide (863_OSR2_4) reaches 79,426 / 252,433 / 121,105, while the other four OSR2 guides barely move. So an enriched call here can be a passenger, and any gene resting on one runaway guide must be read that way. The short-term screen (GSE280676, low MOI) is the clean version of the same biology.

## Composition and choice of contrast

Clonal takeover is even more extreme than in the short-term screen:

| Time point | Top-1% read share | Zero guides |
|---|---|---|
| day 1 | 4.3-4.4% | 1.5-1.6% |
| day 10 | 6.8-7.1% | 2.4-2.7% |
| day 15 | 16-19% | 2.4-3.1% |
| day 20 | 28-35% | 14-16% |
| day 30 | 66-72% | 34-38% |
| day 50-100 | 92-99% | 3-5% (library reduced to a few clones) |

The primary contrast is **day 15 vs day 1** with median-ratio totals (library totals give 15% of controls at p < 0.05 before calibration; median-ratio brings this to 7.7%), the last point before clones dominate. Day 10 vs day 1 (library totals, clean composition) is an earlier, weaker check, and day 30 vs day 1 (median-ratio, enrichment only) documents clonal takeover. No replicate term: the day-1 libraries are indistinguishable.

## Results

| Analysis | Enriched at FDR 0.10 | TP53 | PTEN | OSR2 | nc_guide2480 |
|---|---|---|---|---|---|
| **day 15 vs day 1 (median-ratio)** | 11 | **#1, FDR 5.6e-6**, 5/5 guides up | #37, FDR 0.13 | #151, FDR 0.38 | not called |
| day 10 vs day 1 (library) | 2 | **#1, FDR 0.001** | not enriched | #56 | not called |
| day 30 vs day 1 (median-ratio) | 0 (clonal) | #1 of enriched but FDR 0.12 | FDR 0.39 | FDR 0.66 | not called |

In the day-15 median-ratio run, TP53's five guides all rise in all three replicates and it is the single clearest enriched gene. PTEN and VGLL4 (the short-term leads) are present but weaker here (PTEN rank 37, FDR 0.13; VGLL4 rank 31). The non-cutting control nc_guide2480 does **not** pass FDR in any run: its one runaway guide is swamped by the 435 other controls that do not move, so gene-level aggregation discounts it, exactly as intended. OSR2 (rank 151, FDR 0.38) is likewise not called; only one of its five guides is the runaway.

## Where BARCS agrees and differs

- **Agrees on the headline.** BARCS puts TP53 first among enriched knockouts at day 15 and day 10, with every guide concordant, matching the paper's single firm long-term conclusion.
- **Agrees on the artifacts.** The paper says OSR2 and nc_guide2480 enrichment are passenger co-inheritance, not real. BARCS reaches the same place by construction: neither passes FDR, because gene-level aggregation over 4-5 guides (and 436 controls) does not reward one jackpot guide. This is a clean demonstration that guide aggregation absorbs high-MOI passenger noise.
- **Differs in extent.** The paper leans on clustering and does not give a long-term FDR gene list, so there is no rank list to correlate. BARCS also calls a handful of other enriched genes at day 15 (IL33, ZKSCAN4, GAD2, DMRT3, ZBTB43), none of which the paper names; at high MOI these should be treated as candidates, not established hits.
- **Day 30+ is uninterpretable.** By day 30 the library is a few clones (top 1% of guides hold 66-72% of reads); median-ratio totals are near the cap, and no gene passes FDR after calibration. This is the clonal-takeover regime, not biology.

## Limits

- High MOI: passenger guides co-inherit with drivers, so single-guide calls are unreliable; only multi-guide-concordant genes (TP53) are trustworthy.
- No deposited long-term gene table, so no rank correlation with the paper.
- The primary contrast is day 15, chosen to avoid clonal takeover; the paper's narrative centres on later time points where only TP53 survives.
- No replicate term; day-1 replicates are indistinguishable, so between-culture variance may be understated.
