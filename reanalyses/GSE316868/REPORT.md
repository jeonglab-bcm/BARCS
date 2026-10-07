# GSE316868 reanalysis with BARCS 0.2.1

**Paper.** "The Cyclin C-CDK8/19 Mediator kinase module controls PRCC-TFE3 driven senescence in renal epithelium and tumorigenesis in TFE3-RCC", *Neoplasia* (2026), PMID 41843980, doi:10.1016/j.neo.2026.101296 (PMC13069303).

**Screen.** HK-2 renal epithelial cells with doxycycline-inducible PRCC-TFE3 and the Brunello library (77,441 guides, 1,000 non-targeting). Inducing the fusion causes oncogene-induced senescence, so knockouts that let cells escape it are enriched. There were two independent runs, each a Dox− vs Dox+ pair. The authors deposited a MAGeCK gene summary.

**Design.** `~ run + dox`, 4 libraries, 1 residual df, `test = "auto"`. One control library (Doxy−_2) has 42% zero-count guides, so many guides have no reads in a control.

**Calibration.** 9.1% of non-targeting guides reached p < 0.05 before calibration; 5.0% after, with none below p = 0.001. Pseudo-genes built from four control guides each gave 4.0% at p < 0.05 and 0.1% at p < 0.001, so the gene-level null holds.

## Results

| | BARCS 0.2.1 | Before the Firth fix | Authors' MAGeCK |
|---|---|---|---|
| Genes at FDR 0.10 | 1,151 | 0 | 0 (lowest FDR 0.35) |
| CCNC | **#137, FDR 0.005** | #1,521, p = 0.21 | positive rank 8 |
| CDKN1A (p21) | #340, FDR 0.02 | #2 | |
| MED12 | #420, FDR 0.03 | #8 | positive rank 237 |
| Top genes | EIF6, MYC, … | | MYC, EIF6, … |
| Rank correlation with MAGeCK | 0.51 | 0.35 | |
| Top-100 overlap with MAGeCK | 37 | 6 | |

## What changed

The CCNC data are clear: three of four guides have zero or near-zero reads in both control libraries and 40–480 reads in both induced libraries. In BARCS 0.2.0 those guides were *completely separated*: with no reads in one condition the logistic estimate has no finite value, the fit did not converge, and the guides were dropped. BARCS 0.2.1 refits separated guides with Firth's correction, so they are kept with finite estimates. Across the screen this restored about 5% of guides, many of them strongly affected ones in the sparse control library.

## Where BARCS agrees and differs

- **Agrees.** CCNC is enriched in induced cells at FDR 0.005, and the two strongest genes (EIF6, MYC) are also MAGeCK's top two.
- **More calls.** BARCS calls 1,151 genes where MAGeCK calls none at FDR 0.10. The control-guide checks above indicate the excess is signal. Even so, one residual df and a heavily bottlenecked control library mean the long tail should be confirmed independently.

## Limits

- Two runs only.
- One control library has 42% zero-count guides.
- CDK8 is not in the library under that symbol.
