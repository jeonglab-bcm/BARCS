# GSE197962 reanalysis with BARCS 0.2.3

**Paper.** Israeli et al., "Genome-wide CRISPR screens identify GATA6 as a proviral host factor for SARS-CoV-2 via modulation of ACE2", Nature Communications (2022), PMID 35469023, doi:10.1038/s41467-022-29896-z (PMC9039069).

**Screen.** Brunello knockout library (76,441 guides, 1,000 non-targeting controls) in Calu-3 cells infected with wild-type SARS-CoV-2 (one library), Alpha (two) or Beta (two), with two uninfected and two input libraries (Israeli et al. 2022). Guides enriched in survivors mark proviral host factors. GEO columns are self-named; prepare.R turns Supplementary Data 1 (MOESM4) into the published MAGeCK-RRA table (combined "all" screen and per-variant). Sequencing is shallow (0.4-6.5 M reads for 77k guides; 37% of guides at zero in the WT and Beta libraries).

**Design.** Main analysis pools the five infected libraries (WT + Alpha + Beta) against the two uninfected, `~ infection` (5 residual df), reproducing the authors' combined screen. Second analysis: Alpha vs uninfected (`~ virus`, 2 residual df), the paper's Alpha-specific candidates. Libraries are separate cultures; no pairing term. Enrichment is read (proviral factors).

**Checks.** Control calibration is clean (3.4-3.6% of non-targeting guides at p < 0.05). Composition is flat (top 1% hold 4-7%). Non-targeting controls sit near the targeting guides (shift -0.02), control null centred on controls; it calls 0 genes.

## Results

| | BARCS 0.2.3 | Authors (MAGeCK RRA) |
|---|---|---|
| Combined, genes at FDR 0.10 | 0 (dispersion inflated by pooling three viruses) | ACE2, GATA6 and a longer enriched list |
| ACE2 (receptor) | #2 combined, #1 Alpha; effect positive | top hit |
| GATA6 (headline proviral factor) | #9 combined; #100 Alpha | main finding |
| Alpha-specific KREMEN2 / SETDB1 | #156 / #454 | unique Alpha candidates |
| Combined rank correlation / top-20 overlap | 0.34 / 2 of 20 | |

## Where BARCS agrees and differs

- **Agrees on the two headline genes.** ACE2 (the receptor) and GATA6 (the paper's proviral discovery) are the #2 and #9 most-enriched genes in the combined screen, and ACE2 is #1 in the Alpha screen. BARCS confirms the paper's central result that ACE2 and GATA6 are the strongest proviral factors.
- **Differs everywhere else.** Overall rank correlation is only 0.34 and nothing reaches FDR 0.10. The screen is shallow (one WT replicate, 0.4-6.5 M reads, 37% zero guides), and pooling three antigenically different viruses inflates the between-library dispersion, so BARCS cannot certify the longer host-factor list or the Alpha-specific KREMEN2/SETDB1. MAGeCK's RRA, run per screen with total-read normalization, is more permissive here.

## Limits

- Very shallow sequencing and only one wild-type replicate; pooling WT/Alpha/Beta inflates dispersion. The calls are driven by the two strongest genes; nothing reaches FDR 0.10.
