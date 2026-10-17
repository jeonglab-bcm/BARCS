# GSE251758 reanalysis with BARCS 0.2.3

**Paper.** Lin, Levy, Alflen et al., "Multimodal stimulation screens reveal unique and shared genes limiting T cell fitness", *Cancer Cell* (2024), PMID 38490212, doi:10.1016/j.ccell.2024.02.016 (PMC11003465).

**Screen.** Genome-wide Brie knockout library (4 guides per gene, 1,000 non-targeting guides) in primary OT-I/Cas9 mouse CD8 T cells. After selection, a pre-reactivation sample was taken, and the cells were then stimulated in three ways: intense (two successive 24 h CD3 stimulations, activation-induced cell death), acute (one 24 h CD3 stimulation, then 3 days of expansion) and chronic (11 days of daily co-culture with D4M.OVA tumour cells, against resting cells cultured alongside). Guides enriched after stimulation mark genes that limit T cell fitness. The authors used MAGeCK 0.5.7. Their gene summaries are in Table S1 and on GEO: intense vs pre-reactivation, acute vs pre-reactivation and chronic vs resting. The paper follows up Dap5 (*Eif4g2*), which ranks high in all three screens; *Icam1* (intense and acute); and *Ctbp1* (chronic only). *Trp53* tops the intense and acute screens.

**Counts.** The count tables are the GSMs' second and third supplementary files. One has Intense, Acute, preA-Bulk and T0, with the two replicate libraries per condition already summed by the authors ("sum_rep"). The other has Chronic and Resting, one library each. `prepare.R` downloads both and merges them by sgRNA. All values are integers. Libraries hold 49–60 M reads (intense and acute arms) and 14–20 M reads (chronic arm).

**Design.** Three one-against-one comparisons, `~ condition`: Intense vs preA, Acute vs preA and Chronic vs Resting. These are the authors' comparisons. Because replicates were summed before deposit, each condition is one library, so `run_barcs.R` uses the no-replicate path and pools the overdispersion over the non-targeting guides. The calls are screening-level: variation between replicate cultures could not be measured.

**Checks.**
- Intense and acute arms: the controls behave almost like Poisson counts (pooled ρ = 5e-8 and 1e-7). Control p < 0.05 rates are 5.0% and 5.6%, so the test is calibrated to the controls. Control shift is −0.04 and −0.17 z. The top 1% of guides hold 2.4–2.6% of reads, so the libraries are not bottlenecked.
- Chronic arm: Resting and Chronic correlate only at ρ = 0.53 (Spearman, log counts), and the top 1% of guides hold 10–15% of reads. The co-culture bottlenecked the library. The pooled overdispersion is 80 times the Poisson variance, and control p < 0.05 is 3.7%. Some top calls rest on single jackpot guides, for example *Akr1c12* (one guide at 19,648 reads against 72–331 for the other three) and *Nefm* (one guide at 6,540 reads). Discount them.

## Results

| | BARCS (FDR 0.10; control null) | Paper (MAGeCK, pos FDR < 0.10) |
|---|---|---|
| Intense vs pre | 1,187 genes (232 enriched, 955 depleted); 1,304 against the control null | 54 enriched genes |
| Acute vs pre | 1,643 genes (300 enriched, 1,343 depleted); 2,033 | 64 enriched genes |
| Chronic vs resting | 45 genes (17 enriched, 28 depleted); 21 | 9 enriched genes |
| *Trp53* | #1 enriched in all three (FDR 1e-136, 4e-220, 2e-11) | #1, #1, #7 |
| *Eif4g2* (Dap5) | #8, #5, #5 enriched; FDR 1e-11, 9e-33, 3e-6 | #13, #22, #10 |
| *Icam1* | #67 (FDR 0.011) intense, #27 (2e-10) acute | top 50 in intense and acute |
| *Ctbp1* (chronic) | #48 enriched, FDR 0.47; all four guides 1.3–8-fold up | #22, FDR 0.39 |
| Rank correlation with MAGeCK (enriched score) | 0.76 intense, 0.76 acute, 0.79 chronic | |
| Top-50 overlap | 40 intense, 45 acute, 18 chronic | |

## Where BARCS agrees and differs

- **Agrees.** In the intense and acute screens BARCS reproduces the authors' ranking closely: 40 and 45 of the top 50 enriched genes are shared. *Trp53*, *Eif4g2* and *Icam1* all pass FDR 0.10 with large margins. In the chronic screen, *Trp53*, *Eif4g2*, *Zc3h12a* (Regnase-1) and *Ccnc* (rank 1–5 in the paper) are all called.
- **Differs.** BARCS calls far more genes, mostly depleted ones (genes needed for T cell survival or proliferation under stimulation). MAGeCK's positive-selection FDR is not designed to report those. The long list partly reflects the no-replicate design: the summed libraries are sequenced deeply, the controls are near-Poisson, and BARCS has no replicate cultures from which to estimate biological variation. The control null agrees with the model, but neither can see variation between cultures, so treat the depleted list as screening-level. In the bottlenecked chronic screen, BARCS and MAGeCK share only 18 of the top 50. *Ctbp1*, the paper's chronic-specific gene, misses FDR 0.10 in both methods (BARCS 0.47, MAGeCK 0.39). The paper supports it with individual knockouts, not with the screen statistic.

## Limits

- The authors summed the replicate libraries before deposit (chronic and resting were single libraries), so each test compares one library against one.
- The chronic arm is bottlenecked (top 1% of guides hold 10–15% of reads), and some of its calls rest on single jackpot guides.
- MAGeCK's "pos|score" (RRA) is used as the published ranking. The authors' `pos|lfc` is a median guide LFC, which is why the effect-direction agreement over all genes is near 50%.
