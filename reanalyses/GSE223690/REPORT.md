# GSE223690 — SARS-CoV-2 -1 PRF reporter CRISPR screen

**Paper.** Kim et al., Cell Reports 2023 (PMID 37581984, doi
10.1016/j.celrep.2023.112987). A genome-wide knockout screen for host factors
that modulate SARS-CoV-2 programmed -1 ribosomal frameshifting (-1 PRF).

**Screen.** HEK293T cells with a -1 PRF dual-fluorescence (GFP/mCherry)
reporter were transduced with the two halves of the GeCKOv2 library (HGLibA +
HGLibB) and FACS-sorted into high and low GFP/mCherry (frameshifting) bins at
day 7 and day 14, two biological replicates each. The deposited count table
stacks the HGLibA and HGLibB rows of a given bin/replicate into one column
(each column is the sum of the two sub-libraries; every gene has guides in both
halves). 1,000 non-targeting controls.

**Design.** `~ replicate + condition`, coefficient `conditionlow` (low vs high),
day 14 primary and day 7 secondary; the paper's MAGeCK "pos" direction (higher
in the low bin) is reduced frameshifting (1 residual df after pairing).

**Results.** Day 14: 35 genes at FDR 0.10, control p05 0.048 (well calibrated),
15 against the control null. EIF2A is the top enriched gene (enriched rank 1,
FDR 3.7e-11); the depleted/suppressor side is led by GET4, BAG6, DNAJC24 — the
same genes the paper's "neg" direction tops. Day 7: 43 genes; EIF2A enriched
rank 6 (FDR 0.018).

**Agreement.** Against the authors' MAGeCK table (mmc2, sheets Day_7 / Day_14):
rank correlation 0.64-0.65, effect-direction agreement 97-99%. EIF2A, the one
validated hit, is reproduced as the top enhancer at day 14. Depleted-side
top-10 Jaccard 0.67. agree.

**Limits.** Each count column pools two sequencing sub-libraries (HGLibA +
HGLibB); their depth ratio differs by up to ~12% between columns, a small
per-sub-library offset that largely cancels at the gene level. The paired design
leaves only 1 residual df. BARCS calls a longer list than the paper's very
sparse RRA hits. Count files used as deposited; prepare.R only fetches mmc2.
