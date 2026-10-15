# GSE270368 reanalysis with BARCS 0.2.3

**Paper.** "Reciprocal inhibition of NOTCH and SOX2 shapes tumor cell plasticity and therapeutic escape in triple-negative breast cancer", *EMBO Molecular Medicine* (2024), PMID 39478150, doi:10.1038/s44321-024-00161-8 (PMC11628624).

**Screen.** A genome-wide GeCKO v2 (A+B, 119,461 guides, 1,000 non-targeting) knockout screen in GSI-resistant MB157R triple-negative breast cancer cells. Cells were treated for 14 days with the gamma-secretase inhibitor LY3039478 (GSI) or DMSO, three replicates each, with two T0 libraries. The authors ran MAGeCK test (RRA) on GSI vs DMSO and defined hits as p < 0.001 and |log2 fold change| > 1 (Dataset EV2). SOX2, ranked 11th among negatively selected genes, is the paper's subject. `prepare.R` converts Dataset EV2 to `paper/mageck_gsi_vs_dmso.tsv`. The count file is the GEO file as deposited.

**Design.** GSI vs DMSO, `~ treatment`, 3 vs 3, 4 residual df. Library depth is low for the library size: 12–18 M reads for 119,461 guides, median about 80–110 reads per guide. Replicates agree poorly (Spearman 0.64–0.75 between libraries).

**Composition.** One guide, HGLibB_53702 (VPS33B), holds 7.1 M reads in LY.1, 39% of that library. It is already over-represented in every library, T0 included (about 230,000 reads). HGLibB_21751 (HNF4A) behaves the same way, and together they put 48% of LY.1's reads on its top 1% of guides. With library totals, every other guide in LY.1 would look depleted, so the analysis uses median-ratio totals (`"totals": "median_ratio"`). Non-targeting guides then sit at 2.3% p < 0.05, so no calibration was applied. Moderation fully pools the dispersion trend (prior df infinite). The guide correlation is 0.003.

## Results

| | BARCS 0.2.3 | Authors' MAGeCK RRA (Dataset EV2) |
|---|---|---|
| Genes at FDR 0.10 | 3 (VPS33B, RBM44 enriched; HNF4A depleted), all driven by one jackpot guide each; 11 against the control null | 0 at FDR 0.10 (lowest neg FDR 0.79); 5 negative hits by p < 0.001 and LFC < -1 (EPHA1, LRRC34, SOX2, INTS4, PTK6) |
| SOX2 | depleted #1,462 of 20,706, p 0.14, FDR 1 | neg rank 11, p 5.8e-4, FDR 0.83, LFC -1.32 |
| Rank correlation (depletion score) | 0.54 | |
| Top-25 / top-50 overlap | 5 / 11 | |

## Where BARCS agrees and differs

- **Neither analysis finds genome-wide significant hits.** The authors' MAGeCK assigns no gene an FDR below 0.79. Its hit list is a p-value and fold-change cut, and SOX2 passes it. BARCS's three FDR calls each come from a single guide with a jackpot count in LY.1: VPS33B HGLibB_53702, HNF4A HGLibB_21751 and RBM44 HGLibB_40506. Every other guide for those genes is flat, so the calls are artifacts and BARCS has no credible calls.
- **SOX2.** Two of SOX2's six guides are about 2-fold lower under GSI (p 0.06 each), one is weaker, and three are flat or slightly higher. At about 50–100 reads per guide and with noisy replicates, the gene-level evidence is weak (p 0.14). MAGeCK's RRA ranks genes by their best guides and reports a median LFC of -1.32, so it puts SOX2 near the top of an otherwise null list. The paper's case for SOX2 rests on the follow-up experiments, not on screen significance.

## Limits

- The jackpot guides in LY.1 (and their presence at high abundance in T0) suggest a contaminating or pre-amplified construct. Median-ratio totals protect the other guides, but LY.1 remains the noisiest library.
- Low read depth per guide and replicate correlations of 0.64–0.75 limit power. The screen as deposited cannot support genome-wide calls.
