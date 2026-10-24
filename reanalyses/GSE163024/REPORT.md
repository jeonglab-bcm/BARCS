# GSE163024 — CRISPRa screen for activators of type VII collagen (COL7A1) in keratinocytes

**Paper.** Genes and compounds that increase type VII collagen expression as
potential treatments for dystrophic epidermolysis bullosa. *Exp Dermatol* 2022
(PMID 35243691, doi 10.1111/exd.14555).

**Screen.** Genome-wide CRISPRa (Calabrese set A, 56,762 guides, 3 per gene,
dCas9-VP64) in N/TERT keratinocytes with tdTomato knocked into the last exon of
COL7A1. The top 10% tdTomato cells were sorted and their guides compared with
the plasmid library. The paper converted guide fold changes over the plasmid
into Z-scores, reported 1,544 enriched guides, and picked genes with more than
one enriched guide: DENND4B (Z > 5) and TYROBP (all three guides enriched),
with COL7A1 itself as the positive control; both were validated individually.

**Input.** GEO holds a workbook with one row per guide that had a read in the
sort. The sorted sample's raw reads are the `Count` column (they match the
deposited read file). The plasmid reads are only given as `refCPM`; prepare.R
recovers them exactly: the workbook's CPM is (reads + 1) × one constant per
sample (checked on the sorted sample, where `CPM / 0.0620748 = Count + 1`
for every guide), and `refCPM` is a whole multiple of 0.0301056 for every
guide (largest deviation 1e-11), so plasmid reads = refCPM / 0.0301056 − 1
(32.3 M reads; recovery_scales.json). The half scale would make every count
odd, so the scale is not ambiguous. Guides with no read in the sort (about
2,800) are absent from the deposit, and 74 guides with an empty gene cell are
dropped; 53,854 guides remain.

**Design.** `~ condition`, tdTomato-high vs plasmid, one library each. With no
residual degrees of freedom, run_barcs.R used the no-replicate path: the
overdispersion was pooled from the 477 non-targeting (CONTROL) guides
(rho 2.5e-6) and every guide tested at that value. **Calls are
screening-level**: variation between replicate sorts was not measured.
Control calibration was not needed (4.2% of controls at p < 0.05).

**Results.** 3 genes at FDR 0.10, exactly the paper's three: DENND4B (rank 1;
one guide 1,484 → 20,068 reads, about 27-fold after the 2-fold depth
difference, the other two 1.8-3.3-fold), TYROBP (rank 2; all three guides up
2.8-7.4-fold) and COL7A1 (rank 3; one guide 1,171 → 8,699, the other two
flat or down).
The control null agrees (5 genes at empirical FDR 0.10, centred on the
targeting guides because the controls sit 0.28 z low).

**Agreement.** Gene-level Spearman 0.72 with the paper's best guide Z-score
per gene. Top-N overlap is low beyond the top three because the paper's list
is guide-level: its ranks 3-10 (SH2D1B, OR6C3, RNF114, ARSK, …) each rest on
one guide while the other guides of the gene are flat or down, which BARCS's
gene-level combination does not call (SH2D1B ranks 12,357). The paper itself
discounted these by requiring several enriched guides.

**Limits.** One sorted library against the plasmid; no unsorted or pre-sort
population, so representation drift during culture is confounded with the sort
effect. The plasmid counts are reconstructed from CPM (exact, but derived), and
guides absent from the sort could not be included.
