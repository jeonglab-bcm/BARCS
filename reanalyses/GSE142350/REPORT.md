# GSE142350 reanalysis with BARCS 0.2.3

**Paper.** "Identification of X-chromosomal genes that drive sex differences in embryonic stem cells through a hierarchical CRISPR screening approach", *Genome Biology* (2021), PMID 33863351, doi:10.1186/s13059-021-02321-2 (PMC8051100).

**Screens.** A hierarchical set of CRISPR knockout screens in female (1.8 XX) mouse ESCs for X-linked genes that modulate the female pluripotency phenotype:
- **SRE-Elk** (primary): GeCKOx library against all X-linked genes + MAPK controls; an SRE-Elk (MAPK-target) GFP reporter, GFP-high cells double-sorted vs unsorted (3 reps).
- **Nanog** (secondary, GeCKOxs): 25% lowest Nanog-mCherry double-sorted vs unsorted (2 reps).
- **Esrrb** (secondary): after 3-day LIF withdrawal, 10% lowest Esrrb-mCherry sorted vs unsorted (3 reps).
- **pMek** (secondary): 25% lowest phospho-Mek sorted vs unsorted (3 reps).

Paper method: MAGeCK (double-sorted vs unsorted, FDR < 0.05).

**Design.** Per screen, `~ replicate + population` (sorted vs unsorted), replicate a blocking term. Counts were recovered to integers from the deposited MAGeCK-normalized tables with recover_counts.R (every library passed, integrality 1.0; some pMek/SRE-Elk libraries needed k up to 26 because their smallest value was ~20 reads). The two positive controls the paper names by protein (Erk2, Mek1) were mapped to the library symbols Mapk1, Map2k1.

## Results: the paper's central hits

| Gene | SRE-Elk | Nanog | Esrrb | pMek |
|---|---|---|---|---|
| Dusp9 | **#1** | **#3** | #14 | **#1** |
| Klhl13 | **#3** | **#1** | **#4** | #13 |
| Zic3 | #5 | #4 | #10 | #56 |

Dusp9 and Klhl13 — the two central players validated in the paper — are the top-ranked enriched genes across the screens, and the other named mediators (Zic3, Stag2, Fthl17) rank high. Gene-score Spearman vs the paper's MAGeCK FDRs: SRE-Elk 0.53, Nanog 0.77, Esrrb 0.68, pMek 0.78; top-10 overlap is 7-9/10 in every screen.

## Where BARCS differs

BARCS reports both enriched and depleted genes from one replicate-aware model; the paper separated enriched (double-sorted/unsorted) from depleted (unsorted/double-sorted) HitSelect/MAGeCK runs, so the overall effect-direction agreement on all genes is moderate (35-47%) while the strong hits coincide. The counts are recovered from normalized tables, not the original BAM-level reads.

## Limits

- Counts are exact-integer recoveries of normalized tables (recovery_scales.json records the per-library scales).
- The secondary screens carry only 10 non-targeting controls, too few to calibrate, so their p-values are not control-calibrated; the primary SRE-Elk screen (100 controls) calibrates cleanly (control p<0.05 = 2%).
