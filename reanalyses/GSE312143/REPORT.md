# GSE312143 reanalysis with BARCS 0.2.3

**Paper.** "In vivo CRISPR screening identifies SAGA complex members as key regulators of hematopoiesis", *Nature Communications* (2026), PMID 41577693, doi:10.1038/s41467-026-68465-6 (open access, PMC12914052).

**Screen.** Ex vivo expanded mouse c-Kit+ HSPCs were transduced with one of the 10 Bassik mouse knockout sub-libraries (ACOC, DTKP, GE, MP, MU1, MU2, SP/STP, TMM, U1, U2; ~20,000 elements, 10 guides per gene, non-targeting and safe-targeting controls). They were transplanted into 65 lethally irradiated recipients, pooled per sub-library. After 10-12 weeks, c-Kit+ Lin- HSPCs and mature lineages were sorted. The gene-expression (GE) sub-library was then screened a second time in an independent transplant (24 recipients). The paper ranks genes by casTLE, comparing HSPCs with all mature lineages (Supplementary Data 1, genome-wide; Supplementary Data 2, GE screen). It highlights the SAGA structural subunits Tada2b, Taf5l, Taf6l and Tada1, and Runx1, Gata3 and Cic among known regulators.

**Which comparison.** No plasmid or pre-transplant library was deposited, so the only comparison is the paper's own: HSPCs vs all mature lineages, from the same pooled mice of each sub-library. Each guide belongs to one sub-library, and each sub-library was transplanted once in the genome-wide screen, so every guide has one library per population. GEO's genome-wide count files mix all sub-libraries in one column per population, and the HSPC/lineage depth ratio ranges from 0.12 (GE) to 0.97 (ACOC). `prepare.R` therefore splits each population into one column per sub-library (the guide ID names it), so each analysis uses that sub-library's own library sizes. It also adds the GE screen's per-sample files, drops CRLF line endings, and drops one guide ID listed twice with different counts. It converts the casTLE tables, which use upper-case symbols, to the count file's spelling.

**Designs** (coefficient all lineages vs HSPC, the casTLE sign: negative = knockout enriched in HSPCs):
- `GE_two_screens_lineage_vs_HSPC`: the GE sub-library in both transplants, `~ screen + population`. HSPC and lineage libraries of one transplant share clones (Spearman 0.33 and 0.54 within a screen, 0.05-0.26 across), so screen is a pairing term; this leaves 1 residual df. It is the only comparison with a replicate.
- `GW_<sub-library>_lineage_vs_HSPC` (10 analyses): 1 vs 1, with no residual df, so the overdispersion is pooled over that sub-library's 440-1,230 usable control guides.

**These are screening-level calls: for the genome-wide screen no replicate transplant was measured, and the GE analysis has a single replicate.**

## The libraries are oligoclonal

Within each sub-library, the top 1% of guides hold 82-99% of the HSPC reads and 48-81% of the lineage reads. HSPC libraries detect only 757-11,572 of their 6,800-19,000 guides; single guides hold up to 21% of a library. Runx1 guide 1 alone has 18.0 million of the 142.6 million ACOC HSPC reads. The pooled overdispersion over the controls is 1,900-11,800 times binomial. Median-ratio totals, which the composition calls for, are capped at the largest single count in three HSPC libraries (GE screen, ACOC, U2) and rest on the few guides detected in HSPCs. A median-ratio rerun did not stabilise the calls. Its GE two-screen analysis calls 0 genes and drops Tada2b to rank 1,791, while DTKP rises to 257 calls with none confirmed by the control null. The record therefore keeps library-size totals. Depletion from HSPCs means little here: most guides are simply absent from the HSPC library.

## Results

| Analysis | BARCS FDR 0.10 | Control null | Paper genes at casTLE BH 0.10 |
|---|---|---|---|
| GE, both screens (2 vs 2) | 5 (all enriched in lineage) | 25 | 4 (Tada2b, Taf5l, Taf6l, Nop2; GE screen) |
| GW, 10 sub-libraries (1 vs 1 each) | 109 in total (ACOC 14, DTKP 7, GE 1, MP 5, MU1 22, MU2 15, SP 17, TMM 11, U1 5, U2 12) | 4-25 per sub-library | 33 (genome-wide) |

Controls at p < 0.05: 61% before calibration in the GE two-screen analysis (scaled by 9.0, then 5.0%); 0-2.2% in the 1 vs 1 analyses, whose pooled overdispersion is conservative.

| Named gene | Sub-library | Paper (casTLE effect, p) | BARCS |
|---|---|---|---|
| Runx1 | ACOC | -7.2, 1e-6 (GW #11) | GW ACOC #1, -3.6, FDR 2e-104 |
| Tada2b | GE | GE screen #1 (-6.4, 1e-6); GW -7.6, 8e-4 | GE two screens: #1 HSPC-enriched gene (rank 55 overall), FDR 0.19; GW GE: FDR 1 |
| Taf5l | GE | GE screen #2 (-5.6, 3e-6) | two screens FDR 0.50; GW GE FDR 1 |
| Taf6l | GE | GE screen #3 (-5.6, 2e-5) | two screens FDR 0.79; GW GE rank 23, FDR 1 |
| Tada1 | DTKP | GW -6.6, 4e-6 | GW DTKP rank 683, FDR 1 |
| Gata3, Cic | ACOC | +0.3 (p 0.57), +5.4 (p 0.007) | FDR 1 |

Runx1 is the one robust call. Eight of its ten guides have more reads in HSPCs than in lineage (1,210 to 18 million; 4-55 times their lineage counts, at similar library sizes), so the call stands on consistent multi-guide evidence and not on one clone. The SAGA genes do not pass. Tada2b's guides are expanded in HSPCs in both GE transplants, but different guides in each. In the genome-wide GE pool, guides 7-8 have 5,108 and 2,122 HSPC reads against 944 and 215 in lineage, while guide 6 has 78,170 lineage reads and none in HSPC. In the GE screen, guide 1 has 263,821 vs 364,982 reads at library sizes of 61 and 179 million. That is what clonal expansion gives, and replicate-aware testing cannot separate it from a gene effect with two transplants.

Most BARCS genome-wide calls (89 of 109) are positive: guides absent from the sparse HSPC library but present in lineage. That is the same dropout the composition predicts. Several are olfactory, vomeronasal and immunoglobulin genes not expressed in blood (Olfr119, Olfr347, Olfr538, Vmn2r113, Ighv11-1, Gm10277), whose calls rest on a few jackpot guides or on HSPC dropout. Olfr119 has 3.05 million HSPC reads in one guide and 0 in the other three. These are clone artifacts. The paper's genome-wide casTLE list contains similar ones (Ssxb2, Synb, Actl7b, Ighv15-2, Gm21975). Of the 33 genes the paper's table puts at BH 0.10, only Runx1 and Ep300 are BARCS calls. Rank agreement with casTLE is near zero (Spearman 0.03 for the GE screen; -0.14 to 0.21 within sub-libraries).

## Verdict

BARCS recovers Runx1 as the dominant HSPC-enriched knockout but does not support the SAGA claim from the screen alone. Tada2b is the top HSPC-enriched gene of the replicated GE analysis but does not reach FDR 0.10, and Taf5l, Taf6l and Tada1 are not called. The paper's single-gene transplants validate the SAGA phenotype independently. The screen data are dominated by a few expanded clones per sub-library, which casTLE's permutation p-values and BARCS's pooled-control model both handle poorly.

## Limits

- One library per population for every genome-wide guide; one replicate for GE: screening-level calls only.
- No pre-transplant or plasmid library: depletion relative to input cannot be measured.
- Oligoclonal libraries: library-size and median-ratio totals both rest on a few clones. Calls in either direction mostly reflect clone sizes.
- Comparisons with the paper are per sub-library (`comparison.md` for the GE screen, `comparison_gwGE.md`, `comparison_gwACOC.md`, `comparison_gwDTKP.md`); BARCS has no genome-wide gene table to set against casTLE's.
