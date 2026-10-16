# GSE206832 reanalysis with BARCS 0.2.3

**Paper.** Weiss et al., "Systematic identification of gene combinations to target in innate immune cells to enhance T cell activation", *Nature Communications* (2023), PMID 37813864, doi:10.1038/s41467-023-41792-8 (PMC10562403). GSE206832 is the [DNA] screen series; its single-cell HMPCITE-seq companion (GSE232543) is triaged separately.

**Screens.** Cas9 mouse bone-marrow-derived dendritic cells (BMDCs), LPS-stimulated and sorted into the top and bottom 10% of surface CD86 or PD-L1 (Cd274).

| Screen | Library | Libraries | Analysis |
|---|---|---|---|
| CD86 genome-wide | Brie, 79,314 guides, 986 non-targeting (BRDN) | 2 repeats × H/L | `CD86_GW_low_vs_high` (design.json) |
| PDL1 genome-wide | Brie | 1 × H/L | `PDL1_GW_low_vs_high` (design_pdl1.json), no-replicate path |
| CD86 secondary | ~2,280 genes × 10 guides, 197 intergenic | 1 × H/L | `CD86_secondary_low_vs_high` (design_cd86sec.json), no-replicate path |
| PDL1 secondary | same secondary library, 199 intergenic | 2 repeats × H/L | `PDL1_secondary_low_vs_high` (design_pdl1sec.json) |

Counts are the GEO files, integer reads, columns self-named and matching the GSM titles. Each GEO file starts with a UTF-8 byte-order mark in its first column name; `prepare.R` rewrites the four files without it (counts unchanged) and builds the authors' MAGeCK gene tables (Supplementary Data 1–4, sheet "Mageck genes") as gene, smaller of neg/pos p-value and FDR, and MAGeCK lfc.

**Design.** Every analysis is `~ bin` with low vs high as the coefficient, the same sign as the authors' MAGeCK lfc (treatment = low bin): a positive estimate means the knockout lowers the marker (Cd86, Cd274 themselves), a negative one that it raises it (March1, Cebpb and Med12 in the CD86 screens). The repeats in the two-repeat screens were each sorted into both bins and so are paired, but a repeat term would leave 1 residual df and the libraries do not cluster by repeat (genome-wide CD86 Spearman 0.25–0.41 throughout; PDL1 secondary high bins 0.76 with each other), so it is left out (2 residual df). The single-repeat screens use the no-replicate path: overdispersion pooled over the control guides, calls are screening-level.

**Calibration and checks.** No calibration was needed: control guides at p < 0.05 are 2.9% (CD86 GW), 0.8% (PDL1 GW), 6.6% (CD86 secondary) and 1.0% (PDL1 secondary). Composition is flat (top 1% of guides hold 2.3–4.4% of reads). Controls sit within 0.13 z of the targeting guides, so the control nulls are centred on the controls; they give 6, 0, 151 and 105 genes against the model's 6, 0, 120 and 81. The genome-wide libraries are noisy: H and L bins of one repeat correlate at only 0.25 (CD86) and 0.24 (PDL1), consistent with few sorted cells per guide. The calls rest on guides that agree in direction (3–4 of 4 for every genome-wide call), not on single jackpot guides.

## Results

| | BARCS 0.2.3 | Authors' MAGeCK (FDR 0.10) |
|---|---|---|
| CD86 genome-wide | 6 genes: Hspa5, Cd86 (#2), March1 (#3), Ubl3, Chd4, Eif3g | 6 genes; 5 shared (paper adds 1810013L24Rik) |
| CD86 secondary | 120 genes (151 control null) | 95 genes; 92 shared |
| PDL1 genome-wide | 0 genes; Cd274 #2 (p 7e-4), Cebpb #32 | 1 gene (Cd274) |
| PDL1 secondary | 81 genes (105 control null) | 44 genes; 39 shared |
| Cebpb | CD86 sec #96, FDR 0.036; PDL1 sec #2, FDR 8e-16 | hit in both secondary screens |
| Med12 | CD86 GW #17 (FDR 0.87); CD86 sec #10, FDR 1e-14 | CD86 secondary hit |
| Rank correlation | 0.66 / 0.71 / 0.45 / 0.62 (CD86 GW / CD86 sec / PDL1 GW / PDL1 sec) | |
| Top-25 overlap | 11 / 20 / 2 / 20 | |

## Where BARCS agrees and differs

- **Agrees.** In the genome-wide CD86 screen both methods find the same short list: the Cd86 positive control, its E3 ligase March1, Hspa5, Ubl3 and Chd4. In the secondary screens, which the paper uses to pick its regulators, 92 of the authors' 95 CD86 calls and 39 of their 44 PDL1 calls pass FDR 0.10 in BARCS, and the paper's lead gene Cebpb is called in both (raising CD86, lowering PD-L1), as is Med12 and much of the Mediator complex in the CD86 screen. Effect directions agree for 86–98% of genes.
- **PDL1 genome-wide screen.** With one library per bin and noisy libraries, BARCS calls nothing at FDR 0.10. Cd274 is still #2 and Cebpb #32; MAGeCK calls Cd274 alone (FDR 0.015). BARCS's pooled-control overdispersion is more conservative than MAGeCK's mean–variance fit across all guides here.
- **BARCS-only.** In the secondary screens BARCS adds 28 (CD86) and 42 (PDL1) genes, mostly further Mediator, SAGA (Tada2b, Tada3) and translation genes with consistent guides; the control null supports even more calls, so these are not calibration artefacts.

## Limits

- The genome-wide screens are noisy (within-repeat H/L correlation about 0.25) and the PDL1 one has a single repeat, so its calls are screening-level and BARCS calls nothing there.
- Repeats are not modelled as paired, because a repeat term would leave 1 residual df.
- The HMPCITE-seq single-cell experiments and the Cebpb-knockout BMDC screens (Supplementary Data 11–12, not in this series) are not reanalyzed.
