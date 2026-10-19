# GSE253885 - Toxoplasma Unassigned_2 in vivo CRISPR screen

## Paper
Tachibana, Sasai, Yamamoto. mBio 2024. PMID 39082802, doi 10.1128/mbio.01728-24.
The companion sublibrary to GSE253884: a second ~295-gene gRNA library
(Unassigned_2, 2,949 guides, ~10 gRNAs/gene) passaged in vitro (P4), used to
infect nine mice, and recovered from spleens at day 7. Same analysis: median
log2FC in vivo fitness, per-gene Wilcoxon (P4 vs WT mice), ranked by distance
from the in-vitro/in-vivo regression line. Validated hit from this sublibrary:
TgRimM (TGGT1_321310).

## Series and comparison
counts.tsv rebuilt by prepare.R from the eleven per-sample GEO files (Lib
plasmid input, P4 in vitro, WT_01..WT_09 nine mice); gene id = gRNA id with
trailing _<n> stripped (identical to the Un2_gRNA sheet). All integer, no
non-targeting guides.

Primary analysis in_vivo_vs_in_vitro: nine mouse libraries against the single P4
reference, ~ condition, coefficient conditionin_vivo. 8 residual df (nine mice
are biological replicates of the in vivo condition), so the standard BARCS model
applies and between-mouse variation sets the dispersion. The in vitro reference
is a single library (unreplicated baseline). The in vivo libraries are strongly
bottlenecked (top 1% of guides hold up to 53% of reads in one library), so the
primary fit uses median-ratio totals; in_vivo_vs_in_vitro_library_totals is kept
as a sensitivity analysis, and in_vitro_P4_vs_plasmid gives the in vitro fitness
axis (one library each, zero residual df, no-replicate path - screening-level
only). No non-targeting guides, so control_gene_pattern is unset and calibration
and the empirical null could not be used.

## Agreement
Comparison uses the series supplement Summary sheet (adj.p.value in vitro vs. in
vivo). All eleven genes the paper names or validated pass FDR 0.10, most in the
BARCS top 22: TgRimM/321310 (2), TBC6/237280 (6), DnaJ/203380 (10), CPSF/267710
(17), EFG1/240660 (37), and hypotheticals 300220 (4), 312840 (1), 277870 (3),
250790 (11), 221640 (22), 273905 (46).

BARCS calls 157 genes at FDR 0.10. Spearman vs the paper's adjusted p-value is
0.36 (the paper ranks by distance from the regression line, not by the tie-heavy
Wilcoxon p-value); effect direction agrees for 71% of genes.

## Differences and limits
As in GSE253884, BARCS's moderated guide-level model resolves the in vivo
depletion of the validated hits more sharply than the saturating Wilcoxon, while
genes essential in vitro as well as in vivo rank lower in BARCS because they are
not further depleted relative to the in vitro P4 reference.

Limits: single unreplicated in vitro reference; bottlenecked in vivo libraries
needing median-ratio totals (library-total depletion, 283 genes, not
interpreted); no non-targeting controls, so no calibration or empirical null.
The in vitro P4-vs-plasmid fitness call is screening-level.
