# GSE221576 reanalysis with BARCS 0.2.3

**Paper.** Cao et al., "Resistance mechanism to Notch inhibition and combination therapy in human T-cell acute lymphoblastic leukemia", *Blood Advances* (2023), PMID 37358480, doi:10.1182/bloodadvances.2023010380 (PMC10589794).

**Screen.** DND-41 T-ALL cells expressing Cas9 were transduced with GeCKO v2 (A+B; 119,461 guides in the deposited table, 1,000 non-targeting) and treated for 21 days with DMSO, the Notch transcription-complex inhibitor CB-103, or the gamma-secretase inhibitor DAPT (GSI), three replicate cultures each, plus one time-zero library. The GEO count table is raw integer MAGeCK counts and is used as deposited; its columns map one-to-one to the GSM titles. The authors ran MAGeCK-RRA for each drug versus DMSO (Supplementary Table 1, sheets `GSIvsDMSO_gene_Fig1C1E` and `CB103vsDMSO_gene_Fig1B1D`). `prepare.R` converts those two sheets to `paper/*.tsv`.

**Design.** `~ condition`, drug vs DMSO, 3 vs 3 libraries, 4 residual df, moderated (prior df about 24). Replicate numbers are not stated to be paired across arms, so there is no replicate term. T0 is a library check and is not used. The main analysis is GSI vs DMSO, which carries the paper's headline result (PIK3R1 loss gives resistance). CB-103 vs DMSO is a second analysis (`compare_cb103.json`).

**Calibration and checks.** Non-targeting guides at p < 0.05: 5.2% (GSI) and 5.5% (CB-103), so no calibration. Composition is flat: the top 1% of guides hold 4.7-7.5% of reads. Guide correlation is 0.001 or lower. Controls sit -0.18 / -0.15 z from the targeting guides, so the control null stayed centred on the controls. It gives 508 (GSI) and 187 (CB-103) genes, more than the model's 313 and 88. The controls are mildly offset, so the model counts are the ones quoted. The top calls are not jackpots: PIK3R1, EXTL3 and SOCS1 rise 2-4 fold in all six guides and all three DAPT cultures, and CDK6 falls 5-20 fold in every guide.

## Results (GSI vs DMSO)

| | BARCS 0.2.3 | Authors' MAGeCK-RRA |
|---|---|---|
| Genes at FDR 0.10 | 313 (85 enriched, 228 depleted) | 48 (17 / 31) |
| PIK3R1 (resistance, validated) | #1, FDR 1e-18 | FDR 8e-4 (enriched) |
| CDK6 (combination target) | #8, FDR 7e-7 (depleted) | FDR 1e-3 |
| NOTCH1, DCAF7 | #19, #4 (depleted) | called |
| PCGF1, BCL11B | #6, #7 (enriched) | called |
| Paper's FDR 0.10 calls also called by BARCS | 41 / 48 | |
| Rank correlation (two-sided) | 0.45 | |
| Top-25 / top-50 overlap | 16 / 30 | |

The seven paper calls that BARCS misses (OXNAD1, PAGR1, VPS11, hsa-mir-548ak, PF4, TCEB2, LILRB5) are small or rest on uneven guides. Many of BARCS's extra 265 calls are depleted genes with consistent guides, such as the elongator complex (ELP3, ELP5, ELP4, CTU2), MTOR, PIK3CD and RAB10. These look like real GSI-specific dependencies that MAGeCK's RRA permutation floor leaves out. EXTL3, EXT1 and B4GALT7 (heparan-sulfate synthesis) are strong BARCS-enriched genes in both drug arms and are near the top of the paper's list too.

## CB-103 vs DMSO

BARCS calls 88 genes at FDR 0.10; the paper calls 16, all depleted. JAK1 (#4), NOTCH1 (#7) and IL7R (#12) are called in both. The biggest difference is PIK3R1: BARCS ranks it #1 (6/6 guides up, FDR 5e-4), but MAGeCK ranked it 147th (FDR 0.96). The paper text says PIK3R1 was "also identified as preferentially lost" under CB-103, and its validation shows PIK3R1 knockout also resists CB-103. Seven of the paper's 16 CB-103 calls are not BARCS calls, five of them microRNA or read-through loci (hsa-mir-1299, hsa-mir-1273a, hsa-mir-8086, PDP1, PF4). Rank correlation 0.39.

## Why they differ

BARCS fits a negative-binomial model to each guide with replicate-aware dispersion, moderated across guides, and combines guides by Stouffer. MAGeCK median-normalises, pools variance across conditions and ranks genes by RRA with a permutation floor. With three cultures per arm and about 200 reads per guide, BARCS has more power for genes whose six guides all move the same way, so it calls a longer list. RRA can call genes from one or two outlying guides; BARCS does not.

## Limits

Counts are the authors' processed MAGeCK counts. The replicate cultures are treated as independent. GeCKO v2 is a two-half library with low per-guide coverage (Spearman 0.6-0.7 between replicates), which limits the power for small effects.
