# GSE275314 reanalysis with BARCS 0.2.3

**Paper.** "RAS-GTP Inhibition Overcomes Acquired Resistance to KRASG12C Inhibitors Mediated by Oncogenic and Wild-Type RAS Activation in Non-Small Cell Lung Cancer", *Cancer Research* (2026), PMID 41165456, doi:10.1158/0008-5472.CAN-25-0600, PMC12962340 (full text read from PMC; no gene-level screen table is published). The kinome screen is one part of the paper (Fig. 6F): it asks which kinases sotorasib-resistant NCI-H358 cells (H358-AMGR, the EMT model) newly depend on.

**Series and counts.** `GSE275314_counts_mat.csv.gz` holds integer counts for the Addgene #75314 human kinome library (3,149 guides on 763 genes, 4 per gene, 100 `NonTargetingControl` guides). Column names match the GSM titles: `Ref1` = parental T0 reference, `Ref2` = AMGR T0 reference, `H358R1T1`/`H358R2T1` = parental cells after 2 weeks in DMSO (2 replicate cultures), `AMGR1T1`/`AMGR2T1` = AMGR cells after 2 weeks on sotorasib (2 replicate cultures). Libraries hold 1.7-3.9 M reads; the top 1% of guides hold 3.3-3.9% of reads (no clonal takeover).

## Design

The paper "analyzed depleted sgRNAs in sotorasib-R NCI-H358 cells compared to reference or parental cells" and highlights both kinases more depleted in AMGR than parental (ILK, PTK2, ROCK2, FASTKD3, CDK15, RAB11FIP5) and kinases whose knockout hurt parental cells more (EGFR, MAPK1). That is the end-point comparison, so the primary analysis is **AMGR T1 vs parental T1, ~ line, 2 vs 2** (residual df 2). A second analysis fits `~ line * time` with each line's single T0 reference, so the interaction asks whether a knockout drops out more in AMGR than in parental cells relative to each line's own starting library (residual df 2, one T0 library per line). Replicate cultures are not paired across lines, so no replicate term. Note that the two arms also differ in drug (DMSO vs sotorasib), as in the paper.

## Results

| Analysis | Raw control p<0.05 | Genes FDR 0.10 (model) | Control null | Control shift |
|---|---|---|---|---|
| AMGR vs parental, T1 | 23% (calibrated to 5%) | 4 (2 up, 2 down) | 4 | 0.14 z |
| line x time interaction | 15% (calibrated to 5%) | 2 (both up) | 5 | 0.11 z |

Control calibration was applied in both analyses (the raw non-targeting rate exceeded 7.5%), which shortens the hit list. Guide correlation 0; 13 guides switched to the likelihood-ratio test.

**Agreement with the paper.** BARCS's top ten by p value contains all eight genes the paper calls differential, every one with all four guides in the paper's direction: MAPK1 #1 (FDR 3.5e-7) and EGFR #2 (FDR 6e-4) less essential in AMGR; ROCK2 #3 (FDR 0.021), CDK15 #4 (FDR 0.057), FASTKD3 #5 (0.17), RAB11FIP5 #6 (0.18), PTK2 #7 (0.44), ILK #10 (0.50) more depleted in AMGR. Only MAPK1, EGFR, ROCK2 and CDK15 pass FDR 0.10; with two replicates per arm and a 23% raw control rate, the calibrated test cannot confirm the weaker four. The interaction analysis gives the same picture (EGFR and MAPK1 at FDR 0.10; PTK2, ILK, ROCK2 next).

**Where BARCS differs.** The paper's lead finding, "depletion of sgRNAs targeting cell-cycle checkpoint kinases (PLK1, ATR, CHEK1, CDK1)", is not differential in these counts. PLK1, CDK1 and CHEK1 (one guide) drop out relative to the T0 references in **both** lines, slightly more in parental cells (BARCS estimates for AMGR vs parental: CDK1 +0.90, p 0.10; PLK1 +0.66, p 0.33; CHEK1 0.00; ATR +0.32, p 0.91). They are pan-essential depletions against the reference, not acquired AMGR dependencies; the paper's "compared to reference or parental cells" wording appears to combine both kinds of comparison.

## Limits

Two replicate cultures per arm and a single T0 library per line; the paper's own analysis method and gene table are not given, so the comparison uses the genes named in the text. FDR is BARCS's model FDR after calibration to 100 non-targeting guides; the control null (4 genes) agrees with it.
