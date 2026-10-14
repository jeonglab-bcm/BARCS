# GSE307513 reanalysis with BARCS 0.2.3

**Paper.** "Protein palmitoylation and sphingolipid metabolism control regulated exocytosis in cytotoxic lymphocytes", *Science Immunology* 10:eado3825 (2025), PMID 41105755, doi:10.1126/sciimmunol.ado3825 (not open access; the supplement could not be retrieved, so no gene-level table is compared). The abstract names ZDHHC17, its substrate SNAP23, and serine palmitoyltransferase (SPTLC1/SPTLC2) as regulators of cytotoxic-granule exocytosis found in a genome-scale KO screen in NK-92 cells.

**Series and counts.** `GSE307513_poolq_with_sort_counts.txt.gz` is a PoolQ table of integer counts for the Brunello library (77,441 guides, 1,000 non-targeting). `prepare.R` adds a `Gene` column by stripping the trailing `.<index>` from `Row Barcode IDs`; counts are unchanged. Column names equal the GSM library names: CD107a-high and CD107a-negative gates from two sorts, plus single plasmid, day-9 and day-17 libraries. Sort libraries hold 52-93 M reads; the top 1% of guides hold 5.1-5.6% (no bottleneck).

## Design

Knockouts that impair degranulation should be depleted from the CD107a-high gate relative to the negative gate. Primary analysis: **CD107a-high vs CD107a-negative, `~ sort + gate`, 2 vs 2**, pairing the two gates of each sort (they come from the same stimulated culture). This leaves 1 residual df, which BARCS moderates across guides (prior df 24). Because the correlations only weakly support pairing (within sort 0.82 and 0.75; across 0.78), the unpaired model (`~ gate`, residual df 2) was run as a sensitivity analysis (`design_unpaired.json`).

| Analysis | Raw control p<0.05 | Genes FDR 0.10 | Control null | Control shift |
|---|---|---|---|---|
| paired (`~ sort + gate`) | 6.9% (no calibration needed) | 90 (44 depleted, 46 enriched) | 82 | 0.14 z |
| unpaired (`~ gate`) | 7.6% (calibrated to 4.9%) | 70 (38 depleted, 32 enriched) | 86 | 0.12 z |

The model and the control null agree in both analyses.

## Agreement with the paper

Depletion ranks (primary analysis, 19,092 genes):

- **ZDHHC17** #8, FDR 2.5e-4; all four guides lower in the high gate in both sorts.
- **SNAP23** #18, FDR 0.009; three of four guides depleted, the fourth has almost no reads.
- **SPTLC1** #108 (FDR 0.29) and **SPTLC2** #170 (FDR 0.40). Both are depleted on average (log2 effect about -1.1 and -1.5), but each has guides that disagree between sorts (e.g. SPTLC2 guide 3: 176/702 neg vs 6/274 high; guide 4 has no reads), so neither passes FDR 0.10. The unpaired model gives them weaker FDRs still (0.49 and 0.67).

The screen's built-in positive controls are at the top: LAMP1 (CD107a itself, #3), STXBP2 (#2), RAB27A (#12) and STX11 (#6) are all at FDR < 0.01; UNC13D is #51 (FDR 0.14). Other depleted calls fit the paper's lipidation theme: CERT1/COL4A3BP (ceramide transport), ICMT and RCE1 (prenyl-protein processing), VAMP8 and EXOC6 (exocytosis). Enriched calls include ATP2B1 and ATP2A2 (calcium pumps), TBX21 and SEC23B.

## Limits

There are only two sorts, and the primary model has 1 residual df (moderated). There was no published table, so the comparison uses the four named genes. The sphingolipid arm of the story (SPTLC1/2) is directionally supported but not significant at FDR 0.10.
