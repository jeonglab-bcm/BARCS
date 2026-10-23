# GSE222104 — Genome-wide knockout FACS screen for translocation-associated quality control (SAYSD1)

**Paper.** Liang J-R et al. (Ye Y lab), SAYSD1 senses UFMylated ribosome to
safeguard co-translational protein translocation at the endoplasmic reticulum.
*Cell Reports* 2023 (PMID 36848233, doi 10.1016/j.celrep.2023.112028).

**Screen.** 293T cells carrying the translocation-stalled reporter ER-GFP-K20
were transduced with GeCKO v2 (A+B, 6 guides per gene) and FACS-sorted into
GFP-high (10%) and GFP-low (85%) populations; two biological repeats.
Knockouts that impair TAQC stabilise the reporter and are enriched in GFP-high.
The paper ran MAGeCK (paired mode), called 234 genes at p < 0.01 and 88
high-confidence hits, and highlighted the UFMylation cluster (UFM1, UBA5,
DDRGK1, CDK5RAP3, UFSP2) and the uncharacterised SAYSD1, which it then
validated.

**Input and design.** The deposited workbook's Raw_counts sheet (MAGeCK count
output: initial_rep1/2 = GFP-low, final_rep1/2 = GFP-high) is used as is.
`~ condition`, GFP-high vs GFP-low, 2 residual df; no replicate term (the
counts show no high-low pairing). Composition normal (top 1% of guides
4.4-5.9% of reads); controls calibrated (6.0% at p < 0.05); guide correlation
0.001.

**Results.** 299 genes at FDR 0.10 (30 enriched in GFP-high, 269 depleted =
enriched in GFP-low); 21 against the control null. The enriched side is the
paper's signal: CRCP, SART3, NELFCD, DHX15, SEC61B, DDRGK1, GCN1L1, NELFA,
EIF6, POLR3H — translation, splicing, translocon and UFMylation genes. SAYSD1
is rank 23 (FDR 0.079), DDRGK1 rank 6 (0.027), CDK5RAP3 rank 26 (0.085); these
pass. UFM1 (rank 182, FDR 0.26), UBA5 (0.43) and UFSP2 (0.44) do not: their
enrichment rests on 2 of 6 guides (UFM1 two guides jump to 9,066 and 4,199
reads in one GFP-high repeat but three are flat), which the gene-level test
down-weights.

**Agreement.** Spearman 0.79 with the deposited MAGeCK `pos|score`; 27 of the
top 50 and 46 of the top 100 shared. SAYSD1, the paper's lead and only
mechanistically validated hit, is recovered at FDR 0.10, as are two of the five
UFMylation genes (DDRGK1, CDK5RAP3); the other three (UFM1, UBA5, UFSP2) are
enriched but miss FDR because only part of their guide set responds. The large
depleted side (269 genes enriched in GFP-low) has no biological meaning here —
GFP-low is the bulk population — and reflects the single sort contrast.

**Limits.** Two repeats, one sort contrast, no unsorted baseline; the paper's
paired MAGeCK model and its p < 0.01 / network-clustering criterion differ from
BARCS's per-guide FDR, so the UFMylation cluster is only partly recovered.
