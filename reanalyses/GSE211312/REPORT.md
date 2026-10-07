# GSE211312 reanalysis with BARCS 0.2.1

**Paper.** "Epigenetic control of telomeric RNA maintains heterochromatin in telomerase-driven cancers", *Signal Transduction and Targeted Therapy* (2026), PMID 42236690 (PMC13233980).

**Screen.** GeCKO genome-wide knockout (56,125 guides, 1,000 non-targeting) in GM0847 (ALT) cells with and without hTERT overexpression, sampled at T0, T6 and T15 in duplicate. The same series also has HT1080 pairs.

**Design.** A synthetic-dosage-lethal gene drops out more over time in hTERT cells than in parental cells. That is the line × time interaction: `~ line * time`, T0 and T15, 8 libraries, 4 residual df. The endpoint-only hTERT vs parental comparison was also run.

**Calibration.** 13.7% of non-targeting guides reached p < 0.05 for the interaction before calibration; 5.0% after. Before calibration, 351 genes passed FDR 0.10; after, none.

## Results

| | Interaction | Endpoint only |
|---|---|---|
| Genes at FDR 0.10 | 0 | 0 |
| FTSJ3 | rank 18,567 of 18,685, effect +0.32 (no extra dropout) | rank 13,725 |

## Where BARCS agrees and differs

- **Differs.** FTSJ3 does not drop out faster in hTERT GM0847 cells in this screen.
- **Context.** The paper prioritized 100 candidates across CRISPR and shRNA screens in several isogenic pairs, then validated FTSJ3 with arrayed and in vivo screens. Its selection did not rest on this screen alone, and the HT1080 pair (not reanalyzed) may carry the signal.
- **Calibration.** Without control calibration the interaction model would have reported 351 genes; the non-targeting guides show those calls were not reliable.

## Limits

- One of two isogenic pairs analyzed.
- Two libraries per cell.
- The paper's integrated ranking is not deposited.
