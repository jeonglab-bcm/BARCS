# GSE236244 reanalysis with BARCS 0.2.3

**Paper.** Barrero et al., "The interferon γ pathway enhances pluripotency and X-chromosome reactivation in iPSC reprogramming", *Science Advances* 10 (2024), PMID 39110794, doi:10.1126/sciadv.adj8862 (PMC11305397, open access). Supplementary Table S1 gives the MAGeCK RRA gene results for all five population comparisons.

**Screen.** A mouse genome-wide CRISPR knockout screen (~90,000 guides, up to 5 per gene, no non-targeting controls in the library) during female PaX-iCas9 NPC-to-iPSC reprogramming. At day 10 cells were FACS-sorted into non-pluripotent (SSEA1− X-GFP−), early pluripotent (SSEA1+ X-GFP−) and late pluripotent / X-reactivated (SSEA1+ X-GFP+), alongside the starting NPCs. The paper used MAGeCK RRA on negative log2FC: activators of a transition drop out in the more advanced population.

**Caveat for this series (replicates pooled).** The deposited MAGeCK count workbook has **one count column per population** (four sheets: NPC, Non-pluripotent, Early pluripotent, Late pluripotent). GEO lists two biological reprogramming rounds per population (8 GSMs), but the two rounds were summed into a single column, so there is **one library per condition**. The four columns are raw integers (~90 M reads each). With one library per condition there is no residual degrees of freedom, so `run_barcs.R` uses the no-replicate path: it pools an overdispersion across all guides (there are no non-targeting controls to pool over) and tests each guide at that value. This is deliberately conservative, and the calls are screening-level — between-replicate variation was not measured. Without controls, calibration and a control null cannot be built.

## Design

| Analysis | Comparison | Paper's meaning |
|---|---|---|
| **early_vs_nonplur** | early vs non-pluripotent | activators of early pluripotency (deplete) |
| **late_vs_early** | late vs early pluripotent | drivers of late pluripotency / X-reactivation (deplete) |
| late_vs_npc | late pluripotent vs NPC | overall reprogramming |

## Results

| Analysis | BARCS genes at FDR 0.10 | Spearman vs MAGeCK score | Direction agreement |
|---|---|---|---|
| early_vs_nonplur | 73 (depleted) | 0.51 | 82% |
| late_vs_early | 22 (depleted) | 0.69 | 72% |

Named hits (paper's validated / highlighted genes), BARCS rank of ~18,360 and effect (log-odds; negative = depleted = required):

Early vs non-pluripotent: Fut9 573 (−3.0), Smad4 605 (−1.7), Pou5f1 1838 (−1.8), Smad2 2790 (−1.0), Sox2 4212 (−1.6), Smarca4 4469 (−1.2), Hes1 5020 (−0.8). All seven deplete in the paper's direction; none reach FDR 0.10.

Late vs early (X-reactivation): Nanog 178 (−1.8, p 0.047), Il6st 185 (−0.8, p 0.051), Hes6 290 (−0.7, p 0.10), Spi1 596 (−0.2), Dazl 1020 (−0.1), Jak1 1180 (−0.3), Hes7 1193 (−0.4), Ifngr2 2356, Stat1 2464. Nine of ten deplete in the paper's direction; the IFNγ-pathway genes (Stat1, Jak1, Irf2, Ifngr2) rank mid-list, consistent with the paper's statement that they came from pathway (RRA) enrichment, not individually strong hits.

## Where BARCS agrees and differs

- **Agrees in direction and rough rank.** Gene scores correlate with MAGeCK at Spearman 0.51 (early) and 0.69 (late), and the paper's named pluripotency genes deplete in the expected direction. Nanog and Il6st are near the top of BARCS's late-vs-early list, matching the paper's X-reactivation drivers.
- **Does not confirm at FDR.** With one pooled library per condition, BARCS's conservative no-replicate test puts no named hit below FDR 0.10. BARCS's own strongest calls (Nf2, Agfg1, Trp53) are not the paper's headline genes; Trp53 tops the late-vs-early list, a classic reprogramming barrier whose loss accelerates iPSC formation.
- **Why they differ.** MAGeCK RRA ranks genes by the modified robust rank of their guides and gains power from the two replicates the deposited table does not expose; BARCS sees one library per condition and a single overdispersion, so it is far more conservative. The IFNγ pathway conclusion rests on pathway over-representation of the top 250 RRA genes, which is below what gene-level FDR in a one-library analysis can support.

## Limits

- One library per condition (replicates pooled in the deposit): no residual df, no replicate variance, screening-level calls only.
- No non-targeting controls: no calibration, no control null.
- The paper's pathway-level conclusions (IFNγ) cannot be reproduced as gene-level FDR calls.
