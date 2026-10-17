# GSE223086 — Brunello K562 proliferation benchmark screen

**Paper.** Bei et al., *Optimized minimal genome-wide human sgRNA library*,
Sci Rep 2023 (PMID 37464007, doi 10.1038/s41598-023-38810-6). A methods paper
that benchmarks a minimal library (H-mLib) against the full Brunello library in
a K562/Jurkat proliferation screen.

**Screen analysed.** The genome-wide Brunello arm in K562, day 0 vs day 24, two
replicate cultures per timepoint. Guides depleted over time mark essential
genes. The deposited data are per-sample two-column count files (guide id +
count, no header); prepare.R merges the four Brunello K562 files into one count
matrix and derives the gene from the guide id (`<Gene>_<20nt>_Brunello`).

**Design.** `~ condition`, coefficient `conditionday24` (day 24 vs day 0), 2
residual df. `control_gene_pattern` `^NO_CURRENT` (the Brunello non-targeting
guides).

**Results.** 968 genes at FDR 0.10 (842 depleted). The depleted list is led by
genuine essentials — PPP4C, NOP58, RPTOR, PPP6C, POLR3B, RPP30, CCT7, MAK16,
nucleolar/RNA-pol/chaperonin genes. The NO_CURRENT controls have near-zero
coverage in this deposit (~90 total reads across all 1,000 at day 0), so they
drop out at `min_total_count` and give no usable control null.

**Agreement.** No biological hit table exists (this is a library benchmark). As
a positive-control check, canonical core-essential genes are all strongly
depleted at FDR 0.10: NOP58 #2, RPTOR #3, POLR3B #5, CCT7 #10, plus RPL3,
RPS19, POLR2A, POLR2B, PSMA1, CDK1, MYC. The screen selected as expected.
agree (positive-control validation).

**Limits.** The deposited Brunello non-targeting guides are effectively absent,
so the hit list cannot be calibrated and there is no control null. Essential-
gene recovery is good at the top but imperfect further down (some ribosomal
genes rank modestly), consistent with the day-24 single endpoint and variable
day-0 depth. Counts merged by prepare.R; values unchanged.
