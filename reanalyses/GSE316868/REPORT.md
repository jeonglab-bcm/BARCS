# GSE316868 reanalysis with BARCS 0.2.1

**Paper.** "The Cyclin C-CDK8/19 Mediator kinase module controls PRCC-TFE3 driven senescence in renal epithelium and tumorigenesis in TFE3-RCC", *Neoplasia* (2026), PMID 41843980, doi:10.1016/j.neo.2026.101296 (PMC13069303).

**Screen.** HK-2 renal epithelial cells with doxycycline-inducible PRCC-TFE3 and the Brunello library (77,441 guides). Inducing the fusion causes oncogene-induced senescence, so knockouts that let cells escape it should be enriched. There were two independent runs, each a Dox− vs Dox+ pair. The authors deposited a MAGeCK gene summary.

**Design.** `~ run + dox`, 4 libraries, **1 residual df**, `test = "auto"`. One control library (Doxy−_2) has 42% zero-count guides, against 16–21% in the others.

## Results

| | BARCS | Authors' MAGeCK |
|---|---|---|
| Genes at FDR 0.10 | 0 | 0 (lowest FDR 0.35) |
| CCNC | rank 1,521, p = 0.21 | positive rank 8 |
| CDKN1A (p21) | rank 2, p = 8 × 10⁻⁵ | |
| MED12 | rank 8, p = 0.002 | positive rank 237 |
| Top-25 overlap | 0 of 25 | |
| Rank correlation | 0.35 | |

## Where BARCS agrees and differs

- **Neither method finds significant genes.** One residual degree of freedom leaves almost no information about guide-level variance, and BARCS's t reference reflects that.
- **CCNC is missed, and this is a BARCS failure.** Three of four CCNC guides have zero or near-zero reads in both control libraries and 40–480 reads in both induced libraries, a consistent signal. Two problems lose it:
  1. **Complete separation.** Two guides with all-zero controls send the logistic estimate toward infinity (about 120 log-odds). They are flagged as non-converged and dropped from the gene summary.
  2. **Over-moderation.** The remaining guides are shrunk toward the library-wide variance inflation, about 150. One heavily bottlenecked control library (42% zero guides) sets that level, and the shrinkage overrides the guides' own low variance (0.45).
  - **Planned fix:** keep separated guides by using the likelihood-ratio statistic at the boundary, and use a robust prior for moderation.
- **Plausible top genes.** CDKN1A, the classic senescence effector, ranks second. MED12, another subunit of the same Mediator kinase module, ranks eighth and partly supports the paper's module-level conclusion.

## Limits

- Two runs only.
- One library has a large dropout fraction.
- The paper validates CCNC with independent knockouts and drugs, which a screen reanalysis cannot weigh.
