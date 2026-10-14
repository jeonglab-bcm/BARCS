# GSE290153 reanalysis with BARCS 0.2.3

**Paper.** Nebenfuehr et al., "Uncovering genetic interactions in the DNA repair network in response to endogenous damage and ionizing radiation", Cell Reports (2026), PMID 41546867, doi:10.1016/j.celrep.2025.116850 (PMC12970561).

**Screen.** A large combinatorial dual-guide CRISPR screen of 461 DNA-repair genes in eHAP-iCas9 cells. Each construct is a pair of guides; the library covers over 100,000 gene-gene combinations (809,460 shared constructs across the deposited files). Cells were screened under basal conditions (day0 to day14) and with repeated low-dose ionizing radiation (0.6 Gy per split, IR day15). The paper's central result is a map of genetic interactions (epistasis) between guide pairs: synthetic lethalities such as BRCA1 x PARP10, UBR5 x MRE11, and PARP1 x PARP2.

## What BARCS can and cannot do here

**BARCS models single-gene / single-construct abundance, not epistasis between guide pairs, so it cannot reproduce or evaluate the paper's genetic-interaction findings, which are the paper's core claim.** What it can test is single-gene abundance, defined exactly as the paper defines its single-gene phenotype: constructs pairing a gene with a non-targeting (nt) guide, aggregated by that gene. prepare.R keeps those single-gene constructs (and same-gene pairs), 50,801 constructs over 459 genes, plus the 752 nt+nt controls; the ~758,000 gene-pair constructs are dropped because their interaction meaning is out of scope. Primary contrast IR_day15 vs control_day14 (2 vs 2): single-gene depletion = loss sensitizes to ionizing radiation.

## Results

- **Design.** `~ condition`, IR vs day14, 4 libraries, 2 residual df.
- **Calibration.** The 752 nt+nt controls are exceptionally well-behaved: 0% at raw p < 0.05, control_shift -0.04, so the control null is centred on the controls. 209 guides switched to the likelihood-ratio test.
- **Calls.** **0 genes at FDR 0.10, by both the model and the control null.** The strongest single-gene signals (Rmi1 #3, Polq #7, Ube2b #1, Cul4a #2) have FDR ~1. Canonical DDR/IR genes show only tiny single-gene effects and do not separate: Lig4 #71, Atm #219, Xrcc5 #255, Brca2 #258, Brca1 #453, Parp1 #367, Trp53bp1 #423 of 459 (all FDR 1). UBR5, one of the paper's interaction hubs, is #262 as a single gene.

## Interpretation

This is a well-calibrated run that finds no single-gene hits. That is consistent with the paper's own premise: single-gene knockouts of DNA-repair genes have modest fitness effects under a mild repeated IR dose, and the informative signal lives in the genetic interactions between gene pairs. The paper computes single-gene phenotypes only as a normalization step for its interaction scores, not as a hit list. BARCS, restricted to the single-gene marginal, is correctly null here and cannot address the combinatorial biology the paper is about.

## Limits

- The paper's genetic-interaction analysis is out of scope for BARCS's single-gene model; this reanalysis evaluates only the single-gene marginal.
- 2 replicates per arm, 2 residual df; a mild repeated-IR regimen gives small single-gene effects.
- The single-gene count file is the nt-paired and same-gene constructs plus nt+nt controls; library totals are over that single-gene subset, not the full combinatorial library.
