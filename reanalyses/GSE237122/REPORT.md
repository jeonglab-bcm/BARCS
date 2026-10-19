# GSE237122 reanalysis with BARCS 0.2.3

**Paper.** "Betacoronaviruses SARS-CoV-2 and HCoV-OC43 infections in IGROV-1 cell line require aryl hydrocarbon receptor", *Emerging Microbes & Infections* (2023), PMID 37672505, doi:10.1080/22221751.2023.2256416 (PMC10512916).

**Screen.** Genome-wide Brunello CRISPR knockout library (77,441 guides, 19,113 genes, 1,000 non-targeting controls) in human IGROV-1 ovarian carcinoma cells. An unselected pool was challenged with HCoV-OC43 or SARS-CoV-2, and the surviving (resistant) cells sequenced. One library per condition (uninfected, OC43, SARS-CoV-2); no replicates. This is a positive-selection screen for host dependency factors: a protective knockout is enriched among the survivors.

**Design.** Two analyses, each the infected library versus the unselected pool, reading the enriched term (`~ condition`). With one library per condition the no-replicate path pools the overdispersion over the 1,000 non-targeting guides (inflation 118 for SARS-CoV-2, 165 for OC43 at rho = 0) and tests each guide against the normal. **Calls are screening-level: variation between replicate infected cultures was not measured.** The deposited count file is used unchanged; `prepare.R` builds only the paper's MAGeCK gene tables (Supplementary Table 4) for the comparison.

**Checks.** Non-targeting guides at p < 0.05 are 1.0% (SARS-CoV-2) and 1.7% (OC43), so BARCS is conservative and no control calibration was triggered. Controls sit within 0.08 z of the targeting guides. The infected libraries are strongly bottlenecked (top 1% of guides hold 15% of SARS-CoV-2 and 27% of OC43 reads, versus 6% unselected) because only resistant clones survive; median-ratio totals give an essentially identical ranking (ACE2, AHR top for SARS-CoV-2; AHR, EXT1 top for OC43), so library totals are kept.

## Results

| | SARS-CoV-2 | HCoV-OC43 |
|---|---|---|
| BARCS genes at FDR 0.10 | 1 (ACE2) | 0 |
| BARCS genes at empirical FDR 0.10 | 0 | 0 |
| Paper (MAGeCK pos) at FDR 0.10 | 2 (ACE2, AHR) | 6 (CCDC101, EXT1, EXT2, ADIPOQ, SLC35B2, CYLC2) |
| Named hit ranks in BARCS | ACE2 #1, AHR #2 of 19,049 | AHR #1, EXT1 #2, EXT2 #6, SLC35B2 #8 of 19,040 |
| Spearman of gene scores | 0.71 | 0.69 |
| Effect-direction agreement | 95.9% | 96.6% |
| Top-200 overlap | 67/200 | 81/200 |

## Where BARCS agrees and differs

- **Every named hit is at the very top of the BARCS ranking.** ACE2 (the SARS-CoV-2 entry receptor and the paper's positive control) is BARCS #1; AHR, the paper's headline shared pro-viral factor, is #2 for SARS-CoV-2 and #1 for OC43; the heparan-sulphate entry genes EXT1, EXT2 and SLC35B2 are #2, #6 and #8 for OC43. The paper reported AHR ranking 2nd for SARS-CoV-2 and ~50th for OC43; BARCS places it even higher in OC43.
- **FDR is more conservative than the paper's.** With one library per condition and a large pooled overdispersion, each large effect also has a large standard error, so BARCS clears only ACE2 at FDR 0.10 and the control null confirms nothing. The paper's MAGeCK RRA with four guides per gene and permutation p-values calls AHR (FDR 0.09) and, for OC43, six genes. The two methods rank the same genes; they draw the significance line differently.
- **AHR in OC43 is partly a single-guide effect.** Of AHR's four guides, one (HGLibA_00543) jumps from 523 reads unselected to 8,043 in OC43 while the others move little; AHR's OC43 enrichment leans on that guide. Its SARS-CoV-2 signal and ACE2 (all four guides up, 175-803 to 2,413-4,989) are guide-consistent.

## Limits

- One library per condition, large overdispersion from the survival bottleneck: the screen resolves the paper's top genes by rank but cannot confirm most at the gene level without replicate infections. The result is screening-level.
- The comparison uses the paper's deposited MAGeCK gene_summary tables (Supplementary Table 4); directions and the pos-selection score match the paper's own analysis.
