# GSE244434 reanalysis with BARCS 0.2.3

**Paper.** "Active growth signaling promotes senescence and cancer cell sensitivity to CDK7 inhibition", *Molecular Cell* (2023), PMID 37977119, doi:10.1016/j.molcel.2023.10.017 (preprint doi:10.1101/2021.09.10.459733).

**Screen.** A chemogenetic genome-wide knockout screen in NALM-6 cells with the EKO library (192,613 guides in the deposited table, 2,041 non-targeting). Cells were treated with samuraciclib (ICEC0942, 0.35 uM, about IC30) for 8 days. GEO deposits only two count columns: the single samuraciclib library and `Combined_controls`, the sum of all 16 control libraries (DMSO, ethanol, untreated, spinner-flask day 0-8). This summed reference is exactly what the paper's modified RANKS scoring used. The paper reports pathways rather than a gene table: in the preprint, the top 20 positive interactors (guides enriched under drug, so loss gives resistance) were enriched for "TOR signalling" and "positive regulation of TOR signalling", and the top 20 negative interactors for "negative regulation of TOR signalling". Neither the Molecular Cell supplement nor the preprint gene lists could be retrieved (publisher and bioRxiv pages refused automated access), so no published gene table is compared.

**Design.** `~ condition`, samuraciclib vs combined controls, one library per arm, so the no-replicate path was used. The overdispersion was pooled over 2,039 non-targeting guides (rho = 2.7e-7), and each guide was tested at that value. These calls are screening-level, because variation between replicate cultures was not measured. The control arm is a sum of 16 libraries (271 M reads, against 11 M for the drug library), so its sampling noise is small, but its composition mixes time points.

**Calibration and composition.** 0.7% of non-targeting guides reach p < 0.05, so the model is conservative on the controls and no calibration was applied. The top 1% of guides hold 4.3% and 4.1% of reads, so composition is unremarkable. Against pseudo-genes built from the controls (centred on the controls, control shift -0.05 z), 372 genes pass FDR 0.10. That count is larger than the model's 47 because the model is conservative on the controls. Top calls are carried by 8-10 of 10 guides in the same direction, with no jackpots.

## Results

| | BARCS 0.2.3 | Paper (RANKS vs summed controls) |
|---|---|---|
| Genes at FDR 0.10 | 47 (27 enriched under drug, 20 depleted); 372 against the control-guide null | top 20 per direction, GO-enriched for TOR signalling |
| MLST8 (mTORC1/2) | **#1 overall, enriched, FDR 2.5e-8** | positive regulators of TOR among positive interactors |
| MAPKAP1 / RICTOR (mTORC2) | **#4 and #16, enriched, FDR 8e-6 and 0.005** | |
| NPRL3 / DEPDC5 (GATOR1) | **depleted, FDR 0.019 and 0.052** | negative regulators of TOR among negative interactors |
| TSC2 | **depleted, FDR 0.085** | |
| NPRL2 / TSC1 | depleted, FDR 0.18 / 1 | |
| MTOR, RPTOR, RHEB | not called | essential: guides already near absent in both arms |

## Where BARCS agrees and differs

- **Agrees.** The paper's conclusion is pathway-level: loss of positive regulators of mTOR protects from samuraciclib, and loss of negative regulators sensitizes. BARCS reproduces both halves. The shared mTORC1/2 subunit MLST8 is the strongest gene in the screen, the mTORC2 subunits MAPKAP1 (SIN1) and RICTOR are enriched, and the GATOR1 subunits NPRL3 and DEPDC5 and TSC2 are depleted at FDR 0.10.
- **Not testable.** MTOR, RPTOR and RHEB are core-essential in NALM-6. Their guides average 26-65 reads in the drug library against 58 for all guides, so a resistance effect cannot be read.
- **Other calls.** Other strong calls include ARL1, SLC5A3, GPR107 and ARMC5 (depleted, sensitizers) and SPOP, EIF4A1 and mitochondrial-translation genes (enriched). The paper does not name them.
- **Named genes are pathway members, not a published list.** The genes in the table were chosen as canonical mTORC1/2 and TSC/GATOR1 components, because the paper names the pathway, not individual genes. Treat agreement as agreement with the paper's pathway conclusion.

## Limits

One library per arm: no replicate cultures, and only the summed control is deposited, so per-condition replicates (DMSO 2, ethanol 2, untreated 2) cannot be used separately. The model's FDR is conservative on the non-targeting controls (0.7% at p < 0.05), and the control-null count (372) is the less conservative reading.
