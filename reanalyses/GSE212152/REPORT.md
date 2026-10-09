# GSE212152 reanalysis with BARCS 0.2.2

**Paper.** "Requirements for establishment and epigenetic stability of mammalian heterochromatin", *Molecular Cell* (2025), PMID 40972525, doi:10.1016/j.molcel.2025.08.025 (PMC12478525).

**Screen.** An inducible H3K9me3 heterochromatin reporter is silenced in mouse ES cells; a custom chromatin-factor CRISPR-Cas9 knockout library (5,950 guides, 1,310 genes, 150 non-targeting guides) is screened for factors whose loss leaves the reporter active. Cells that lose silencing stay eGFP+, so required factors are **enriched** in the eGFP+ fraction versus the unsorted population. Two separate screens were deposited, each with its own count file and the same library: **establishment** and **maintenance**. The authors deposited MAGeCK-RRA gene summaries for both.

**Design.** Both screens: `~ replicate + condition`, eGFP+ vs unsorted, 4 libraries, 1 residual df, `test = "auto"`. Within each screen the two replicates (A, B) are paired infections split into sorted and unsorted fractions, so replicate is a blocking term. Establishment reproduces the paper's primary claim and is the **primary** analysis; maintenance is the second screen (DHX9/R-loops). The column-to-sample mapping is taken from the deposited headers (`GFP`/`Unsorted`, `repA`/`repB`), which match the GSM titles; it is not inferred.

**Calibration.** Establishment: 2.0% of non-targeting guides at p < 0.05, so no calibration. Maintenance: 10.7% at p < 0.05, so calibrated to the 150 controls (4.7% after).

## Results — establishment (primary)

| | Value |
|---|---|
| Genes at FDR 0.10 | 106 (47 enriched, 59 depleted); control-null 217 |
| Rank correlation with authors' MAGeCK (pos) | 0.88 |
| Top-50 overlap with MAGeCK | 46 / 50 |

| Named hit (enriched) | BARCS rank (enriched) | Effect | p | FDR |
|---|---|---|---|---|
| Dnmt1 | 2 | +1.99 | 8.2e-09 | 4.7e-06 |
| Setdb1 | 7 | +2.00 | 4.9e-07 | 8.0e-05 |
| Ehmt2 (G9a) | 13 | +1.56 | 1.5e-05 | 1.3e-03 |
| Dnmt3b | 35 | +1.30 | 2.2e-03 | 0.053 |
| Dnmt3a | 39 | +1.41 | 3.7e-03 | 0.064 |
| Suv39h1 | 48 | +1.28 | 0.013 | 0.12 |
| Hdac2 | 168 | +0.12 | 0.52 | 0.72 |
| Hdac1 | 1160 | -0.85 | 4.7e-05 | 3.4e-03 (depleted) |
| Dhx9 | 1128 | -1.32 | 4.5e-03 | 0.072 (depleted) |

Top enriched genes: Atf7ip, Dnmt1, Cbx1, Kdm1a, Atrx, Rbm14, Setdb1, Cbx5, Daxx, Smarcad1 — the H3K9 and DNA-methylation machinery the paper names.

## Results — maintenance

| | Value |
|---|---|
| Genes at FDR 0.10 | 164 (49 enriched, 115 depleted); control-null 309 |

| Named hit (enriched) | BARCS rank (enriched) | Effect | p | FDR |
|---|---|---|---|---|
| Dnmt3l | 1 | +1.66 | 2.2e-17 | 2.6e-14 |
| Uhrf1 | 3 | +1.47 | 1.7e-14 | 6.5e-12 |
| Dnmt3a | 4 | +1.19 | 4.1e-14 | 1.2e-11 |
| Dnmt1 | 5 | +1.51 | 1.3e-13 | 2.9e-11 |
| Dnmt3b | 15 | +0.40 | 6.4e-06 | 2.7e-04 |
| Setdb1 | 35 | +1.03 | 1.3e-03 | 0.020 |
| Ehmt2 | 61 | +0.28 | 0.023 | 0.13 |
| Dhx9 | 143 | +0.33 | 0.21 | 0.41 |

## Where BARCS agrees and differs

- **Agrees strongly on establishment.** Every DNA/H3K9 methyltransferase the paper highlights is enriched at FDR 0.10 except Suv39h1 (borderline, 0.12); Dnmt3a passes at 0.064. Rank correlation with the authors' MAGeCK is 0.88 and 46 of the top 50 genes are shared.
- **Hdac1/Hdac2 are not enriched.** Not a disagreement with a specific named gene: the abstract names HDACs as a class, and at the guide level Hdac1 moves the opposite way (depleted, essential-gene behaviour), so BARCS places it at the bottom of the enriched list. Hdac2 is flat.
- **Dhx9.** In establishment it is depleted (essential-gene loss), matching its guide counts. In maintenance — where the paper reports DHX9 is required — BARCS ranks it #143 enriched (p = 0.21), so BARCS does not reach significance for the single R-loop gene the paper validated, though the direction is now enriched.

## Limits

- Two replicates per screen, 1 residual df.
- One establishment eGFP+ library (repB) is bottlenecked (19.5% of reads on its top 1% of guides); library-total depletion calls there are less reliable, but the enriched hits are robust.
- Named hits beyond the deposited class labels are inferred from the abstract classes and the GEO summary.

**Control null.** The control null is centred on the targeting guides because the non-targeting controls sit away from them (+0.55 z in establishment, +0.48 in maintenance; non-targeting guides make no cut).
