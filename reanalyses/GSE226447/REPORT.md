# GSE226447 — Genome-wide knockout screen for alpha-amanitin resistance (HAP1)

**Paper.** Wang B et al., Identification of indocyanine green as a STT3B
inhibitor against mushroom α-amanitin cytotoxicity. *Nat Commun* 2023
(PMID 37193694, doi 10.1038/s41467-023-37714-3).

**Screen.** Brunello knockout library in HAP1 cells; mutant pools treated with
α-amanitin (AMA) or PBS for 7 days, two replicates each; survivors sequenced.
The paper ran MAGeCK (Supplementary Data 1, positive selection), reported 559
genes at p < 0.05 and |LFC| > 1, and highlighted the N-glycan pathway: STT3B
and MGAT1 in the top 10 (STT3B validated by knockout, and the basis of the
ICG antidote), with guide counts for ALG10, STT3A and RPN2 described as
enriched.

**Input and design.** The deposited count table is used as is (PBS1/2,
AMA1/2, matching the GSM titles). `~ condition`, AMA vs PBS, 2 residual df.
AMA kills most cells: the top 1% of guides hold 81-86% of the reads in the AMA
libraries (5% in PBS). With library totals, almost every guide looks depleted
and 98.7% of the non-targeting controls reach p < 0.05 before calibration
(calibration scale 4.2). Following the skill, the recorded comparison uses
**median-ratio totals** (`AMA_vs_PBS_median_ratio`); the library-total run is
kept for reference. Median-ratio totals were not capped; controls were still
calibrated (20.3% at p < 0.05 raw, scale 1.83).

**Results (median-ratio).** 17 genes at FDR 0.10, all enriched: WDR81, MGAT1,
TAF4, SPPL3, SLC46A3, KIAA1033, COMMD3, PSENEN, STT3B, NELFCD, CFAP52, RALGAPB,
FAM45A, RPL32, DCPS, COMMD7, HIST1H2AJ. 8 pass the control null (empirical FDR
0.10, centred on the controls). NELFCD, RPL32 and DCPS rest on a single guide
(the others fall below the count filter) and should be discounted. The large
counts are reproducible across the two AMA replicates (e.g. one TAF4 guide
holds 1.9 M and 1.7 M reads, one STT3B guide 23,005 and 21,200), so the
replicates probably share resistant clones from the common mutant pool;
replicate agreement here does not prove independent selection.
Library totals give 8 genes (TAF4, SLC46A3, MGAT1, WDR81, STT3B, NELFCD,
SPPL3, KIAA1033), the same core.

**Agreement.** Spearman 0.77 with MAGeCK `pos|score`; 8 of the top 10 shared.
8 of the paper's 10 genes at MAGeCK FDR 0.10 are BARCS calls (not LAMTOR2,
rank 26, and TIGD5, rank 24). STT3B (#9, FDR 0.038; two of four guides
jump from 26-115 to about 20,000 reads, two stay near zero) and MGAT1 (#2,
all four guides up) pass. ALG10, STT3A and RPN2 are not hits: their raw counts
fall or stay at the floor under AMA (RPN2 guides ≤ 34 reads in all libraries;
STT3A 65-309 → 0-104), so their "enrichment" in the paper can only come from
median-scaling the AMA libraries, whose median guide has 13-19 reads against
109-128 in PBS. The same scaling makes MAGeCK rank the non-targeting controls
as the #1 positively selected "gene".

**Limits.** Strong bottleneck: most guides are lost under AMA (19-30% zeros),
so depletion cannot be read and enrichment is driven by a few hundred clones.
Two replicates that likely share clones; no plasmid or T0 library deposited.
