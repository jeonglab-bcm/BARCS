# GSE192828 reanalysis with BARCS 0.2.3

**Paper.** Mamedov et al., "CRISPR screens decode cancer cell pathways that trigger γδ T cell detection", *Nature* (2023), PMID 37648854, doi:10.1038/s41586-023-06482-x (PMC11003766).

**Screen.** Genome-wide knockout library (90,709 guides over 18,009 genes; no non-targeting guides) in Daudi-Cas9 cells. The library was co-cultured with primary Vγ9Vδ2 T cells from three donors (E:T 1:4, 1:4 and 1:2); surviving cells were compared with the pre-kill population. The counts are the GEO file as deposited: integer reads, columns named by condition and donor. The authors ran MAGeCK RRA; their gene table is Supplementary Table 1, which `prepare.R` downloads unchanged.

**Design.** `~ condition`, killing (3 donor co-cultures) vs pre-kill (1 library), 2 residual df (prior df 19.6 after moderation). Donors are replicates of the killing arm only; there is one pre-kill library, so no pairing term. The pre-kill library is taken before co-culture, so depletion mixes sensitization to γδ killing with ordinary fitness loss during the co-culture: most of the 2,335 depleted calls are core-essential genes (CCND3, TPI1, ARFRP1, BRF1), as in the authors' table (1,912 negative calls at FDR 0.10). The comparison therefore uses enrichment (knockouts that protect from killing), which is the paper's focus.

**Calibration.** The library has no non-targeting or safe-harbour guides, so control calibration and the control null could not be checked. Composition is flat (top 1% of guides hold 3.4–4.3% of reads). Guide correlation 0.004; 1,013 guides were tested by likelihood ratio. The top enriched genes are carried by all of their guides (direction agreement 1.0), so no jackpot artefact drives them.

## Results

| | BARCS 0.2.3 | Authors' MAGeCK RRA (Supp. Table 1) |
|---|---|---|
| Enriched genes at FDR 0.10 | 120 | 71 (pos\|fdr < 0.10) |
| Depleted genes at FDR 0.10 | 2,335 (mostly fitness genes) | 1,912 |
| BTN3A1 | #1 enriched, FDR 3.5e-17 | #1 |
| SPIB / IRF1 | #2 / #3 | #2 / #3 |
| BTN2A1 / BTN3A2 | #5 / #7 | top 10 |
| NLRC5 | #9, FDR 2e-6 | #8 |
| HMGCR (mevalonate) | #64, FDR 0.04 | FDR 0.04 |
| Rank correlation (enrichment score) | 0.80 | |
| Top-25 / top-50 overlap | 20 / 37 | |
| Shared enriched calls | 60 of the paper's 71 | |

## Where BARCS agrees and differs

- **Agrees.** The top of both lists is the same: BTN3A1, SPIB, IRF1, FBXW7 are #1–4 in both, and BTN2A1, BTN3A2, NLRC5 and the MHC-I/IFN regulators (RFXAP, SPI1, IRF8, JAK1, STAT1) follow. All seven named hits pass FDR 0.10 in BARCS. ZNF217, the negative BTN3A regulator, is depleted in both (BARCS FDR 6e-8; MAGeCK neg|fdr 0.025).
- **Paper-only.** 11 of the authors' 71 enriched calls miss FDR 0.10 in BARCS; GLA and SGMS1 sit just above it (0.101, 0.103), the rest (PRKD3, GFI1, LRBA, CDK5 ...) have weaker or inconsistent guides across donors.
- **BARCS-only.** 60 extra enriched calls with modest effects but consistent guides, mostly from the same interferon/MHC and sterol (ACAT2, SQLE, MYLIP) programmes the paper describes. BARCS uses donor-to-donor variation and moderated dispersion; MAGeCK RRA ranks guides with permutation p-values and pools the replicates.

## Limits

- One pre-kill library and no untreated co-culture arm: depletion is dominated by fitness effects and is not a clean sensitizer readout.
- No control guides, so calibration could not be checked; the FDR rests on the model alone.
- Only the killing screen is in this series; the BTN3A surface-expression sort screen is not reanalyzed.
