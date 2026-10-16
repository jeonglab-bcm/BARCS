# GSE232543 reanalysis with BARCS 0.2.3

**Paper.** "Systematic identification of gene combinations to target in innate immune cells to enhance T cell activation", *Nature Communications* (2023), PMID 37813864, doi:10.1038/s41467-023-41792-8 (PMC10562403).

**Series.** This SubSeries holds the paper's Cebpb arm. The main CD86 and PD-L1 genome-wide and secondary screens (Chd4, Stat5b, Egr2, Med12, Sptlc2 and so on) are deposited elsewhere. It contains three FACS screens in Cas9 bone-marrow DCs, each sorted into the top and bottom 10% of CD86, with one library per bin:
1. a genome-wide screen in Cd11c-Cre Cebpb(fl/fl) (Cebpb-KO) DCs, 79,423 guides at 4 per gene, plus an unsorted library (Supplementary Data 11);
2. a secondary library of 661 Cebpb-regulated genes (10 guides each, 6,513 guides) in Cebpb-KO DCs;
3. the same secondary library in Cebpb-WT DCs (Supplementary Data 12).

No library has non-targeting guides. The GEO count files are identical to the "Reads" sheets of the supplement. The authors' MAGeCK compares Low with High, so Cd86 is the top positive gene. They conclude that the screens "confirmed that Nr4a3 mediates the increase in CD86 in Cebpb-targeted cells", that Stat2 activates DCs (positive regulator) and Rxra has the opposite phenotype, and they discuss Mitf (positive) and Fosl2 (negative).

**Design.** CD86-low vs CD86-high (`~ condition`, 1 vs 1) for each screen. The primary analysis is the Cebpb-KO secondary screen (`design.json`); the WT secondary (`design_wt.json`) and the Cebpb-KO genome-wide screen (`design_gw.json`) were run alongside. A gene enriched in the low bin is a positive regulator of CD86. With one library per bin, all three use the no-replicate path, with overdispersion pooled over all guides because there are no controls (conservative). Calls are screening-level, and calibration could not be checked.

**Composition.** The top 1% of guides hold 2.6-3.8% of reads (genome-wide). The secondary libraries are deep (22-34 M reads for 6,513 guides).

## Results

| | BARCS 0.2.3 | Paper (MAGeCK RRA, Low vs High) |
|---|---|---|
| Cebpb-KO secondary, genes at FDR 0.10 | 39 (14 positive regulators, 25 negative) | 22 positive, 27 negative |
| Cebpb-WT secondary, genes at FDR 0.10 | 43 (13 positive, 30 negative) | 24 positive, 35 negative |
| Cebpb-KO genome-wide, genes at FDR 0.10 | 1 (Cd86) | 2 positive (Cd86, Matn1) |
| Cd86 (control) | **#1 in all three** | #1 in all three |
| Nr4a3, KO secondary | **#5 positive, FDR 1e-10** | #6 positive, FDR < 1e-5 |
| Mitf, KO secondary | FDR 0.61 | #15 positive, FDR 0.033 |
| Stat2, WT secondary | FDR 0.15 | #15 positive, FDR 0.032 |
| Rxra, WT secondary | **#13, negative, FDR 1.5e-5** | #14 negative, FDR 1.6e-5 |
| Cebpb, WT secondary | **#2, negative, FDR 5e-98** | #1 negative |

Rank correlation with MAGeCK `pos|rank` is 0.82 for both secondary screens and 0.80 for the genome-wide screen. The top 10 positive regulators are identical in the Cebpb-KO secondary screen and share 8 of 10 in the WT one.

## Where BARCS agrees and differs

- **Agrees.** The paper's central claim from these screens holds. Nr4a3 is a strong positive regulator of CD86 in Cebpb-KO DCs, but not in WT DCs (FDR 0.70). In WT DCs, Cebpb and Rxra restrain CD86. Gene rankings track MAGeCK closely.
- **Differs.** Two discussed genes, Mitf (KO) and Stat2 (WT), pass FDR 0.05 in MAGeCK but not FDR 0.10 in BARCS (0.61 and 0.15). Their effects are small (+0.14 and +0.11 log), and BARCS tests each guide at an overdispersion pooled over all guides, which is conservative without controls.
- **Genome-wide Cebpb-KO screen.** The screen recovers only Cd86, in both methods (Matn1 is #3 in BARCS, FDR 1). At 4 guides per gene and one library per bin, it does not resolve the modifiers.

## Limits

One library per bin, so there are no replicate sorts. There are no non-targeting guides, so calibration and the control null are unavailable. The paper's headline genome-wide CD86/PD-L1 regulators are in other series.
