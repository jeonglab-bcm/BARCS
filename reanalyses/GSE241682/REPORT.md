# GSE241682 reanalysis with BARCS 0.2.3

**Paper.** "Systematic identification and characterization of exon-intron circRNAs", *Genome Research* (2024), PMID 38609186, doi:10.1101/gr.278590.123 (PMC11067877).

**Screen.** Genome-wide Brunello CRISPR knockout library (77,441 guides, 19,113 genes, 1,000 non-targeting controls) in two HEK293 EIciGFP reporter lines: P-In reports the EIciPAIP2 exon-intron circRNA, E-In the EIciEIF3J circRNA. GFP intensity tracks reporter-EIciRNA level. For each reporter, cells were sorted into input (bulk), high-GFP (top 10%) and low-GFP (bottom 10%); one library per sort, no replicates.

**Design.** Two analyses, high-GFP versus input for each reporter (`~ sort`, enriched term), the paper's main comparison: knockouts that raise EIciRNA (and thus GFP) are enriched in high-GFP, identifying negative regulators of EIciRNA biogenesis. With one library per condition the no-replicate path pools the overdispersion over the non-targeting guides (inflation 101 for P-In, 43 for E-In at rho = 0). **Calls are screening-level: variation between replicate sorted cultures was not measured.** The deposited count file is used unchanged; there is no gene-level MAGeCK table in the supplement (Table S5 is the sgRNA counts), so the comparison rests on the paper's named hits.

**Checks.** Non-targeting guides at p < 0.05 are 3.3% (P-In) and 4.3% (E-In), so BARCS is well calibrated and no control calibration was needed. Composition is flat (top 1% of guides hold 3.5-4.5% of reads), so library totals are appropriate. Controls sit within 0.1 z of the targeting guides.

## Results

| | P-In (EIciPAIP2) | E-In (EIciEIF3J) |
|---|---|---|
| BARCS genes at FDR 0.10 | 0 | 25 (33 against the control null) |
| Paper (MAGeCK) candidate genes, high-GFP | 854 | 709 (80 shared between reporters) |
| SRSF1 (validated hit) rank in BARCS | 2911 of 19,111 (p 0.38) | 239 of 19,112 (p 0.019, FDR 0.82) |
| SRSF2 / HNRNPK / SNRNP70 ranks | 12831 / 1216 / 8711 | 691 / 5468 / 2209 |

## Where BARCS agrees and differs

- **SRSF1 is recovered as enriched in both reporters but passes FDR in neither.** In E-In all four SRSF1 guides rise in high-GFP (e.g. 135->270, 253->462, 55->400), and BARCS places SRSF1 at #239 of 19,112 (top 1.3%, p 0.019). In P-In three of the four SRSF1 guides have zero input reads (0->99, 0->32, 0->0), leaving one usable guide, so SRSF1 lands mid-pack at #2911. SRSF1 is the only hit the paper validated (shRNA knockdown raised EIciGFP in both lines); BARCS confirms its direction but, with one library per condition, does not reach FDR 0.10.
- **The other named splicing RBPs rank low.** SRSF2, HNRNPK and SNRNP70 (shown among the paper's eight RNA-splicing RBPs) sit mid-to-low in the BARCS ranking in both reporters.
- **BARCS calls far fewer genes.** MAGeCK reported 854 (P-In) and 709 (E-In) high-GFP candidate genes from multi-guide RRA on single libraries; BARCS, treating each library as one measurement with a pooled overdispersion, calls 0 and 25 at FDR 0.10. The large candidate lists are not supported at the gene level without replicate sorts.

## Limits

- One library per sort, no replicates: the screen is screening-level, and BARCS is much more conservative than the paper's RRA candidate lists.
- No gene-level published table exists; the comparison uses the paper's named/validated hits only.
- Several SRSF1 guides in the P-In reporter have zero input counts, so that reporter resolves SRSF1 poorly; E-In is the more informative arm.
