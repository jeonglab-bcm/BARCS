# GSE230735 reanalysis with BARCS 0.2.3

**Paper.** "Itaconate uptake via SLC13A3 improves hepatic antibacterial innate immunity", *Developmental Cell* (2024), PMID 39116875, doi:10.1016/j.devcel.2024.07.011.

**Screen.** A custom CRISPRi membrane-transporter library (7,441 sgRNAs, 1,241 genes; Corus Biotechnology) in 293T cells expressing the cBioITA itaconate fluorescent biosensor. After 1 h of 3 mM itaconate, cells were FACS-sorted by cBioITA intensity into a bottom (lowest 25%) and a top (highest 25%) population. The screen was used to find the itaconate importer.

**Design.** Top versus bottom (`~ condition`, depleted term for the importer). Each sort bin was sequenced twice (Bottom-1/Bottom-2, Top-1/Top-2); the two reads of a bin are technical re-sequencing of one sort (log-count correlation 0.995 for Top, 0.998 for Bottom, with a near-constant depth ratio of 1.4-1.5), so `prepare.R` sums them into one library per bin, leaving one library per condition. The no-replicate path pools the overdispersion (inflation 77 at rho = 0). The library has no non-targeting controls, so overdispersion is pooled over all guides (conservative) and the FDR is uncalibrated and has no control null. **Calls are screening-level: variation between replicate sorted cultures was not measured.**

## Results

| | BARCS 0.2.3 |
|---|---|
| SLC13A3 (the importer) | #1 of 1,241, estimate -1.75 (depleted in top / enriched in bottom), p 1.1e-88, FDR 1.4e-85 |
| Genes at FDR 0.10 | 3 (SLC13A3, ABCG2, RACK1) |

## Where BARCS agrees and differs

- **The paper's single screen hit is BARCS's #1 gene.** SLC13A3, identified by the authors as the itaconate importer, is the top-ranked and overwhelmingly most significant gene. Its knockdown lowers itaconate uptake and cBioITA fluorescence, so its guides are strongly enriched in the bottom bin: five of six guides drop sharply from bottom to top (e.g. 28,910->2,188; 41,232->1,357; 29,029->1,793). The effect is guide-consistent, not a single-clone jackpot.
- **Few other genes.** Only ABCG2 and RACK1 also reach FDR 0.10 (both enriched in top); the paper did not pursue them. The screen was designed and reported around SLC13A3, and BARCS agrees.

## Limits

- One effective library per bin after summing the technical re-reads, no replicates: the reanalysis is screening-level, and with no control guides the FDR is uncalibrated. The SLC13A3 result is nonetheless unambiguous (FDR ~1e-85).
- The paper (Cell Press, not open access) deposited no gene-level screen table, so the comparison rests on its named hit SLC13A3.
