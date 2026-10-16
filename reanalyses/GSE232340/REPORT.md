# GSE232340 reanalysis with BARCS 0.2.3

**Paper.** Flugel and colleagues, "A genome-wide in vivo CRISPR screen identifies essential regulators of T cell migration to the CNS in a multiple sclerosis model", *Nature Neuroscience* (2023), PMID 37709997, doi:10.1038/s41593-023-01432-2 (PMC10545543).

**Screens.** Encephalitogenic Lewis-rat CD4+ T-MBP cells were edited with a genome-wide library (87,690 guides, up to 4 per gene, 800 non-targeting), transferred into rats, and recovered on day 3 from blood, spleen, spinal-cord leptomeninges and parenchyma of three animals (R1-R3). A validation library (12,000 guides, up to 6 per gene, 241 non-targeting) against the candidates was run the same way. The authors ran MAGeCK on pairwise tissue comparisons; genes needed for entry into the CNS are depleted in parenchyma and meninges relative to blood. Counts are the GEO files, integer reads, columns self-named by animal and tissue (confirmed against the GSM descriptions).

**Design.** `~ rat + tissue`, parenchyma (and meninges) vs blood, 6 libraries, 2 residual df. Each animal's tissues come from one transferred cell pool, so rat is a paired term (the tissues of one animal correlate 0.94-0.97, far more than across animals). The depletion coefficient matches the authors' MAGeCK neg|lfc. The primary analysis is the genome-wide parenchyma-vs-blood screen (design.json); meninges-vs-blood and the validation parenchyma-vs-blood screen (design_validation.json) are also run.

**Checks.** Control calibration is clean (non-targeting guides at p < 0.05: 5.8% genome-wide, 3.7% validation). One library, R3Blood, is jackpotted (its top 1% of guides hold 24% of reads) from the small number of T cells recovered from blood; the other libraries are flat (4-5%). Guide correlation 0.007-0.012. In the genome-wide screen the controls sit +0.21 z from the targeting guides and the control-null count (33) rests on a mis-centred null of random genes, not the paper's hits, so it is not quoted as a hit list.

## Results

| | BARCS 0.2.3 | Authors' MAGeCK (neg|fdr < 0.10) |
|---|---|---|
| Genome-wide, parenchyma vs blood | 0 genes at FDR 0.10; Itga4 #1, Grk2 #8, Fermt3 #12, Cxcr3 #30 (all depleted) | 22 genes |
| Genome-wide, meninges vs blood | 0 genes at FDR 0.10; Itga4 #1, Cxcr3 #4, Fermt3 #6, Grk2 #8 | 9 genes |
| Validation, parenchyma vs blood | 22 genes at FDR 0.10 (24 control null) | 20 genes |
| Named hits (validation) | Itga4 #1 (FDR 4e-9), Cxcr3 #3, Fermt3 #4, Grk2 #7, Cbfb #12 (FDR 0.01); all at FDR 0.10 | all hits |
| Validation top-10 overlap | 8 / 10 | |
| Validation rank correlation | 0.47 | |

## Where BARCS agrees and differs

- **Validation screen: agrees.** All five named migration regulators (Itga4, Cxcr3, Fermt3, Grk2, Cbfb) pass FDR 0.10 in BARCS, with Itga4, Fermt3 and Cxcr3 as the three strongest genes, matching the authors. 8 of the top 10 are shared.
- **Genome-wide screen: hits recovered in ranking, not at FDR 0.10.** BARCS ranks Itga4 #1 and Grk2, Fermt3, Cxcr3 inside the top 30 of 21,700 genes, all depleted, but with only 2 residual df, real in-vivo animal-to-animal variation and a jackpotted blood library, no gene clears FDR 0.10. MAGeCK's permutation p-values and RRA call 22 (parenchyma) and 9 (meninges). The low rank correlation (0.40) and 55% direction agreement reflect the bulk of near-null genes, not the top hits, which the two methods rank the same way.

## Limits

- The genome-wide screen has three animals (2 residual df) and one jackpotted blood library; BARCS confirms the paper's hits only in ranking there, not at FDR 0.10. The validation screen, with 6 guides per gene over fewer genes, confirms them at FDR 0.10.
- Only parenchyma/meninges vs blood are reanalyzed; the spleen and culture-vs-plasmid comparisons are not.
