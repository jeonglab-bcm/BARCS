# GSE284239 reanalysis with BARCS 0.2.3

**Paper.** "Characterization of TNG348: A Selective, Allosteric USP1 Inhibitor That Synergizes with PARP Inhibitors in Tumors with Homologous Recombination Deficiency", *Molecular Cancer Therapeutics* 2025, PMID 39886906 (PMC12046316).

**Screens.** Cas9 cells grown 10 population doublings in DMSO, the USP1 inhibitor TNG348 or olaparib. DNA-damage-response library (1,145 genes, ~6 guides each, 594 non-targeting) in BRCA1-mutant UWB1.289 (DMSO, TNG348 200 nM, olaparib 1 uM) and MDA-MB-436 (two DMSO cultures, TNG348 100 nM, olaparib 10 nM); genome-wide library in TNG348-resistant COV362 and HCC1395 (DMSO, TNG348 500 nM each).

**Counts.** GEO holds one file per sample listing reads per guide and lineage barcode (`umi_barcode`). `prepare.R` sums reads over barcodes per guide and merges the samples of each library (`counts_ddr.tsv`, 7,825 guides; `counts_gw.tsv`, 76,741 guides). Libraries are deep (84-259 M reads). Column-to-sample mapping is certain (one file per GSM).

**Design.**
- `uwb_tng348_vs_dmso` and `uwb_olaparib_vs_dmso`: one library per arm, so the no-replicate path pools the overdispersion over the 594 non-targeting guides. Calls are screening-level: variation between replicate cultures was not measured.
- `mda_tng348_vs_dmso`: two DMSO cultures vs one TNG348 culture, 1 residual df.
- `gw_tng348_vs_dmso` (`design_gw.json`): `~ line + condition` over COV362 and HCC1395, so each TNG348 library is paired with its own DMSO and the TNG348 effect shared by the two lines is tested with 1 residual df (between-line variation acts as replicate variation).

## Results

| Analysis | Genes at FDR 0.10 | Control null | Control p<0.05 |
|---|---|---|---|
| UWB1.289 TNG348 vs DMSO | 3 (all enriched: RB1, RAD18, E2F7) | 6 | 3.9% |
| UWB1.289 olaparib vs DMSO | 3 (E2F7, RB1, CTC-534A2.2) | 3 | 3.7% |
| MDA-MB-436 TNG348 vs DMSO | 10 (all enriched; UBE2A, RAD18, UBE2K top 3) | 9 | 36.7% raw, calibrated to 5.0% |
| COV362 + HCC1395 TNG348 vs DMSO | 102 (75 enriched, 27 depleted) | 65 | 6.0% |

Composition is normal (top 1% of guides hold 4-13% of reads). Guide correlation is at most 0.02. The control null is centred on the controls in every analysis, with shifts below 0.07 z. The MDA-MB-436 analysis was calibrated to the controls because the two DMSO cultures agree more closely than either agrees with the TNG348 culture; that calibration shortens its hit list. Top hits are carried by all or most guides at tens of thousands of reads, so there are no jackpot calls.

## BARCS vs paper

The paper's tables (S5-S10) give a per-gene `wtheta` (0.5 = no change) and p-value for every screen, and the paper reads hits at p < 0.05 (90-360 genes per direction and screen).

- **RAD18** (resistance via loss of PCNA ubiquitination, the paper's main mechanism): FDR 0.0013 in UWB1.289 (rank 2), 1e-06 in MDA-MB-436, 1e-10 in the pooled genome-wide screens. **UBE2A and UBE2K** are BARCS's top-3 calls in MDA-MB-436 with RAD18 (FDR < 1e-4); in UWB1.289 they rank 26 and 96 without reaching FDR 0.10. RFWD3 ranks 16-52 without reaching FDR 0.10.
- **PARP1** sensitizes cells to TNG348 in the genome-wide screens: rank 6 depleted, FDR 0.001. In UWB1.289 its effect points the same way (-1.26) but is not significant on one library per arm (paper p = 7e-5). Under olaparib, PARP1 loss enriches (rank 21, p = 0.07; paper p = 1.4e-5).
- **BRCA1-A complex** loss sensitizes cells in the genome-wide screens, as the paper reports: UIMC1 (FDR 6e-4), BRCC3 (0.009) and BRE (0.02) are called; BABAM1 and FAM175A are not.
- Rank agreement with the published tables: Spearman 0.64 (UWB1.289 TNG348), 0.65 (UWB1.289 olaparib), 0.68 (MDA-MB-436 TNG348). In the top 20 enriched genes, 12 (UWB1.289) and 15 (MDA-MB-436) are shared.
- Genome-wide, BARCS tests the effect shared by COV362 and HCC1395, while the paper analysed each line alone, so ranks agree less (Spearman 0.31 with COV362, 0.27 with HCC1395). The HCC1395 paper table has few strong genes (26 at p < 0.001); its top-ranked genes include a cutting control, which suggests noise.
- BARCS-only enriched genes: RB1, CDKN2A and E2F7 rise under both drugs (cell-cycle checkpoint loss, likely faster growth under drug stress). CHD2, DYNLL1, ATMIN and TADA2B are strong genome-wide.

## Limits

UWB1.289 has one library per arm and MDA-MB-436 has one TNG348 library, so those calls are screening-level. The paper's p-values come from a per-screen method on single libraries and are much more liberal: hundreds of genes reach p < 0.05. The genome-wide analysis pools two cell lines, so it finds genes shared by both lines rather than line-specific ones.
