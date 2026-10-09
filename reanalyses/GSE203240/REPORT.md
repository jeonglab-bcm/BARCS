# GSE203240 reanalysis with BARCS 0.2.2

**Paper.** "Identification of targetable vulnerabilities of PLK1-overexpressing cancers by synthetic dosage lethality", *Cell Genomics* (2025), PMID 40347943, doi:10.1016/j.xgen.2025.100876 (PMC12230241).

**Screen.** A secondary pooled knockout library of 211 guides (two per gene for 105 candidate synthetic-dosage-lethal genes from the authors' genome-wide shRNA screen, plus one non-targeting guide, "NT"). Cells with and without Cas9 were transduced, injected into mice and grown as tumours for three weeks; seven tumours per arm (two infections: four and three mice) plus two T0 pools per arm were sequenced. GEO labels the cells HCT116 (colon); the paper's text describes this in vivo screen in HCI-010 breast-cancer PDX-derived cells injected into the mammary fat pad. The mapping of columns to samples is certain (column names equal GSM titles), but the cell model is ambiguous between the two sources. The authors compared Cas9 with no-Cas9 tumours and report 15 hits at p < 0.05 (Table S7, a score, p-value and rank for the hits only; no full table).

**Design.** Cas9 vs no-Cas9 tumours at T1, `~ cas9`, 14 libraries (7 vs 7), 12 residual df. Infections are separate cell pools per arm, so there is no pairing term. Library totals; the libraries are not skewed (top 1% of guides hold 7–10% of reads in a 211-guide pool).

**Calibration.** There is only one non-targeting guide, so BARCS cannot calibrate to controls or build a control null, and the control check in `run_info.json` is empty. As a substitute, two within-arm null contrasts (infection 2 vs infection 1 among the no-Cas9 tumours, and among the Cas9 tumours, 4 vs 3 each) call 0 genes at FDR 0.10. The model is therefore not producing false calls from mouse-to-mouse noise. The single NT guide sits at +0.32 log fold change (more abundant in Cas9 tumours) while the median gene sits at −0.02. Cutting itself costs fitness, so the non-cutting guide rises relative to the targeting ones, and the 17 "enriched" calls (log fold changes +0.17 to +0.58, e.g. GSK3A, EMD) most likely mean "less cutting toxicity than average", not resistance.

## Results

| | BARCS | Paper (Table S7) |
|---|---|---|
| Genes at FDR 0.10 | 38 (21 depleted, 17 enriched); no control null (one control guide) | 15 hits at p < 0.05 |
| Sensitivity: median-ratio totals | 47 | |
| Sensitivity: interaction with T0 (`~ cas9 + time + cas9:time`, 18 libraries) | 15 | |
| IGF2BP2 (named hit) | #9 among depleted genes, log2-scale effect −1.57, FDR 1.6 × 10⁻⁶ | #6 of 15, p = 0.043 |
| C19orf35 (PEAK3) | #1 depleted, FDR 4 × 10⁻¹⁹ | #1 |
| ATP4A | #2, FDR 3 × 10⁻¹² | #2 |
| Paper's 15 hits at FDR 0.10 | 13/15 (all but LPL and KIF5B) | |
| Spearman with the paper's p-values (15 genes) | 0.34 | |

PEAK3 in the paper is C19orf35 in the count file (same Entrez ID, 374872).

## Where BARCS agrees and differs

- **Agrees.** IGF2BP2 is strongly depleted in every Cas9 tumour. Its abundant guide falls from 20,000–42,000 reads in no-Cas9 tumours to 1,700–5,200 in Cas9 tumours. The second guide falls from 200–2,000 to 59–263 in six tumours, with one jackpot (3,737 reads in Rep1 mouse 1). The call does not depend on that jackpot: the abundant guide alone is decisive. The paper's top two (PEAK3/C19orf35, ATP4A) are BARCS's top two, and 13 of its 15 hits pass FDR 0.10.
- **BARCS is more confident than the paper.** The authors' p-values for their hits range from 5 × 10⁻⁴ to 0.05. BARCS gives FDRs below 10⁻⁶ for its top ten, because 7 vs 7 tumours with 12 residual df and very deep counts (tens of thousands of reads per guide) leave little sampling noise. ATP4A rests mainly on one abundant guide that nearly vanishes in Cas9 tumours (17,000–41,000 → 1–1,237 reads); its second guide is sparse and noisy.
- **Differs.** LPL and KIF5B, the paper's weakest hits (scores −0.49 and −0.40), do not move in BARCS (FDR 0.98 and 0.92). Their guides have equal counts in both arms. BARCS adds ZBTB7A (#10, FDR 2 × 10⁻⁴), RCE1, KRT6B, CDCA7, MAP1S, SLC35E2, FZD4 and RAVER1. Several of these (SLC35E2, RAVER1, TLE2, SASS6) are supported by only one of their two guides.

## Limits

- One non-targeting guide: no control calibration and no control null. Within-arm null contrasts are the only calibration check.
- Two guides per gene, and the "enriched" side reflects the cutting-toxicity offset rather than biology.
- GEO and the paper disagree on the cell model (HCT116 vs HCI-010 PDX cells).
- The published table lists only the 15 hits, so rank correlation and overlap are computed on those genes alone.
