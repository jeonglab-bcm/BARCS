# GSE294894 reanalysis with BARCS 0.2.3

**Paper.** "A whole genomic CRISPR-Cas9 screen identifies the amino acid transporter SLC43A1 (LAT3) as a major determinant of oxaliplatin sensitivity in colorectal cancer cells", *Molecular Cancer Therapeutics* 2026, PMID 42227585 (PMC13317012, doi 10.1158/1535-7163.MCT-25-0508).

**Screen.** Genome-wide Brunello knockout and Calabrese activation screens in RKO and SW620 colorectal cancer cells: day 0, day 20 untreated (T20) and day 20 oxaliplatin (RKO 1.9 uM; SW620 0.38 and 0.5 uM). GEO deposits one MAGeCK count table per screen (`*.count.txt.gz`, raw integers; the `count_normalized` files were ignored). Column names (T0, T20, OXAL, OXAL038, OXAL050) match the GSM titles.

**Paper's analysis.** MAGeCK 0.5.7 `test`, oxaliplatin vs T0 or T20, normalized to non-targeting guides. No gene-level table is published; the paper reports SLC43A1 as the most enriched gene in both knockout screens and depleted in both activation screens.

**Design.** Oxaliplatin vs T20 untreated, one analysis per screen and dose (the two SW620 doses are separate cultures, not replicates). **One library per condition, no replicates**: BARCS uses the no-replicate path (overdispersion pooled over the non-targeting guides; 1000 in Brunello, 496 in Calabrese), so the calls are screening-level and the FDR does not include variation between replicate cultures. SLC43A1 guides alone hold about 17% of the RKO knockout OXAL library (top 1% of guides: 41% of reads), so median-ratio totals are used and enrichment is read first. Primary analysis: RKO knockout (`design.json`); the other three screens are in `design_*.json`.

## Results

| Screen | Ctrl p<0.05 raw / used | Top 1% share (T20 / OXAL) | FDR 0.10 (up / down) | Control null | SLC43A1 |
|---|---|---|---|---|---|
| RKO KO, 1.9 uM | 4.7% / 4.7% | 3.9% / 41% | 67 / 1 | 8 (controls) | **#1 enriched, FDR 4e-76** |
| SW620 KO, 0.38 uM | 5.8% / 5.8% | 3.2% / 9.6% | 23 / 0 | 4 (centred on targets) | **#1 enriched, FDR 2e-135** |
| SW620 KO, 0.5 uM | 8.2% / 5.0% (calibrated) | 3.2% / 32% | 4 / 0 | 0 (centred on targets) | **#1 enriched, FDR 5e-28** |
| RKO activation | 12.9% / 5.0% (calibrated) | 2.7% / 53% | 13 / 0 | 546 (centred on targets, offset; not quoted) | not called (p 0.70) |
| SW620 act., 0.38 uM | 1.0% / 1.0% | 2.4% / 7.2% | 16 / 0 | 43 | not called (p 0.60) |
| SW620 act., 0.5 uM | 2.2% / 2.2% | 2.4% / 10% | 54 / 0 | 81 | not called (p 0.18) |

**Knockout screens.** SLC43A1 is the top enriched gene in all three knockout analyses, with all four guides rising from hundreds of reads to 0.3-2.1 M reads. The rest of the RKO list is coherent DNA-damage/p53 biology: CDKN1A #2, WDR20 #3, TP53 #4, MAPK14 #5, MAP2K3, RB1, KEAP1. WDR20 is #2-3 in all three knockout analyses. CTAGE8 (#15) is a jackpot call (one guide 1094 -> 88,866 reads, two others falling) and should be discounted. The control null is small (8, 4, 0) because with one library per condition the control-derived pseudo-genes cannot confirm more than the strongest hits; read it as "controls confirm SLC43A1 and a few others", not as a short list of true hits.

**Activation screens.** BARCS does not reproduce SLC43A1 depletion. In RKO the three SLC43A1 guides fall from 930/138/389 reads to 0/0/0; in SW620 they start low (62/75/25 -> 2/17/0 at 0.5 uM). Guides that drop to zero get an unbounded Wald standard error and the 100-fold likelihood-ratio switch does not trigger for depletion to zero under strong-selection median-ratio totals, so a real depletion is reported as p 0.70. The RKO activation OXAL library is dominated by a few guides (top 1% hold 53% of reads; 12.9% of controls at p < 0.05 before calibration), so its depletion side is not interpretable in any case; no gene is called depleted in any activation screen. The enriched activation calls (NEUROD2, LCE1C, FMO3, RNF122, ZP2) are single-culture outgrowths the paper does not discuss.

## BARCS vs paper
Agree on the paper's main claim: SLC43A1 knockout is the strongest oxaliplatin-resistance hit in both RKO and SW620, at rank 1 in every knockout analysis. The activation-screen depletion the paper also cites is visible in the raw counts but not called by BARCS (zero counts, strong composition shift, sparse SW620 guides). No published gene table exists to compare list lengths.

## Limits
One library per condition: screening-level calls with no replicate culture variance. Strong selection (median-ratio totals) makes depletion hard to read, especially in the RKO activation screen. The paper normalized to non-targeting controls; BARCS used median-ratio totals because of the composition shift.
