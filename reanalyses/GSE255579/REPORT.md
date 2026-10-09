# GSE255579 reanalysis with BARCS 0.2.2

**Paper.** "EXO1 as a therapeutic target for Fanconi Anaemia, ZRSR2 and BRCA1-A complex deficient cancers", *Nature Communications* (2025), PMID 41006228, doi:10.1038/s41467-025-63349-7 (PMC12475092). This series holds the rescue screens. The headline synthetic-lethal dropout screen (EXO1 knockout vs wild type) is in a separate series, GSE255664, and is not reanalyzed here.

**Screen.** A Brunello library (77,441 guides, 1,000 non-targeting) in eHAP iCas9 EXO1-knockout cells, transduced in triplicate. Each replicate was then split into three arms carrying a second sgRNA: non-targeting (NT), FANCG (FG) or ZRSR2 (ZR). Both FANCG and ZRSR2 are synthetic lethal with EXO1. Cells were collected 10 days after Cas9 induction. Knockouts that make the double knockout more tolerable, i.e. rescue genes, are enriched in the FG or ZR arm relative to NT. The authors deposited a gene-level MAGeCK `test` table for each comparison (Supplementary Data 4 and 5).

**Design.** `~ replicate + condition`, 6 libraries, 2 residual df. Primary analysis: FG vs NT. Second analysis: ZR vs NT. The three arms of one replicate correlate most strongly with each other (0.56–0.69, against 0.40–0.53 across replicates), and the methods describe a split from one transduced culture. Replicate is therefore a blocking term. Composition is normal: the top 1% of guides hold 4.5–5.7% of reads.

**Calibration.** FG vs NT: 14.4% of non-targeting guides reached p < 0.05, so the test was calibrated to them (4.9% after). ZR vs NT: 6.6%, no calibration. In both arms the control guides sit lower than the targeting guides: their median guide z is −0.74 (FG) and −0.28 (ZR), against about 0 for targeting guides. Non-cutting controls are not exchangeable in location with cutting guides in this screen. Centred on the controls, the pseudo-gene null called 6,081 and 230 genes, an artifact of that offset. Centred on the targeting guides (as `run_barcs.R` now does when the offset exceeds 0.25 z), it calls 467 (FG) and 16 (ZR). In FG it supports TYMS (FDR 0.018) and GINS2 (0.023), the paper's two strongest hits, but not CDC6, SMC5 or RRM1 (0.12–0.27). The agreement label rests on the model FDR.

## Results

| | FG vs NT (BARCS) | FG vs NT (authors' MAGeCK) | ZR vs NT (BARCS) | ZR vs NT (authors' MAGeCK) |
|---|---|---|---|---|
| Genes at FDR 0.10 (enriched) | 27 | 18 | 18 | 0 (lowest FDR 0.31) |
| GINS2 | #82, FDR 0.21 | rank 4, FDR 0.04 | #394, FDR 0.59 | rank 55, FDR 0.49 |
| TYMS | **#23, FDR 0.098** | rank 10, FDR 0.10 | #397, FDR 0.59 | rank 107, FDR 0.70 |
| CDC6 | #342, FDR 0.46 | rank 40, FDR 0.14 | #845, FDR 0.71 | rank 14, FDR 0.31 |
| RRM1 | #929, FDR 0.72 | rank 41, FDR 0.14 | #490, FDR 0.63 | rank 22, FDR 0.41 |
| SMC5 | #798, FDR 0.69 | rank 376, FDR 0.43 | #352, FDR 0.56 | rank 291, FDR 0.82 |
| Rank correlation with MAGeCK | 0.68 | | 0.59 | |
| Top-100 overlap with MAGeCK | 40 | | 26 | |

## Where BARCS agrees and differs

- **Agrees.** All five named rescue genes have positive effects in both arms. In FG vs NT, TYMS passes FDR 0.10; it is the gene the paper went on to validate with pemetrexed. The overall ranking agrees well with the authors' MAGeCK (Spearman 0.68). Most calls in both analyses are core-essential genes: proteasome (PSMA2, PSMA5, PSMB5), ribosome (RPL27, RPL10, RPS16), splicing (SF3B4, LSM10). Their knockouts drop out less in the slower-growing double-knockout arms, and the authors' top lists show the same pattern.
- **Weaker for the replication genes.** GINS2, CDC6, RRM1 and SMC5 do not pass. They are essential, so their guides are sparse and erratic in the NT arm. For example, RRM1 guides have 0–172 reads across the NT libraries and 0–274 across the FG libraries. The direction is positive, but replicates disagree in size by orders of magnitude. BARCS's replicate-aware variance treats that as noise, where MAGeCK's comparison of means does not. In the authors' own table only GINS2 and TYMS reach FDR 0.10 for FANCG, and none of the five reaches it for ZRSR2. "Identified as rescue genes in both screens" rests on ranks, not significance.
- **Single-guide calls.** Several top BARCS calls rest on one guide with a clonal jackpot. CTAGE6, the #1 gene in FG vs NT, has one guide at 59,690 reads in FG_3 against 1,023 in NT_3. In ZR vs NT, GPR75, PUM2, EIF2B2 and PPP4R4 have one guide with z > 7 and the rest near 0. These should be discounted.
- **ZRSR2 in its own arm.** ZRSR2 is called in ZR vs NT (#4, FDR 0.009) because one Brunello guide is 3–8× higher in each ZR library than in the matching NT library. That is probably carry-over of the arm's own ZRSR2 sgRNA (*inferred*), not biology.

## Limits

- Only the rescue screens are in this series. The paper's main dropout screen is in GSE255664.
- Three replicates per arm (2 residual df). Essential-gene guides are sparse, so the rescue signal for replication genes is noisy.
- Non-targeting controls are offset from targeting guides, so the control-pseudo-gene null is not usable here.
