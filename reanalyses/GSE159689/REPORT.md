# GSE159689 reanalysis with BARCS 0.2.3

**Paper.** Romine et al., "Monocytic differentiation and AHR signaling as primary nodes of BET inhibitor response in acute myeloid leukemia", Blood Cancer Discovery (2021), PMID 34568834, doi:10.1158/2643-3230.BCD-21-0012 (PMC8462123). Only the abstract was accessible (the PMC copy serves no body text and the PDF is blocked), so the comparison uses the genes it names; no gene-level table could be retrieved.

**Screen.** Yusa human knockout library (about 90,700 guides, 5 per gene, no non-targeting controls) in BETi-sensitive parental OCI-AML2 cells and in JQ1-resistant OCI-AML2 cells, treated with JQ1 or DMSO for 14 days. Each day-14 library was sequenced twice; the re-reads agree near the Poisson level (dispersion index 2-3, Spearman 0.97-0.98), so prepare.R sums them. The abstract names SPI1, JUNB, FOS and AHR/ARNT as determinants of response (resistance when lost) and BCL2 and CDK6 as vulnerabilities in resistant cells.

**Design.** Two analyses, `~ treatment`, JQ1 vs DMSO: parental (2 vs 2, enrichment = resistance) and JQ1-resistant (2 vs 3, depletion = re-sensitization). Arms are separate cultures, no pairing term. The day-21 CPI-0610 arm is not analyzed.

**Checks.** No controls, so calibration and the control null could not be checked. Parental JQ1 libraries are skewed (top 1% hold 20-24% of reads vs 13-14% for DMSO).

## Results

| | BARCS 0.2.3 | Authors (abstract) |
|---|---|---|
| Parental, genes at FDR 0.10 | 1 enriched | resistance genes SPI1, JUNB, FOS, AHR/ARNT |
| FOS / SPI1 | #5 (p 0.007) / #75 (p 0.07), FDR 1 | named |
| JUNB / ARNT / AHR | #3,756 / #2,610 / #11,315 | named |
| Resistant, genes at FDR 0.10 | 2,750 (795 enriched, 1,955 depleted) | BCL2, CDK6 as vulnerabilities |
| BCL2 / CDK6 (depleted) | #280, FDR 0.009 / #4,405, FDR 0.29 | named |

## Where BARCS agrees and differs

- **Partly agrees.** In parental cells FOS (#5) and SPI1 (#75) lead the enrichment the right way, but with two libraries per arm and a skewed JQ1 composition nothing except one gene passes FDR 0.10; JUNB, AHR and ARNT show no enrichment in these counts. In resistant cells BCL2 is a clear depleted call (FDR 0.009), CDK6 is not.
- **The resistant-line call count is not trustworthy.** 2,750 genes at FDR 0.10 with no controls to calibrate against is far more than a re-sensitization screen supports; the strongest ones (BCOR, CAND1, FLCN, TP53) are general fitness modifiers under JQ1. The AHR result in the paper also rests on Beat AML data and drug experiments, which this reanalysis does not cover.

## Limits

- No controls; two libraries per arm in parental cells; paper body and supplementary tables not accessible.
