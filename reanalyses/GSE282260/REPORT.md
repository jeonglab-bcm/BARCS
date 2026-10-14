# GSE282260 reanalysis with BARCS 0.2.3

**Paper.** "N6-methyladenosine in DNA promotes genome stability", *eLife* 13:RP101626 (2025), PMID 40193195, doi:10.7554/eLife.101626, PMC11975372 (open access). This is a genome-wide CRISPR KO screen in HT-29 colorectal cancer cells under floxuridine (FdU, 2.2 nM). UNG is the top hit; known U-BER (APEX1, LIG1) and MMR (MSH2, EXO1) factors also score, and so do the m6A methyltransferases METTL3, METTL14 and METTL4. Supplementary file 1 gives the paper's MAGeCK gene results (log2 fold change, -log10 p) for every gene, by sub-library pool. `prepare.R` downloads it and splits it by pool. Despite the column header "-log2(fold change)", the values are negative for genes depleted under FdU (UNG -4.5, TK1 +3.4).

**Series and counts.** The library was split into four pools (A-D). Each pool was transduced separately and has its own integer count file (`GSE282260_Pool{A,B,C,D}_cts.txt.gz`, about 20k guides on about 5,000 genes, 149-150 non-targeting `NT` guides). Library totals are therefore per pool, and each pool is a separate BARCS analysis (`design.json` = pool A, `design_pool{B,C,D}.json`). The files hold more libraries than the 6 GSMs per pool in GEO. There are two arm series, **E** and **U**, each with two replicate cultures (E1/E2, U1/U2) and DMSO and FdU libraries at the GEO end point (A day 11, B day 15, C day 14, D day 15). There are also later time points, and in pool A some FdU_R libraries.

## What E and U are

Neither the paper nor GEO explains E and U (the paper mentions only "technical triplicates"). The data settle which one the paper used. The paper's published log2 fold changes are reproduced almost exactly by the **E arm** at the GEO end point. The Pearson r between the paper's values and the E1/E2 FdU-vs-DMSO median guide log fold changes is 0.997, 0.990, 0.986 and 0.992 for pools A-D. For the U arm the same r is 0.41-0.52, and for the later time points it is 0.55-0.83. The two arms are not replicates of each other: E1 and E2 agree with each other (r 0.34-0.55 between their FdU effects) better than either agrees with U1 or U2 (0.16-0.32). In pool A, UNG guides drop out by day 11 in E but only by day 21 in U, so U responded more slowly (perhaps a lower effective dose). What U is remains undocumented. The GEO REP1/REP2 samples are taken to be E1/E2.

## Design

Primary analysis per pool: **FdU vs DMSO at the end point, E arm, `~ treatment`, 2 vs 2** (residual df 2). DMSO and FdU cultures were split at t0 and not paired per replicate, so there is no culture term. Sensitivity analysis: both arms with an arm term (`~ arm + treatment`, 4 vs 4).

| Pool | Raw control p<0.05 | Genes FDR 0.10 (E arm) | depleted / enriched | Control null | E+U sensitivity |
|---|---|---|---|---|---|
| A (day 11) | 8.7% (calibrated) | 693 | 408 / 285 | 1,019 (centred on controls, shift -0.23 z) | 586 |
| B (day 15) | 11.4% (calibrated) | 437 | 301 / 136 | 529 (centred on targets, shift -0.41 z) | 361 |
| C (day 14) | 7.3% | 701 | 442 / 259 | 962 (centred on targets, shift -0.44 z) | 655 |
| D (day 15) | 6.0% | 646 | 380 / 266 | 775 (centred on targets, shift -0.38 z) | 388 |

In total, 2,477 genes reach FDR 0.10 (1,531 depleted, 946 enriched) out of about 20,000. The libraries are deep (about 7 M reads for 20k guides) and not bottlenecked (top 1% of guides hold 2.6-5.3% of reads). The top eight calls in every pool have all four guides in the same direction, so the long list reflects a strong drug effect measured precisely, with many small effects. Restricting to |log2 FC| > 0.5 leaves 238/181/318/323 genes.

## Agreement with the paper

Pool A (named hits, depletion rank of 4,853 genes): **UNG #7** (FDR 6e-27; the separate UNG_2 isoform guides are #4), **APEX1 #8**, **LIG1 #10**, **METTL3 #74** (FDR 1.7e-6), **METTL14 #91** (FDR 1.3e-5), **METTL4 #105** (FDR 7.1e-5). EXO1 (pool B) is #19 and MSH2 and LIG1 (pool D) are #68 and #86, all at FDR < 0.001. TK1 is the second-ranked gene in pool A, enriched: TK1 phosphorylates floxuridine, so losing it gives resistance. This is an internal positive control.

Against the published table (depletion ranked by fold change), the Spearman correlation is 0.97, 0.96, 0.95 and 0.94 for pools A-D. The top-100 overlap is 74, 69, 67 and 67, and 94% of genes agree in direction. Of the paper's genes passing its own cutoff (p < 0.01 and |log2 FC| > 0.5; 224, 158, 245 and 246 genes), 98-99% are at BARCS FDR 0.10. The differences are in ordering. BARCS ranks consistent moderate effects higher (LIG1 #10 vs published #97, BRD2, CAD, USP7). The published list puts some larger but more variable fold changes higher (INO80 #17 vs BARCS #71, DTYMK, SETD1A).

## Limits

- Each pool has two replicate cultures per arm.
- The E/U assignment rests on matching the published table, not on documentation.
- FDR is controlled per pool, not genome-wide.
- In pool A the control null counts more genes than the model (1,019 vs 693) with the null centred on the controls (shift -0.23 z), so the model count is the one to quote.
- Pools B-D have non-targeting guides offset from the targeting guides (-0.38 to -0.44 z), so their control null is centred on the targeting guides.
