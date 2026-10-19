# GSE260469 - B16F10 druggable in vivo lung-metastasis screen (OPG)

## Paper
"OPG promotes lung metastasis by reducing CXCL10 production of monocyte-derived
macrophages and decreasing NK cell recruitment." eBioMedicine 2024/2025. PMID
39674088, PMC11700254. B16F10 melanoma transduced with a druggable sgRNA library
was injected i.v. into mice treated with control IgG or anti-Csf1R (to deplete
monocyte-derived macrophages, Mo-macs); lung metastases were harvested and sgRNAs
sequenced. Analysed by MAGeCK. The screen nominated osteoprotegerin OPG
(Tnfrsf11b), which the authors then validated extensively: OPG blocks RANKL-RANK
on Mo-macs, suppressing CXCL10 and NK-cell recruitment to permit metastasis.

## Series and comparison
GSE260469 deposits one count file with paired technical re-reads of each library
(columns 1.X / 2.X; constant ~3-fold ratio, r=0.995 - technical re-reads, so
prepare.R sums each pair) into three libraries: cell (in vitro input), IgG and
csf1r (metastases). guide=Oligo_Name, gene=Gene_Symbol. The library carries 100
Intergenic + 100 Offtarget control guides (control_gene_pattern
^(Intergenic|Offtarget)).

Primary analysis csf1r_vs_IgG reproduces the paper's key MAGeCK comparison
(anti-Csf1R vs IgG; paper table mmc5), direction enriched (OPG-KO cells
metastasize better when Mo-macs are depleted). There is one library per condition,
so residual df = 0 and BARCS uses the no-replicate path, pooling rho across the
200 control guides. These are screening-level calls: replicate metastasis
libraries were not measured. A secondary IgG_vs_cell fit gives the
metastasis-vs-input axis. Composition is mild (top 1% hold 8-15% of reads), so
library totals are used; control calibration is clean (1% of controls at p<0.05).

## Agreement
The headline hit OPG (Tnfrsf11b) ranks #10 of 1,212 enriched genes in BARCS,
matching the paper's MAGeCK positive rank of 8. Spearman correlation between the
BARCS enrichment score and the paper's MAGeCK pos|score is 0.73, with 96% effect-
direction agreement and growing top-N overlap (Jaccard 0.35 at top 100). So BARCS
reproduces the paper's candidate ranking closely.

Neither method reaches statistical significance: BARCS calls 0 genes at FDR 0.10,
and in the paper's own MAGeCK OPG has pos|fdr ~0.93. With a single library per
condition the screen is underpowered for a formal call, so OPG was a top-ranked
candidate that the paper then validated by orthogonal experiments rather than an
FDR-significant screen hit. BARCS agrees on that ranking.

## Differences and limits
Top-20 disagreements (e.g. Gabrg2, Axl high in BARCS; Dck, Fgf4 high in MAGeCK)
reflect the different test statistics (BARCS beta-binomial Wald with pooled rho vs
MAGeCK RRA permutation) applied to an unreplicated two-library contrast, where
rankings below the very top are noisy. Limits: one library per condition (no
residual df, screening-level); technical re-reads summed; mild composition shift.
