# GSE287048 reanalysis with BARCS 0.2.3

**Paper.** "Discrete vulnerability to pharmacological CDK2 inhibition is governed by heterogeneity of the cancer cell cycle", *Nature Communications* 2025, PMID 39924553 (PMC11808123).

**Screens.** TKOv3 knockout library (71,090 guides, 4 per gene; 142 LacZ/EGFP/luciferase control guides) grown for 8 passages with or without the CDK2 inhibitor INX-315 (500 nM, "ARC-500" in the sample names). HCC1806: two DMSO and two INX-315 cultures, plus P0. MIA PaCa-2: one control and one INX-315 library at P8, plus P1 and palbociclib.

**Counts.** Raw integer guide counts deposited per screen (`GSE287048_HCC1806-INX315.count.txt.gz`, `GSE287048_MIA-PaCa-TKOv3.count.txt.gz`), used as is. Column names equal the GSM titles, so the mapping is certain.

**Design.**
- `inx315_vs_dmso` (main): HCC1806 INX-315 vs DMSO, `~ condition`, 2 vs 2 cultures (not paired), 2 residual df.
- `inx315_vs_dmso_noR1` (sensitivity): DMSO culture R1 is an outlier (Spearman 0.47 with every other library versus 0.88-0.95 among the rest, 4.8% zero guides, top-1% read share 10.5% vs 4%). Dropping it leaves 1 DMSO vs 2 INX-315 libraries (1 residual df).
- `miapaca_inx315_vs_control` (`design_miapaca.json`): MIA PaCa-2, one library per arm. The no-replicate path pools the overdispersion over the 142 controls, so calls are screening-level.

## Results

| Analysis | Genes at FDR 0.10 | Control null | Control p<0.05 |
|---|---|---|---|
| HCC1806, 2 vs 2 | 3 (CDK2 enriched; CCNB1, FOXM1 depleted) | 188 | 0% |
| HCC1806 without DMSO R1 | 347 (61 enriched, 286 depleted) | 331 | 17.3% raw, calibrated to 5.0% |
| MIA PaCa-2, 1 vs 1 | 6 (all enriched) | 24 | 3.5% |

With the outlier DMSO culture included, the residual variance is inflated. No control guide reaches p < 0.05, so the 2 vs 2 model is conservative. The control null, built from only 142 controls, admits 188 genes. Dropping R1 gives a hit list that the control null supports (331 genes).

## BARCS vs paper

The paper ran DrugZ (Supplementary Data 2) and names CDK2 loss as the mediator of resistance to INX-315. Its HCC1806 calls at FDR 0.10 are CDK2 and DYRK1A enriched and 55 genes depleted (synthetic, led by CCNB1, FOXM1 and MTR). Its MIA PaCa-2 calls are 6 enriched genes.

- **CDK2** is BARCS's top enriched gene in HCC1806 (FDR 0.048; 2.4e-10 without R1) and ranks 3rd in MIA PaCa-2 (FDR 5e-05).
- **HCC1806**: gene scores correlate with DrugZ normZ at Spearman 0.94. The top-20 lists share 14 genes on the enriched side and 16 on the depleted side. DYRK1A ranks 2nd enriched (FDR 0.26 in the 2 vs 2 model, 5e-08 without R1). CCNB1, FOXM1 and MTR are BARCS's top 3 depleted genes. Without R1, 47 of the paper's 55 synthetic genes pass FDR 0.10.
- **MIA PaCa-2**: BARCS calls exactly the paper's six enriched genes (LCMT1, CELF1, CDK2, AMBRA1, PPP2R2A, KIDINS220); Spearman 0.93.

## Limits

HCC1806 has two cultures per arm, and one DMSO culture looks bottlenecked or mislabelled (CDK2 guides at ~20 reads versus ~300 in R2). The 2 vs 2 model therefore calls few genes, and the sensitivity run without R1 has 1 residual df. MIA PaCa-2 has one library per arm (screening-level).
