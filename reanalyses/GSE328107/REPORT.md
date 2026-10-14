# GSE328107 reanalysis with BARCS 0.2.3

**Paper.** "PI3K Regulates Wild-type RAS Signaling to Confer Resistance to KRAS Inhibition", *Cancer Research* 2026, PMID 42095550 (PMC13237827).

**Why it was excluded before.** Only MAGeCK-normalized counts were deposited, not raw reads.

**Count recovery.** `GSE328107_screen.count_normalized.txt.gz` is raw reads times one constant per sample (MAGeCK median normalization, unrounded). x / s is an integer (within ~1e-12) for 100.0% of positive values at s = v_min (k = 1) in all seven columns. Recovered integers in `recovered_counts.tsv`; totals 23-31 M reads.

**Screen.** Genome-wide Brunello KO (~77.4k guides, 1000 non-targeting) in PaTu-8988T PDAC pools, KRAS-intact vs KRAS-KO clones, sampled at D4/D8 and a final 14-population-doubling time point (D22 intact, D32 KO).

**Design.** The paper ran `mageck test` on the final time point vs D4 per genotype, normalized to non-targeting controls. Reproduced as two analyses, final vs D4 with control totals. One library per condition, so BARCS uses the no-replicate path (overdispersion pooled across 1000 non-targeting guides; the calls are screening-level because variation between replicate cultures was not measured).

## Results
- **KRAS-KO, D32 vs D4:** 106 genes at FDR 0.10 (47 against the control null). The two RAS-GAPs the paper highlights as enriched in KRAS-deficient cells are the top two genes: **NF1 #1** (FDR 4e-63) and **RASA2 #2** (FDR 2e-49).
- **KRAS-intact, D22 vs D4:** **KRAS is depleted** (rank 1202 by p, FDR 2e-7) as the paper reports for intact cells, and PI3K/MAPK-pathway genes (PTPN11, MAPK1, SHOC2, SOS1, EGFR, PIK3CA) are also depleted, matching Fig. 4G/H. The intact null count is inflated (8,876 at model FDR 0.10) because one library per condition with control totals over-calls depletion; the empirical/control-null count (2,826) and the named genes are the interpretable signal.

## BARCS vs paper
Strong agreement on the paper's main claims: NF1 and RASA2 enriched in KRAS-KO (ranks 1-2), KRAS and RAS/MAPK effectors depleted in KRAS-intact. Differences are in list length, driven by the no-replicate design.

## Limits
One library per condition (screening-level). Control totals as in the paper amplify depletion calls in the intact arm; read enrichment and the named genes rather than the raw FDR-0.10 count there.
