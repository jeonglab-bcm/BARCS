# GSE215926 reanalysis with BARCS 0.2.3

**Paper.** "Systematic characterization of the HOXA9 downstream targets in MLL-r leukemia by noncoding CRISPR screens", *Nature Communications* (2023), PMID 38016946, doi:10.1038/s41467-023-43264-5 (PMC10684515).

**Screen.** This is a dropout screen of the 229 HOXA9-bound peaks found by HA-HOXA9 ChIP-seq in SEM cells. The library has 5,718 guides over 249 elements: peaks (some split by genome build), an RPS19 coding positive control and 20 negative-control guides. It was screened in SEM-Cas9, SEM-dCas9-KRAB and MOLM13-Cas9 cells at days 0, 7 and 14, with three replicates each. GEO holds one workbook (sheet `Raw.Count.tsv`), whose columns map one-to-one to the 27 GSM titles. The authors ran MAGeCK (unpaired) for each arm's day 7 and day 14 against day 0 (Supplementary Data 2). They highlight the HOXA9-bound FLT3 distal enhancer (two peaks annotated to the neighbouring PAN3, "FLT3 Enh left/right") as a top dropout in both the Cas9 and dCas9-KRAB screens, the CDK6 intronic site (CRISPRi), and further sites near RUNX1, DCAF11, PEBP4, NDUFS8, ZCCHC7 and MAN1C1 tested by competitive proliferation.

**Design.** `~ condition`, day 14 vs day 0, 3 vs 3, for SEM-Cas9 (primary) and SEM-dCas9-KRAB. Replicate residuals show no day-0/day-14 pairing, so there is no replicate term. MOLM13 is not in the paper's supplementary MAGeCK tables and is not analysed.

**Calibration and composition.** There are only 20 negative-control guides, too few for calibration or a control null. Of these, 4 (Cas9) and 3 (dCas9) reach p < 0.05, so calibration could not be checked properly. Composition is unremarkable (top 1% of guides hold 4.6-4.9% of reads). Residual df 4, moderation applied, guide correlation 0.002 and 0.008.

## Results

| | BARCS 0.2.3 (Cas9 / dCas9-KRAB) | Paper MAGeCK (Cas9 / dCas9-KRAB) |
|---|---|---|
| Elements at FDR 0.10 | 100 (35 depleted, 65 enriched) / 48 (8 depleted, 40 enriched) | 15 / 9 depleted (neg FDR < 0.1) |
| RPS19 (positive control) | **#1, FDR 1e-235** / #6, FDR 2e-4 | #1 / - |
| FLT3 enhancer left (pkscore157:PAN3) | **#2, FDR 2e-43** / **#2, FDR 4e-28** | #2 / #2 |
| FLT3 enhancer right (pkscore264:PAN3) | **#4, FDR 8e-23** / enriched | #4 / - |
| CDK6 intron (pkscore178) | slightly enriched (+0.045) / **#1, FDR 1e-42** | not depleted / #1 |
| RUNX1, DCAF11, NDUFS8 | **depleted, FDR 0.014, 0.013, 0.007** / **#5, #7, #4, FDR <= 3e-4** | |
| PEBP4, ZCCHC7 (pkscore465) | **#8, #11, FDR <= 4e-6** / not called | |
| MAN1C1 | not called / #12 by depletion, FDR 0.23 | |

Rank correlation with the authors' MAGeCK `neg|rank` is 0.76 (Cas9) and 0.67 (dCas9). In the Cas9 screen, 9 of the top 10 depleted elements are shared; in the dCas9 screen, 8 of 10.

## Where BARCS agrees and differs

- **Agrees.** All of the paper's main noncoding hits pass FDR 0.10 in the screen where the paper found them. The FLT3 distal enhancer is the top element after RPS19 in both modalities, CDK6 is the top CRISPRi element, and RUNX1, DCAF11, NDUFS8, PEBP4 and ZCCHC7 are depleted. MAN1C1, tested by the authors in Cas9 cells, is the only named site that BARCS does not support (FDR 0.94 in Cas9).
- **More depleted calls.** BARCS calls 35 and 8 depleted elements, against MAGeCK's 15 and 9. With 20-60 guides per element, Stouffer combination of guide tests gives power to small, consistent shifts (median depletion of called elements is about -0.09 log).
- **Enriched calls are probably inflated.** About 65 Cas9 and 40 dCas9 elements are called as enriched, with effects of only +0.06 to +0.11. Part of this is composition: strong depletion of RPS19 and the FLT3 enhancer raises every other element under library-size totals. With median-ratio totals, 49 and 8 remain enriched (93 and 23 elements in total). Part is the near-Poisson dispersion of this deep, small library, which the 20 controls cannot check (15-20% of them at p < 0.05). Read the enrichment side as unconfirmed. The paper reports essentially none (MAGeCK pos FDR < 0.1: 0 and 1).

## Limits

The paper's 1,800-peak primary screen is not deposited, so this is the 229-peak follow-up. There are too few non-targeting guides to calibrate. The paper's table is taken from Supplementary Data 2 (`prepare.R`), where the day-14 Cas9 values are rounded to two decimals, so the comparison uses MAGeCK's rank.
