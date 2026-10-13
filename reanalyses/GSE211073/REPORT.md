# GSE211073 reanalysis with BARCS 0.2.2

**Paper.** Meyer et al., "Deciphering the mitophagy receptor network identifies a crucial role for OPTN (optineurin) in acute myeloid leukemia", *Autophagy* 19 (2023), PMID 37439113, doi:10.1080/15548627.2023.2230839 (PMC10549194, open access).

**Screen.** A **pairwise multiplexed (dual-guide) CRISPR screen** of 14 mitophagy receptors in MV4-11/MOLM AML cells (Cas9 + mt-mKeima reporter). Each deposited construct is a pair of guides (Guide_1 x Guide_2); per-sample CSVs (`GSE211073_RAW.tar`) were merged on the construct pair (4,761 constructs, raw integer counts). Cells were sorted into high and low mitophagy (mt-mKeima) fractions after induction with deferiprone (DFP) or oligomycin+antimycin A (OA), 3 replicates each. The paper's conclusion — **OPTN is the sole non-redundant mitophagy receptor** — comes from **genetic-interaction (epistasis) analysis between guide pairs**: OPTN had the fewest genetic interactions, not necessarily the largest single-gene effect.

## Caveat for this series

This is a genetic-interaction screen. **BARCS models single-gene guide aggregation, not epistasis between guide pairs**, so it cannot reproduce or evaluate the paper's central OPTN non-redundancy claim. What BARCS can do is test **single-construct abundance**: each construct is a unit, and its "gene" is the non-control receptor it targets. control+control constructs (144) are used as non-targeting controls; gene+control and same-gene constructs (112 per receptor) give the single-gene effect; gene A + gene B constructs are aggregated as nominal A_B labels but their interaction scores are **out of scope** and should not be read as BARCS results.

## Results (single-gene receptors; negative effect = depleted in high fraction = required for mitophagy)

| Receptor | OA high vs low | | DFP high vs low | |
|---|---|---|---|---|
| | effect | FDR | effect | FDR |
| **PHB2** | −0.98 | 5e-6 | −0.80 | 0.003 |
| FKBP8 | −0.27 | 0.034 | −0.18 | 0.37 |
| OPTN | +0.06 | 0.51 | +0.04 | 0.76 |
| SQSTM1 | +0.16 | 0.13 | +0.08 | 0.56 |
| CALCOCO2 | +0.09 | 0.18 | +0.07 | 0.61 |

PHB2 is by far the strongest single-gene hit in both inductions, depleted in the high-mitophagy fraction (its knockout reduces mitophagy). FKBP8 is the next required receptor. The remaining receptors, including OPTN, show little single-gene abundance change in the sort.

## Where BARCS agrees and differs

- **Agrees on a single-gene requirement the paper also notes.** The paper's network places PHB2 (an inner-membrane receptor) and the ubiquitin-dependent receptors as strongly interconnected mitophagy drivers; BARCS's single-gene signal picks PHB2 and FKBP8 as the receptors whose knockout most reduces mitophagy flux, consistent with them being functional nodes.
- **Cannot reproduce the OPTN headline.** OPTN shows no significant single-gene abundance change in the mt-mKeima sort. This is expected: the paper identified OPTN not by a large single-gene sort effect but as the receptor with the fewest genetic interactions (non-redundant), a property defined over guide *pairs* that BARCS does not model. The paper itself validated OPTN mainly through proliferation and in vivo experiments, not sort magnitude.
- The control calibration is imperfect here: the control-control constructs sit ~1.2 z from the targeting constructs (no KO at all), so the control null is centred on the targeting guides and its counts are not quoted.

## Limits

- Genetic-interaction screen: epistasis between guide pairs is the paper's core analysis and is outside what BARCS models.
- Only single-gene (control-paired) abundance is interpretable; pair labels are nominal.
- The mitophagy sort measures flux, not fitness; OPTN's proliferation role (the paper's main point) is not in these counts.
