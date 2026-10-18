# GSE246837: METTL3 inhibition and T-cell killing (PMID 37548590)

**Paper:** Guirguis, Ofir-Rosenfeld et al., "Inhibition of METTL3 Results in a Cell-Intrinsic Interferon Response That Enhances Antitumor Immunity", *Cancer Discovery* 2023;13(10):2228-2247.

**Series:** GSE246837 ([CRISPR screen] SubSeries). It has 11 per-sample `guideCounts` files: raw integer read counts per Brie guide, with the unmapped reads on a `*` line. `prepare.R` merges them into `counts.tsv.gz`. It fills guides missing from a file with 0, drops the `*` line, and takes the gene name from the part of the guide id before the first underscore. The merged table has 79,525 guides, 19,671 genes and 1,000 `Control` non-targeting guides.

## Libraries

There is one library per condition:

- an early time point;
- B16-Ova-Cas9 cells without T cells, with DMSO, 5 uM or 20 uM STM2457 (Mettl3i);
- OT-I co-culture at E:T 1:20 (DMSO, 5 uM), 1:5 (DMSO, 5 uM, 20 uM) and 1:1 (DMSO, 20 uM).

The labels for GSM7879968 disagree. Its title says 20 uM, but its treatment field and file name (`2457L`) say 5 uM. I used 5 uM.

The two 1:20 libraries correlate 0.90 with the no-T-cell library that got the same drug. This fits drug-pretreated cultures that were split into co-culture.

The two 1:1 libraries are heavily bottlenecked:

- their Spearman correlation with each other is 0.28;
- the top 1% of guides holds 6% (DMSO) and 11% (Mettl3i) of the reads.

## Design

**Main analysis: `Mettl3i_vs_DMSO_coculture`**

- Formula `~ ratio + drug` over the 7 co-culture libraries, coefficient `drugM3i`.
- The model compares Mettl3i with DMSO inside each E:T ratio and pools the two doses.
- It has 3 residual degrees of freedom and moderation applied.
- Guide correlation is 0.000.
- `control_p05` is 4.75%, so no calibration was needed.
- Composition is normal except for the 1:1 pair.

Design uncertainties:

- The two doses are pooled into one Mettl3i effect.
- Blocking by ratio assumes each ratio's DMSO arm is the right baseline for its Mettl3i arm.
- Effects that the drug has without T cells are not subtracted. An interaction model would do that.

**Positive-control analysis: `Tcells_1to5_vs_none`**

- Additive model `~ drug + ratio` over the 10 treated libraries, coefficient `ratio1to5`.
- 9 genes pass FDR 0.10 (45 against the control null).
- The top genes are Ifngr2, Stat1, Ifngr1, Jak1, Jak2, B2m, Tap1 and Tap2.
- So the T cells selected as expected: the IFN-gamma pathway and antigen presentation are enriched.
- The raw `control_p05` is 0.5%, which means the test is conservative here.

## Results (main analysis, enriched = knockout protects cells under Mettl3i)

At FDR 0.10, 4 genes pass: Jak1, Stat1, Ifngr1 and Ifngr2.

- All four guides of each gene are enriched in every ratio.
- None of these calls rests on a jackpot guide.

The control null gives 6 genes; it is centred on the controls (shift -0.05). The two genes it adds are Ints3 and Nxt2. Most of their signal comes from single guides in the bottlenecked 1:1 Mettl3i library, so I discount them.

## Comparison with the paper

I could not get a gene-level table:

- GEO has only the per-sample counts.
- The paper is not in PMC.
- The AACR supplement page returned HTTP 403.

The named hits are therefore canonical members of the two pathways that the abstract names: dsRNA sensing (Ifih1, Mavs) and interferon signalling (Ifnar1, Jak1, Stat1, Ifngr1). They are not hits taken from a paper table.

| Gene | BARCS rank (enriched) | FDR |
|---|---|---|
| Jak1 | 1 | 2.7e-06 |
| Stat1 | 2 | 2.7e-06 |
| Ifngr1 | 3 | 6.6e-04 |
| Mavs | 2545 | 0.88 |
| Ifih1 | 4796 | 0.94 |
| Ifnar1 | 19544 (slightly depleted) | 0.65 |

**Agreement: partial.**

- BARCS strongly supports the claim that interferon signalling mediates the extra T-cell killing under Mettl3i, but through the IFN-gamma receptor/JAK1/STAT1 axis.
- In this co-culture screen BARCS finds no support for the dsRNA sensors MDA5 (Ifih1) and MAVS, or for type I IFN receptor signalling (Ifnar1).
- The paper may have shown the dsRNA arm with other screens or experiments (for example the cell-intrinsic interferon response without T cells), which this record does not cover.

## Limits

- There is one library per condition. Replicate cultures were not measured, and the ratios act as pseudo-replicates of the drug effect.
- The 1:1 libraries are bottlenecked.
- The named hits come from the abstract's pathways, not from the paper's own table.
