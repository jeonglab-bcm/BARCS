# GSE290358 reanalysis with BARCS 0.2.3

**Paper.** Dam et al., "ZEB1, a novel junctional adhesion molecule A regulator, impacts sensitivity of pancreatic cancer-associated fibroblasts to reovirus", Molecular Therapy Oncology (2025), PMID 41244268, doi:10.1016/j.omton.2025.201071 (PMC12617759).

**Screen.** A genome-wide Brunello knockout library (77,441 guides) in RLT-PSC pancreatic stellate (CAF-like) cells. Cells were stained for surface JAM-A and sorted into high and low bins, plus an unsorted sample, in two replicates. The count file is the GEO file as deposited (integer reads, counted with UMIs); columns map one to one to the GSM titles. The authors ran MAGeCK RRA on high versus low for each replicate separately (Supplementary tables mmc2, mmc3). prepare.R merges the two tables; its published score is the weaker of a gene's two per-replicate p-values, because the paper required a gene to rank high in both replicates (ZEB1 is rank 1 in replicate 1, rank 146 in replicate 2).

**Design.** ~ fraction, JAM-A high vs JAM-A low, 4 libraries, 2 residual df. The two replicates are separate sorts, so a replicate term would leave 1 residual df and is left out. Enriched in the high bin marks a negative regulator of JAM-A (its loss raises JAM-A); depleted marks a positive regulator.

**Calibration.** The deposited table carries only 4 guides labelled CTRL (Brunello's 1,000 non-targeting guides are not identifiable in it), so there is no usable control set: control calibration, the control null, and control_shift are all unavailable. The reported FDR is the model BH FDR only, with no empirical check. Composition is flat (top 1% of guides hold 3-4% of reads).

## Results

| | BARCS 0.2.3 | Authors' MAGeCK (per replicate) |
|---|---|---|
| Genes at FDR 0.10 | 19 (9 enriched in high, 10 depleted); no control null available | 21 at FDR 0.10 in replicate 1, 0 in replicate 2; paper's hits rest on consistent ranks across both |
| F11R (JAM-A gene, positive control, KO lowers JAM-A) | #3, FDR 5e-5, all 4 guides depleted in high | rank 1 (low bin) in both replicates |
| ZEB1 (top negative regulator) | #1, FDR 3e-6, all 4 guides enriched in high | rank 1 / 146 |
| FGFR1 (second negative regulator) | #5, FDR 4e-4 | rank 5 / 4 |
| Rank correlation (two-sided score) | 0.29 | |
| Effect direction agreement | 87% of 19,357 genes | |

## Where BARCS agrees and differs

- Agrees on the headline. The positive control F11R (the JAM-A gene itself) is BARCS #3 with all four guides depleted in the high bin, confirming the sort worked. ZEB1, the paper's top negative regulator, is BARCS #1, and FGFR1, its second, is #5. The two validated genes are BARCS's two strongest enriched calls.
- Why the top-10 lists diverge. The paper scored each replicate separately and highlighted genes consistent across both; BARCS fits both replicates jointly. The two replicates are noisy (guide counts swing several-fold between them), so the per-replicate ranks and the joint fit order the middle of the list differently (Spearman 0.29). BARCS's other calls (INTS10, NUS1, DAD1, E4F1, KANSL1) have all four guides moving the same way, but WDR75 and ACTB are guide-dropout patterns (guides falling to 0-3 reads in one bin), typical essential-gene dropout rather than a JAM-A phenotype, and should be read with care. KAT8 and DAD1 are strong in the authors' table too (ranks 3-4).

## Limits

- No usable controls. Only 4 CTRL guides; the FDR cannot be checked against a non-targeting null, and BARCS's empirical control-null columns are absent. With 2 residual df and no control calibration, the 19-gene list is the model estimate alone.
- Two replicates, separate sorts; between-replicate variation is estimated from two sorts.
- Only the high vs low contrast is analyzed, which is the paper's screen.
