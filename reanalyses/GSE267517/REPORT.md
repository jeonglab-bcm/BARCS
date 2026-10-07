# GSE267517 reanalysis with BARCS 0.2.1

**Paper.** "Tumor Intrinsic METTL5 Modulates ATF4 Translation to Prevent T Cell-Induced Ferroptosis in Ovarian Cancer", *Advanced Science* (2025), PMID 41042068, doi:10.1002/advs.202507718 (PMC12697795).

**Screen.** ID8/GC mouse ovarian cancer cells with a genome-wide library (about 90,000 guides). The cells were cultured with gp100-specific pmel T cells at effector:target 1 or 0.2, or without T cells. The authors deposited MAGeCK gene summaries for both comparisons.

**Design.** `~ treatment`, ET1 (3 libraries) vs no T cells (4), 5 residual df, `test = "auto"`. ET0.2 vs no T cells was also run. The in vivo anti-PD-1 sub-library screen in the same series is a separate count file and was not reanalyzed.

## Results (ET1 vs control)

| | BARCS | Authors' MAGeCK |
|---|---|---|
| Top protective (enriched) | B2m #1, Jak1 #4, H2-D1, Jak2, Tap1, Tap2 | B2m pos rank 1 |
| Top sensitizing (depleted) | Rnf31 #6, Cflar | Rnf31 neg rank 1 |
| Mettl5 | depleted, p = 0.012, FDR 0.23, rank 927 | neg rank 312, p = 0.012 |
| Top-25 overlap | 20 of 25 shared | |
| Rank correlation | 0.50 | |

At ET0.2 the signal is weaker (30 genes at FDR 0.10). It is led by the TNF-survival module: Cflar, Rnf31, Traf2, Fadd, Map3k7, Ikbkg, Rela, Rbck1.

## Where BARCS agrees and differs

- **Agrees.** Both methods find the expected biology. Loss of antigen presentation (B2m, H2-D1, Tap1/2) or interferon signaling (Jak1/2) protects tumor cells. Loss of LUBAC/NF-κB survival genes (Rnf31, Rbck1, Cflar, Traf2) sensitizes them to T-cell killing.
- **Mettl5 is a modest screen hit in both.** It is depleted, as the paper reports, but well outside the top hundred. The paper chose it by integrating the screen with clinical data, which this reanalysis cannot test.

## Limits

- Pairing between control and T-cell cultures is not documented, so the comparison is unpaired.
- The in vivo anti-PD-1 screen was not reanalyzed.
