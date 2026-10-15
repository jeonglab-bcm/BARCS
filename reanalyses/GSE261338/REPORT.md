# GSE261338 reanalysis with BARCS 0.2.3

**Paper.** Truong et al., "TOPORS E3 ligase mediates resistance to hypomethylating agent cytotoxicity in acute myeloid leukemia cells", *Nature Communications* (2024), PMID 39198401, doi:10.1038/s41467-024-51646-6 (PMC11358519).

**Screen.** A genome-wide Brunello knockout screen in MDS-L cells (Cas9). Cells were sampled at T0 and after 19 days of azacitidine (AZA) or DMSO, two replicates each. The AZA arm went through about 12 divisions and the vehicle arm about 18. The authors ran MAGeCK MLE with MAGeCKFlute cell-cycle normalization and picked AZA-specific genes from a nine-square plot of the two arms' beta scores (Supplementary Data 2). TOPORS, UBE2K and UBXN7 were validated as AZA sensitizers, and TOPORS is the paper's subject.

**Counts.** The GEO count file is a gzipped binary `.xls` that stops at the old Excel limit of 65,535 rows. So 65,535 of the 77,441 Brunello guides are present (19,040 genes; the paper's Supplementary Data 1 is cut the same way). The missing guides are spread across genes: most genes keep three or four guides. `prepare.R` converts the sheet to a tab-separated file without changing the counts. It also writes the paper's beta scores to `paper/beta_scores.tsv`, with `diff` = AZA beta minus DMSO beta. The authors ran their MLE on the full library (19,112 genes).

**Design.** AZA vs DMSO at T19, `~ condition`, 2 vs 2 libraries, 2 residual df (prior df 37.5 after moderation). Nothing marks the replicates as paired across arms, so the model has no replicate term.

**Calibration.** Before calibration, 21% of the 982 non-targeting guides reached p < 0.05, so `run_barcs.R` calibrated to the controls (scale 1.64; 5.0% afterwards). This shortens the hit list. Composition is flat: the top 1% of guides hold 3.8–4.5% of reads. The guide correlation is 0.006. Controls sit +0.27 z from the targeting guides, so the control null was centred on the targeting guides. It gives 519 genes, close to the model's 516.

## Results

| | BARCS 0.2.3 | Authors' MAGeCK MLE (Supp. Data 2) |
|---|---|---|
| Genes at FDR 0.10 | 516 (77 depleted, 439 enriched under AZA); 519 against the centred control null | 50 AZA-specific depleted ("bottomcenter"), 11 enriched ("topcenter") |
| UBE2K | depleted #2, FDR 1e-9 | diff rank 1 |
| TOPORS | depleted #4, FDR 1e-8 | diff rank 3 |
| UBXN7 | depleted #16, FDR 0.007 | diff rank 2 |
| UCK2 (AZA-activating kinase, resistance) | enriched #2 overall, FDR 6e-18 | topcenter |
| Paper's 50 depleted genes passing BARCS FDR 0.10 | 7 (UBE2K, TOPORS, UBAP2L, BRAP, PPP1R15A, UBXN7, OTUB1), none called in the opposite direction | |
| Paper's 11 enriched genes passing BARCS FDR 0.10 | 10 (all but HDAC2) | |
| Rank correlation with `diff` (depletion score) | 0.72 | |
| Top-25 / top-50 overlap (depleted) | 5 / 7 | |

## Where BARCS agrees and differs

- **Agrees.** All three validated sensitizers are among BARCS's 16 most depleted genes. Their guides agree in both replicates: for TOPORS, all four guides are 3–4 fold lower under AZA. UCK2, the kinase that activates AZA, is the second-strongest gene overall in the enriched direction. Ten of the paper's eleven AZA-resistance genes are called.
- **The two methods ask slightly different questions.** BARCS compares AZA and DMSO directly. MAGeCKFlute first rescales each arm's beta scores for its number of divisions. The AZA arm divided less, so in a direct comparison guides against essential genes are relatively more abundant under AZA. Most of the 439 enriched BARCS calls are such genes: their mean DMSO beta is -0.84, against -0.20 for all genes. The same effect explains the published-only part of the top lists. In the paper's top 25, TXNL4B, PHAX, POLE, PCNA, SNRPF and NOP58 are core essential genes. Cell-cycle normalization makes them look AZA-depleted, and BARCS ranks them in the thousands. BARCS-only depleted genes such as PTEN, ARIH2 and SIRT6 rank 34–90 in the paper's list. GCM2 (#9) is called from one of three guides and should be discounted.

## Limits

- About 15% of guides are missing from the deposited file because of Excel's row limit. Genes lose guides at random, which weakens some calls; the paper's own analysis used the full library.
- The comparison is AZA vs DMSO at the same time point without cell-cycle normalization, so enrichment of essential genes under AZA reflects growth rate, not resistance.
- Two replicates per arm. Control calibration was needed, which suggests extra variation between cultures.
