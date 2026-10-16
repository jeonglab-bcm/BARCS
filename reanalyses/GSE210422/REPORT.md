# GSE210422 reanalysis with BARCS 0.2.3

**Paper.** "Landscape of enhancer disruption and functional screen in melanoma cells", *Genome Biology* (2023), PMID 37904237, doi:10.1186/s13059-023-03087-5 (PMC10614365).

**Screen.** The authors ran a dCas9-KRAB CRISPRi screen of melanoma highly recurrent region (HRR) associated enhancers in A375 cells. The library has 9,977 guides: 8,977 over 805 enhancer core regions, plus 1,000 non-targeting guides, each listed as its own `N_<i>`. Libraries were sequenced at day 0 and day 21, two replicates each. GEO holds one count file per sample. `prepare.R` joins them on guide and gene. It also keeps the A375 day-7 and SK-MEL-2 libraries added in 2023, which are not analysed. The paper's MAGeCK analysis of day 21 vs day 0 (Table S7) reports 66 positively selected enhancers, whose silencing speeds growth (tumour-suppressive candidates), and 17 negatively selected. It follows up E_349 (looping to MEF2A by 4C), E_156 (PTEN) and E_409 (NF1).

**Design.** `~ condition`, A375 day 21 vs day 0, 2 vs 2, unpaired, compared in the enrichment direction. The A375 day-7 and SK-MEL-2 libraries are bottlenecked (55-76% of guides at zero, top 1% of guides holding 11-19% of reads). The A375 day-7 libraries also correlate better with SK-MEL-2 day 7 than with A375 day 0. They are not used.

**Calibration and composition.** 0.7% of non-targeting guides reach p < 0.05, so the model is conservative on the controls and no calibration was needed. The top 1% of guides hold 5.6-8.1% of reads. Residual df 2, moderation applied, guide correlation 0.011. 184 guides moving more than 100-fold were tested by likelihood ratio. Against pseudo-genes built from the controls (centred on the controls, shift -0.11 z), 259 enhancers pass FDR 0.10: 71 enriched and 188 depleted. The top enriched calls rest on several guides each, with no jackpots.

## Results

| | BARCS 0.2.3 | Paper (MAGeCK, Table S7) |
|---|---|---|
| Enhancers at FDR 0.10 | 226 (21 enriched, 205 depleted); 259 against the control null (71 enriched) | 66 positive, 17 negative |
| E_349 (MEF2A/IGF1R) | **#3 enriched, FDR 0.014** | #1 positive |
| E_409 (NF1) | **#5 enriched, FDR 0.023** | #3 positive |
| E_156 (PTEN) | **#17 enriched, FDR 0.065** | #2 positive |
| Paper's 66 positive enhancers | 20 enriched at FDR 0.10 | |
| Paper's 17 negative enhancers | 11 depleted at FDR 0.10 | |

Within the 66 published positive enhancers, rank correlation with the MAGeCK score is 0.29, and 4 of the paper's top 10 are in the BARCS top 10.

## Where BARCS agrees and differs

- **Agrees on the headline enhancers.** E_349, E_409 and E_156, the three the paper validates (4C for E_349 and E_156), all pass FDR 0.10 in the enrichment direction.
- **Shorter positive list.** BARCS model FDR keeps 20 of the 66 positive enhancers. Several published top-10 positives have small or inconsistent effects in BARCS, for example E_728 (TADA3) #367, E_611 (UBE2F) #417 and E_358 (GRIN2A) #497. With two replicates per arm and per-guide dispersion, BARCS does not reproduce them. MAGeCK's RRA, by contrast, rewards a few strongly enriched guides. The control-null count (71 enriched) is closer to the paper's 66.
- **Many depleted enhancers.** BARCS calls 205 depleted enhancers (median effect -0.47 log), against the paper's 17 negatives. CRISPRi at enhancers and promoter-proximal sites of essential genes (the library was designed around melanoma-essential genes, Table S4) depletes in a 21-day culture. The paper's question was positive selection, so these are not compared further.

## Limits

Two replicates per arm. The paper published only its significant enhancers, so rank comparison is restricted to those 66. The paper's day-7 analyses use libraries that are too bottlenecked to reanalyse.
