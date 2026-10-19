# GSE268182 - Genome-wide HSV-1 restriction-factor screen (TMEFF1)

## Paper
"TMEFF1 is a neuron-specific restriction factor for herpes simplex virus."
Nature 2024. PMID 39048823. Cas9+ SK-N-SH cells were transduced with the GeCKO v2
library (part A = screen 1, part B = screen 2), infected with HSV-1-K26GFP
(MOI 0.25), and the GFP-high fraction sorted 17 h post-infection and compared with
an unsorted control. Loss of a restriction factor raises viral replication and GFP,
so restriction-factor guides should enrich in GFP-high. The authors nominated
TMEFF1 and validated it extensively (neuronal knockdown, Tmeff1-/- mice,
interactions with nectin-1 and NMIIA/B).

## Series and comparison
Two per-sample count files, one per GeCKO v2 half-library, each holding a GFP-high
(High) and an unsorted-control (USC) column for that half. The halves contain
different guides, so prepare.R writes two count files (countsA.tsv, countsB.tsv)
and they are analysed separately:
- libraryA_High_vs_USC (design.json, 63,950 guides, 20,667 genes)
- libraryB_High_vs_USC (design_libraryB.json, 56,869 guides, 18,830 genes)

guide=sgRNA, gene=Gene, direction enriched, term conditionHigh (reference USC).
Each half has one library per condition, so residual df = 0 and BARCS uses the
no-replicate path, pooling rho across the 1,000 NonTargetingControl guides
(control_gene_pattern ^NonTargetingControl). These are screening-level calls:
replicate sorts were not measured. The 1,000 controls give an empirical null, and
control calibration is clean in both halves (control_p05 0.008 and 0.028,
control_shift near 0, composition mild at 4-7%).

## Agreement - BARCS does not recover TMEFF1
The paper's validated hit TMEFF1 is not recovered as an enriched gene in either
half-library. The gene labelled TMEFF1 (2 guides per half) ranks 13,497/20,667
(library A) and 17,405/18,830 (library B) with slightly negative estimates. The
GeCKO readthrough label MSANTD3-TMEFF1 (3 guides, which also targets TMEFF1) is
modestly enriched (rank 307, p=0.10 in A; rank 135, p=0.03 in B) but not
significant.

No gene passes the empirical (control-null) FDR 0.10 in either half. Library A
shows 12 genes at model FDR 0.10, but 0 against the control null, and its top
"hits" are olfactory receptors and other sparse-count genes (OR2A25, ZSWIM3,
UGT1A10) typical of single-replicate jackpot artifacts; library B calls 0 genes at
model FDR. The well-behaved 1,000-guide control null confirms that no gene rises
above noise.

## Interpretation and limits
This is a genome-wide screen (20k genes) deposited as a single GFP-high vs single
unsorted library per half-library, with no replicate sorts. With one library per
condition and only 2-3 guides per gene, BARCS has no power to separate a true
restriction factor from sampling noise, and the clean control null shows no gene
stands out. The authors identified TMEFF1 through their own screen pipeline
(likely combining the halves and additional metrics) and, critically, through
extensive orthogonal validation rather than from a significant enrichment in these
counts. BARCS, applied faithfully to the deposited data, flags TMEFF1 only weakly
(via the readthrough guides) and does not confirm it. Verdict: differ (the deposit
is underpowered for a formal call and the named hit is not recovered).

Limits: one library per condition (no residual df, screening-level); two half-
libraries that cannot be pooled at the guide level; genome-wide scale with few
guides per gene.
