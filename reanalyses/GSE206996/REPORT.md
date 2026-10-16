# GSE206996 reanalysis with BARCS 0.2.3

**Paper.** "Whole genome CRISPR screening strategy to identify genes contributing to SARS-CoV-2 spike and VSV-G mediated entry", *Journal of Medical Virology* (2023), PMID 37707319, doi:10.1002/jmv.29087 (not open access).

**Screens.** Brunello genome-wide knockout library (77,441 guides, 1,000 non-targeting) in ACE2-expressing HEK293T cells, with a GFP/mNeonGreen reporter delivered by pseudotyped retrovirus, sorted into reporter-low (uninfected) and reporter-high cells. Three screens share the library: SARS-CoV-2 spike-mNeonGreen, VSV-G-mNeonGreen, and VSV-G-Cre (which activates a floxed GFP reporter on entry, bypassing retro-transcription and integration). Host factors needed for entry or reporter expression are enriched in the reporter-low bin. The GEO file lays the three screens side by side under two title rows; `prepare.R` splits it into one count file per screen (counts unchanged). Columns Pre/Input/Low/High match the GSM titles.

**Design.** `~ sort`, reporter-low vs high, one library per bin for each screen, so the no-replicate path pools the overdispersion over the ~1,000 non-targeting guides; calls are screening-level. The presort and plasmid libraries are not used.

**Checks.** Calibration is clean (non-targeting guides at p < 0.05: 4.7% / 4.8% / 6.2%). Composition is flat (top 1% of guides hold 3.5-4.5% of reads). Controls sit within 0.14 z of the targeting guides, so the control nulls are centred on the controls.

## Results

| Screen | BARCS at FDR 0.10 | Positive control |
|---|---|---|
| Spike-mNeonGreen | 30 genes (28 control null); top ACE2, SIK2, SERPINA4, IQGAP1, ARPC4 | ACE2 #1, FDR 6e-10; SLC35B2 #5 |
| VSV-G-mNeonGreen | 13 genes (21 control null); top EP300, SLC35B2, HSP90B1 | LDLR #9 (FDR 0.09); SLC35B2 #2 |
| VSV-G-Cre | 28 genes (46 control null); top EXOSC1, SLC35B2, HSP90B1, PIK3C3 | LDLR #10, FDR 2e-9; SLC35B2 #3 |

## Where BARCS agrees with the paper

- **Receptors separate exactly as designed.** ACE2, the spike receptor, is #1 in the spike screen and ranks 129th / 17,709th in the two VSV-G screens. LDLR, the VSV-G receptor, is a top-10 enriched gene in both VSV-G screens and non-significant (#532) in the spike screen. This is the differential result the paper built the counter-screens to produce.
- **Shared entry machinery.** SLC35B2 (heparan-sulfate biosynthesis) is a top-5 hit in all three screens, as expected for a factor common to retroviral entry and reporter expression; HSP90B1 and other trafficking genes recur in the VSV-G screens.

## Limits

- One library per bin and no replicates: the FDR rests on the control-pooled overdispersion and the calls are screening-level.
- The paper is not open access, so no gene-level MAGeCK table was retrieved; the comparison uses the paper's named receptors (ACE2, LDLR) and the shared factor SLC35B2.
