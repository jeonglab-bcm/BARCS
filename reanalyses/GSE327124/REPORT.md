# GSE327124 reanalysis with BARCS 0.2.1

**Paper.** "Virus-like particles enable targeted gene engineering and pooled CRISPR screening in primary human myeloid cells", *Nature Biotechnology* (2026), PMID 42608566, doi:10.1038/s41587-026-03258-2. The paper is not open access, so the comparison uses the abstract.

**Screen.** Primary human monocyte-derived macrophages with a transcription-factor knockout library (6,000 guides, 1,351 genes, 593 non-targeting). The cells were stimulated with LPS and sorted into CD80-high and CD80-low bins, from four donors.

**Design.** `~ donor + bin`, 8 libraries, 3 residual df. The high and low bins of each donor come from one infected population, so donor is a blocking term. Donors 1–2 and 3–4 cluster apart (log-count correlation about 0.53), consistent with two experiments; the donor term absorbs this.

## Results

| | Value |
|---|---|
| Genes at FDR 0.10 | 9 (4 enriched in CD80-high, 5 depleted) |
| TNFAIP3 | **rank 1**, enriched in CD80-high, FDR 2 × 10⁻⁶ |
| Next | CD274, JUN, IRF8, IRF9, JDP2, HLA-DRA, TGIF1 |
| Guide correlation | 0.010 |

## Where BARCS agrees and differs

- **Agrees.** TNFAIP3 (A20), the paper's central regulator, is the strongest gene. Losing it raises CD80, consistent with A20's role as a brake on NF-κB.
- **Biologically coherent neighbors.** IRF8, IRF9 and JUN are plausible regulators of an LPS-induced costimulatory program. CD274 and HLA-DRA are probably co-regulated surface markers that sort with CD80, not causal regulators.
- **Conservative.** Few genes pass FDR 0.10, as expected from a sort screen with 4 donors and a modest effect size.

## Limits

- No published gene table was available.
- The TNF screen (2 donors) was not reanalyzed.
