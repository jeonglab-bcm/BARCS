# GSE232856 reanalysis with BARCS 0.2.2

**Paper.** "A non-canonical role for a small nucleolar RNA in ribosome biogenesis and senescence", *Cell* 2024, PMID 38981482 (PMC11344685).

**Why it was excluded before.** Only normalized, non-integer guide counts were deposited.

**Count recovery.** The deposited table is raw reads scaled to 20,000,000 per library plus a pseudocount of 1: (x - 1) / s is an integer (within ~1e-3) for 100.0% of positive values in all four columns. Recovered integers in `recovered_counts.tsv` (offset 1, per-column scale in the scales JSON); each raw library totals ~19-23 M reads.

**Screen.** Genome-scale CRISPRi against 6,701 fibroblast-expressed noncoding RNAs (~69.7k guides, CRiNCL library) in BJ-HRAS(G12V)-dCas9-KRAB fibroblasts; day 0 vs day 21 of HRAS(G12V) induction (oncogene-induced senescence), two independent clones (a, b).

**Design.** `~ clone + condition`, D21 vs D0, 4 libraries, 1 residual df. Guide-to-lncRNA mapping was rebuilt from the GSE85011 CRiNCL transcript GTF (guide names carry the TSS id and Cufflinks transcript id).

**Composition.** The two D21 libraries are dominated by a few surviving clones (top 1% of guides hold 58% and 70% of reads). Library-total normalization therefore over-calls depletion (6,616 genes down); rerun with median-ratio totals, which is the correct read on a strong-selection screen. Reported numbers use median-ratio totals.

## Results (median-ratio totals)
- 140 genes at FDR 0.10 (131 against the control null); control p<0.05 rate 2.5% after; guide correlation ~0.
- The paper's single highlighted hit, **EPB41L4A-AS1** (host transcript of SNORA13; gene id LH12673) is the **#1 enriched locus** (estimate +2.3, FDR 1e-11, empirical FDR 0.003).
- **FENDRR** (LH06194) is #3 enriched; the paper's other highly-ranked signals are promoter-proximal protein-coding units (CCNC, CDKN1A, FOXF1) that are not direct members of this lncRNA library and so are not named genes here.

## BARCS vs paper
Agreement on the paper's central finding: EPB41L4A-AS1 / SNORA13 is the top enriched noncoding RNA required for oncogene-induced senescence. The paper used MAGeCK on enriched-vs-depleted populations; BARCS reaches the same lead hit after accounting for the strong composition shift.

## Limits
Two clones, one culture each (1 residual df). Depletion calls are unreliable under the composition shift; enrichment (the paper's question) is the interpretable direction. The paper's supplementary MAGeCK table (Table S1) is behind a paywall, so comparison is to the named hit and the CRiNCL loci.
