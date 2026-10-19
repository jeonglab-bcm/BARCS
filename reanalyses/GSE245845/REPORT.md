# GSE245845 reanalysis with BARCS 0.2.3

**Paper.** "Proinsulin regulators identified with CRISPR screen and in vivo mouse QTL mapping", *Nature Communications* (2026), PMID 41974708, doi:10.1038/s41467-026-71726-z (open access, PMC13249969).

**Screen.** Mouse GeCKOv2 A + B knockout library (~6 guides per gene, ~2,000 non-targeting) in MIN6 beta cells, stained for proinsulin and insulin and FACS-sorted into relative proinsulin-high (Hi) and proinsulin-low (Lo) populations. One library per bin (GSM7849905 F5.ProinsHi, GSM7849906 F6.ProinsLo).

**Counts.** The GEO file `GSE245845_Reads_number_total.txt.gz` was written without field separators: each row reads `"1""MGLibA_00001""0610007P14Rik"1734`, with the Hi and Lo counts run together. It cannot be split on its own. The same raw read counts are in the paper's Supplementary Data 1 (sheet "Raw_reads_number_analysis"). `prepare.R` reads them and checks every one of the 126,372 rows against GEO: same guide ID, and the two counts written side by side reproduce the GEO characters exactly. Both files write a zero count as "NA". The paper's own log2 fold changes, which equal log2((Hi + 5) / (Lo + 5)) plus a constant, confirm the value 0 (for example Lo = 1 with Hi "NA" gives 0.197). So NA becomes 0. The supplement lost gene names for the 2,561 guides with no Hi reads, and Excel turned 146 March/Sept gene names into dates. `prepare.R` therefore takes genes from MAGeCK's mouse GeCKOv2 library file, matched on guide ID; every other name agrees with it. The counts are integers, 1.7-2.0% zeros. Hi and Lo correlate at Spearman 0.88.

**Design.** `~ bin`, Hi vs Lo (positive = enriched in proinsulin-high cells, the sign of the paper's log2FC.HitoLo). Negative proinsulin regulators such as Pcsk1 and Cpe are positive; positive regulators such as Pdia6 are negative. With one library per bin, `run_barcs.R` pools the overdispersion over 1,654 usable non-targeting guides (inflation 1.9 over binomial). **These are screening-level calls: no replicate sorts or cultures were measured, so that variation is not in the error model.**

**Checks.** Composition is flat (top 1% of guides hold 5.5% of reads). Non-targeting guides at p < 0.05: 4.8%, so no calibration was needed. Controls sit 0.005 z from the targeting guides and are about as abundant as them (median 65 vs 55 reads per guide over both bins). The control null gives 422 genes at FDR 0.10, against 356 for the model.

## Results

BARCS: 356 genes at FDR 0.10 (211 enriched in Hi, 145 in Lo); 206 at FDR 0.05. The top genes are Pcsk1, Cpe, Furin, Rbm18, Slc38a10, Paxip1, Dpagt1 and Yipf5.

The paper called 84 regulators (60 negative, 24 positive) with a per-guide binomial test (FDR < 0.01) and a rule of at least two significant guides and no contradicting guide.

| Named gene | Paper | BARCS rank | Effect (log, Hi vs Lo) | FDR |
|---|---|---|---|---|
| Pcsk1 | strongest negative regulator | 1 | +3.09 | 3e-28 |
| Cpe | negative regulator | 2 | +1.36 | 4e-22 |
| Furin | top negative regulator | 3 | +1.51 | 2e-9 |
| Yipf5 | positive regulator | 8 | -1.62 | 5e-8 |
| Pdia6 | strongest positive regulator | 13 | -1.82 | 2e-6 |
| Hid1 | negative regulator | 17 | +0.78 | 4e-6 |
| Madd | top negative regulator | 21 | +0.75 | 1e-5 |

All seven pass FDR 0.10 in BARCS, in the paper's direction. Of the 84 paper genes, 63 pass BARCS FDR 0.10, and 80 (95%) share the sign. Among the 84, BARCS ranks and the paper's mean fold changes correlate at Spearman 0.27 (`comparison.md`). Only 84 paper genes have a score, so this is a selected subset.

## Where they differ

- **Paper hits BARCS does not call (21).** These are mostly genes carried by two low-count guides, which the binomial test treats as precise, while the gene's other guides are flat or point the other way. Rpl7 (paper #7 by fold change) has guides of 17 vs 0 and 10 vs 5 reads; BARCS ranks it 630. Others are similar: AA987161 (30 vs 4 and 104 vs 181), Ube2cbp (48 vs 14 next to 29 vs 86), Irf2bp2 and Olfr1475.
- **BARCS hits outside the paper's list.** These are consistent multi-guide shifts that miss the paper's two-guide FDR < 0.01 rule. Rbm18 (#4): 5 of 6 guides 2-9-fold up in Lo (for example 11 vs 157 reads). Slc38a10 (#5): all 6 guides up in Hi. Paxip1, Dpagt1 (an N-glycosylation enzyme) and the COPII/ER-Golgi genes Sec24c and Sec22b fit the paper's own trafficking theme.
- **Sensitivity.** With `min_total_count` 100 (guides with at least 100 reads over both bins) BARCS calls 151 genes, 40 of them among the paper's 84. Cpe, Pcsk1, Sec24c, Tram1, Rbm18 and Paxip1 stay on top. The longer list at the default filter is therefore partly low-count guides, as for the paper's list.

## Why

Both methods use the same two libraries, so neither sees replicate variation. The paper tests each guide with a binomial test, which ignores overdispersion entirely and so calls many guides; its two-guide rule then trims the gene list. BARCS inflates the variance with an overdispersion estimated from the non-targeting guides and pools every guide per gene by Stouffer. That gives it more calls from consistent moderate guides and fewer from single low-count guides.

## Limits

- One library per bin, no replicate sorts: screening-level calls only.
- The counts come from the paper's supplement, after an exact row-by-row check against the malformed GEO file. Gene names come from the GeCKOv2 library file.
- The paper's published table covers only its 84 calls, so the rank comparison is limited to them.
