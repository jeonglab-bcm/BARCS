# GSE253884 - Toxoplasma Unassigned_1 in vivo CRISPR screen

## Paper
Tachibana, Sasai, Yamamoto. "CRISPR screens identify genes essential for in vivo
virulence among proteins of hyperLOPIT-unassigned subcellular localization in
Toxoplasma." mBio 2024. PMID 39082802, doi 10.1128/mbio.01728-24.

A small-scale gRNA library (295 genes of unassigned hyperLOPIT localization plus
in vitro essential/dispensable and in vivo virulence controls, ~10 gRNAs/gene,
2,944 guides) was passaged in vitro (P4), used to infect ten mice by footpad, and
recovered from spleens at day 7. The authors scored in vivo fitness as the median
log2 fold change of guide abundance between each mouse and P4, tested each gene by
Wilcoxon rank-sum (P4 vs WT mice), and ranked by distance from the
in-vitro/in-vivo regression line. They validated TgGTPase (TGGT1_277840) and, in
Unassigned_2 (GSE253885), TgRimM by knockout.

## Series and comparison
GSE253884 deposits one count file per sample (plasmid input Lib, in vitro P4,
WT_01..WT_10 from ten mice); all integer, no non-targeting guides. counts.tsv is
rebuilt from these by prepare.R; the gene id is the gRNA id with trailing _<n>
stripped (verified identical to the Un1_gRNA sheet mapping).

Primary analysis in_vivo_vs_in_vitro: the ten mouse libraries against the single
P4 reference, ~ condition, coefficient conditionin_vivo. 9 residual df (the ten
mice are biological replicates of the in vivo condition), so the standard BARCS
model applies and between-mouse variation sets the dispersion. The in vitro
reference is a single library, so its baseline is unreplicated. The in vivo
libraries are strongly bottlenecked (top 1% of guides hold 23-41% of reads per
mouse), so library-total normalisation drives almost every gene to depletion; the
primary fit uses median-ratio totals. in_vivo_vs_in_vitro_library_totals is kept
as a sensitivity analysis, and in_vitro_P4_vs_plasmid reproduces the in vitro
fitness axis (one library each, zero residual df, no-replicate path, rho pooled
across all guides - a screening-level call only).

The library has no non-targeting guides; its controls are known essential/
dispensable and virulence genes (ROP18, GRA23), none a null, so
control_gene_pattern is unset and BARCS calibration and the empirical null could
not be used.

## Agreement
Comparison uses the series supplement Summary sheet (adj.p.value in vitro vs. in
vivo, the paper's gene-level Wilcoxon). All ten genes the paper names/validated
rank in the BARCS top 29 and pass FDR 0.10, nine in the top 18:
TGGT1_211850 (1), Trx4/224060 (2), Nudix/282190 (3), TgGTPase/277840 (4),
VIT/266800 (6), GLT2/239752 (8), DDI1/304680 (10), mRNACF/221190 (13),
AAMT/310070 (18), Caax/221170 (29).

BARCS calls 185 genes at FDR 0.05 and 198 at FDR 0.10 (of 295). In vivo essential
controls ROP18 (7) and GRA23 (9) also rank highly, as the paper reported.
Spearman vs the paper's adjusted p-value is 0.28 and top-15 Jaccard 0.36, which
is expected: the paper ranks by distance from the regression line, not by the
Wilcoxon p-value, and its Wilcoxon on ~10 guides saturates with heavy ties.
Effect direction agrees for 79% of genes.

## Differences and limits
Genes BARCS ranks high but the paper's adj.p column ranks lower (TgGTPase,
TGGT1_208390, mRNACF) have a clean large in vivo depletion that the tie-heavy
Wilcoxon cannot resolve; BARCS's moderated guide-level model separates them.
Genes in the paper's adj.p top-15 that BARCS ranks low (RON5/311470,
actin/209030, myosins) are essential in vitro as well, so relative to the in
vitro P4 reference they are not further depleted in vivo and BARCS correctly does
not flag them as in-vivo-specific.

Limits: single unreplicated in vitro reference; strongly bottlenecked in vivo
libraries needing median-ratio normalisation (library-total depletion, 284
genes, is unreliable and not interpreted); no non-targeting controls, so no
calibration or empirical null. The in vitro P4-vs-plasmid fitness call is
screening-level (one library per condition).
