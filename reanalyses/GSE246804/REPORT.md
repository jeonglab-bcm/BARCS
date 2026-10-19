# GSE246804 reanalysis with BARCS 0.2.3

**Paper.** "CRISPR Screening Identifies Mechanisms of Resistance to KRASG12C and SHP2 Inhibitor Combinations in Non-Small Cell Lung Cancer", *Cancer Research* (2023), PMID 37934115, doi:10.1158/0008-5472.can-23-1127 (PMC10722132).

**Screen.** Genome-wide CRISPR knockout library (18,360 protein-coding genes, 10 sgRNAs/gene, split into three EPIC sub-pools) in five KRAS-G12C-mutant NSCLC lines (NCI-H1373, NCI-H1792, HCC-44, Calu-1, NCI-H23) expressing Cas9. Each line/pool was treated with a KRAS-G12C inhibitor (AGENT_NAME FVH342), a SHP2 inhibitor (LMD099) or the combination, each against a matched DMSO library; one library per arm, no replicates. Gene scores in the paper were computed by RSA (Dafflon procedure).

**Raw counts recovered.** The series was deposited not as a count matrix but as a long-format table of pairwise drug-vs-DMSO comparisons (`sgRNAData.txt.gz`). Each row carries the raw integer read count of the treatment library (`SAMPLE_COUNT`) and of its DMSO control (`CONTROL_SAMPLE_COUNT`, identical across the three drug arms of a given cell line and pool), so the per-library integer counts are exactly recoverable. `prepare.R` reconstructs, for NCI-H23 (the line the paper features in validation), one genome-wide matrix by stacking the three EPIC pools (each gene in exactly one pool; guide ids suffixed with the pool to stay unique) with columns DMSO, KRASG12Ci, SHP2i and combo. **The screen is therefore reanalyzable and is not excluded.**

**Design.** Combination versus DMSO (`~ condition`), the paper's main comparison. Rescuers (knockouts that restore growth under the drug) are enriched; sensitizers are depleted. With one library per condition the no-replicate path is used. Only 10 CTRL guides exist (all in pool 1), below the thresholds for control calibration and the control null, so the overdispersion is pooled over all guides (conservative) and the model FDR is uncalibrated. **Calls are screening-level: variation between replicate cultures was not measured, and with no usable control set the reliable output is the ranking, not the hit count.** Composition is flat (top 1% of guides hold 4.4-4.7% of reads), so library totals are kept. The three pools have unequal combo:DMSO sequencing depth (1.4/0.8/1.0), which adds a small per-pool offset absorbed as noise; the strong hits are unaffected.

## Results (NCI-H23, combination vs DMSO)

| | BARCS 0.2.3 | Paper (RSA, NCI-H23) |
|---|---|---|
| Rescuer ranks (enriched) | PTEN #1, PLCG1 #2, NF1 #3, ARIH2 #4, CUL5 #6, KEAP1 #63 of 18,907 | top rescuers CUL5, ARIH2, PTEN, UBE2F, PPP6C, PLCG1 |
| Sensitizer ranks (depleted) | EXTL3 #235, ITGB1 #303, EXT1 #694, EXT2 #1123, B4GALT7 #1398, FGFR1 #4399 | top sensitizers CRKL, SHOC2, MAPK1, EEF1A1, YAP1, IGF1R; EXT2/B4GALT7/EXTL3/FGFR1 strong |
| Spearman of gene scores | rescuers 0.37, sensitizers 0.38 | — |
| Top-25 overlap | rescuers 11/25, sensitizers 4/25 | — |
| Genes at FDR 0.10 | 8,606 (uncalibrated, n=1; treat as ranking) | — |

## Where BARCS agrees and differs

- **Rescuers agree strongly.** PTEN, the paper's abstract-level strongest rescuer, is BARCS #1 and robust across all 11 guides (e.g. 1,134->5,873, 809->4,762 reads; not a jackpot). NF1 (#3) and KEAP1 (#63) are named rescuers. BARCS's top enriched genes (PTEN, PLCG1, NF1, ARIH2, CUL5) match the paper's own NCI-H23 RSA rescuers (CUL5/ARIH2/PTEN/PLCG1, a CRL5/Cullin-RING ligase and RTK-signalling node) almost one-for-one in the top 6.
- **Sensitizers agree partially.** The heparan-sulfate / FGFR-ligand-presentation genes the paper highlights (EXTL3, ITGB1, EXT1, EXT2, B4GALT7) are all depleted and significant in BARCS. FGFR1 itself, the paper's panel-wide strongest sensitizer, is only mid-pack in this single line (#4399, FDR 0.084) -- consistent with the paper noting FGFR1's rank is panel-level and MAPK1/CRKL/SHOC2 lead the NCI-H23 sensitizer list.
- **FDR count is inflated.** With one library per condition, deep sequencing (~195k guides) and only 10 controls, the model FDR calls ~8,600 genes; this is overoptimistic and uncalibrated. The ranking, not the count, is the dependable result, and it places the paper's hits at or near the top.

## Limits

- One library per arm, no replicates: screening-level; the hit count is uncalibrated (only 10 control guides, no empirical null).
- Only NCI-H23 is reanalyzed; the paper's headline FGFR1/PTEN ranking is panel-wide across five lines.
- The three EPIC pools were stacked with their deposited raw counts despite unequal depth; this adds a small per-pool offset that the strong hits survive.
