# GSE223716 reanalysis with BARCS 0.2.2

**Paper.** Price et al., "Epigenetic control of telomeric RNA maintains heterochromatin in telomerase-driven cancers", *Signal Transduction and Targeted Therapy* 11 (2026), PMID 42236690, doi:10.1038/s41392-026-02750-0 (PMC13233980). The genome-wide screens are in GSE211312; this series holds the in vivo validation pool.

**Screen.** A sub-library of 196 guides on 98 synthetic-dosage-lethal (SDL) candidate genes, 2 guides per gene. Tumors were grown in HT1080 fibrosarcoma cells with low hTERT (HTelo−, `HT1080_*`) and with GFP-hTERT (HTelo+, `HT_TERT_*`), and in five more models (22Rv1, ES-2, HCT-15, MDA-MB-231, MIA PaCa-2). Each model has a "Wild Type" arm and a "cas9" arm, with 2 tumors each (28 libraries). Column names match the GSM titles. The paper's Fig. 2d compares HTelo+ with HTelo− tumors (t-test with permutation p-values) and names FTSJ3, MED14, RRM2, GNB1L and PRMT1 as the top SDL hits in hTERT-positive tumors. Fig. 2e shows MAGeCK RRA plots for the other five models, and the text names FTSJ3, MED14, PRMT1, GNB1L, PRPF19 and LMNB1 as recurrent hits. No gene-level table was available: the paper has no machine-readable supplement in Europe PMC.

**Caveats for this series.**
- The deposited table has **no non-targeting guides**, although the paper says non-targeting sgRNAs served as controls. Calibration and the control null cannot be checked, so every p-value here rests on the model alone.
- **The Wild Type arm is not described.** GEO and the paper do not say whether "Wild Type" tumors lack Cas9. If they do, Cas9 vs Wild Type is the cutting effect, and the HTelo line × Cas9 interaction is the cleanest SDL test. If they do not, those contrasts mean nothing. The primary analysis therefore avoids the Wild Type arm.
- The tumors are strongly clonal. 20–28% of guides are at zero in most libraries, and in some libraries the top 2 guides (1% of 196) hold 26–55% of reads. Single guides jump between a few reads and tens of thousands of reads across replicate tumors.

## Design

| Analysis | Libraries | Formula / term | Genes at FDR 0.10 |
|---|---|---|---|
| **HTelo+ cas9 vs HTelo− cas9** (primary, Fig. 2d) | 2 vs 2 | `~ line`, `lineHTelo_plus` | 8 (all depleted) |
| HTelo+ WT vs HTelo− WT (check) | 2 vs 2 | `~ line` | 0 |
| HTelo line × Cas9 interaction | 8 | `~ line * cas9` | 0 |
| Cas9 vs WT within HTelo+ | 2 vs 2 | `~ cas9` | 0 |
| Cas9 vs WT, HCT-15 | 2 vs 2 | `~ cas9` | 4 (PRMT1, FTSJ3, MCM5, BIRC5) |
| Cas9 vs WT, 22Rv1 / ES-2 / MDA-MB-231 / MIA PaCa-2 | 2 vs 2 each | `~ cas9` | 0 each |

All analyses use library totals, 2 residual df and moderated dispersion. Guide correlation is 0.02 in the primary analysis.

## Results (primary: HTelo+ vs HTelo− Cas9 tumors)

| Gene | Paper | BARCS rank (depleted, of 91) | log-odds effect | FDR |
|---|---|---|---|---|
| MED14 | top SDL hit | 3 | −3.85 | 0.029 |
| GNB1L | top SDL hit | 4 | −7.65 | 0.032 |
| RRM2 | top SDL hit | 6 | −6.47 | 0.038 |
| FTSJ3 | top SDL hit, lead gene | 9 | −3.95 | 0.12 |
| PRMT1 | top SDL hit | 17 | −2.28 | 0.35 |

BARCS's 8 calls are POLA2, GINS4, MED14, GNB1L, CGRRF1, RRM2, ARHGAP15 and PLK1.

In the Cas9 vs Wild Type contrasts, FTSJ3 is a top-ranked depleted gene in HCT-15 (rank 2, FDR 0.07), 22Rv1 (rank 2) and ES-2 (rank 4), but passes FDR 0.10 only in HCT-15. PRMT1 is rank 1 in HCT-15 (FDR 0.002).

## Where BARCS agrees and differs

- **Agrees in rank.** Four of the paper's five named HTelo hits are in BARCS's top 9 of 91 depleted genes, and three (MED14, GNB1L, RRM2) pass FDR 0.10. FTSJ3 is just above the threshold (FDR 0.12), with both guides lower in HTelo+ tumors.
- **The evidence is thin.** The raw counts behind the calls are erratic:
  - RRM2 rests on one guide (the other has under 5 reads everywhere).
  - The GNB1L call is driven mostly by a 38,190-read jackpot in one HTelo− tumor.
  - POLA2, BARCS's top gene, rests on one guide with 63 and 17 reads against 0 and 0.
- **The HTelo comparison is not Cas9-specific.** HTelo+ vs HTelo− in Cas9 tumors cannot separate SDL from differences between the two transduced pools. The line × Cas9 interaction, which would make that separation, calls nothing (FTSJ3 rank 8, FDR 0.90). The Wild Type arm is itself noisy: for example, MED14 guide 1 has 22,544 reads in one HTelo+ Wild Type tumor and 317 in the other. So whether or not Wild Type means "no Cas9", it adds variance rather than a baseline. The Wild Type-arm check (HTelo+ vs HTelo−) calls nothing, which is consistent with no cutting there, but with 2 tumors per arm it has little power.
- **Across models**, BARCS confirms FTSJ3 and PRMT1 only in HCT-15. Elsewhere it ranks FTSJ3 high but cannot separate it from tumor-to-tumor noise with 2 tumors per arm.

## Limits

- There are no controls, so calibration could not be checked.
- There are 2 tumors per arm, and the tumors are clonal.
- The meaning of the Wild Type arm is unknown.
- The paper's own test (t-test with permutation, and MAGeCK RRA per model) and its exact sample pairing are not documented in enough detail to reproduce.
