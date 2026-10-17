# GSE235620 reanalysis with BARCS 0.2.3

**Paper.** Prezza, Liao, Reichardt, Beisel, Westermann, "CRISPR-based screening of small RNA modulators of bile susceptibility in Bacteroides thetaiotaomicron", *PNAS* (2024), PMID 38294941, doi:10.1073/pnas.2311323121 (PMC10861873).

**Screen.** A genome-wide CRISPRi (dPb2Cas12a) library knocking down the 135 intergenic sRNAs of *B. thetaiotaomicron* VPI-5482: each sRNA is targeted by up to three "mature" guides and one full CRISPR-array guide, plus 20 non-targeting controls (667 library members). The input library was subcultured into rich medium (TYG) with IPTG, with or without 0.05 mg/mL bile salts, in three biological replicates, and grown to stationary phase. The authors compared guide abundance bile vs no-bile with edgeR per guide, then averaged per sRNA (Dataset S4), using |log2FC| > 0.5 and FDR < 0.05. They report two hits: BatR (BTnc167), whose knockdown increases numbers under bile (enriched, resistance), and BTnc353 (depleted). BatR is the paper's subject.

**Counts.** Nine per-sample headerless `<guide> <count>` files (GEO sample supplements), same 667 guides. `prepare.R` merges them, sets the gene to the sRNA (grouping each sRNA's mature and array guides as the paper does) and the 20 non-targeting guides to one control group, and downloads Dataset S4 (via the Europe PMC supplement bundle, since the PNAS host blocks direct requests here).

**Design.** Bile vs TYG, `~ condition`, three libraries per arm, 4 residual degrees of freedom. The three glycerol-stock "library" samples are the input reference and are not in the published comparison, so they are left out. Library totals; the top 1% of guides hold about 4% of reads, no bottleneck. Dispersion moderation applied (prior df 5.7). Guide correlation 0.

**Checks.** 20 non-targeting guides; 20% reach p < 0.05, above the nominal 5%, but 20 controls are too few to calibrate reliably or to build a control null (needs 100+), so the raw test is used and this is noted as a limit. The two top genes rest on four guides each that move together, no jackpots.

## Results

| | BARCS (FDR 0.10) | Paper (edgeR per sRNA, Dataset S4) |
|---|---|---|
| Hits | 3 sRNAs: BTnc353 (FDR 9e-5, depleted), BatR/BTnc167 (3e-4, enriched), BTnc242 (0.06, depleted) | 2 sRNAs at FDR 0.05 & \|log2FC\|>0.5: BatR (enriched), BTnc353 (depleted) |
| BatR (BTnc167) | #2 of 166, estimate +0.37 | logFC +0.78, FDR 3e-20 |
| BTnc353 | #1, estimate −0.51 | logFC −0.79, FDR 1e-19 |
| Rank correlation (two-sided score) | 0.39; direction agreement 81% | |
| Top-20 overlap | 11 of 20 | |

## Where BARCS agrees and differs

- **Agrees.** Both sRNAs the paper reports are BARCS's top two calls, with the same directions: BatR enriched under bile, BTnc353 depleted. Over all sRNAs, 81% of effect directions agree.
- **Differs.** BARCS adds one call, BTnc242 (depleted, FDR 0.06), which the paper ranks 27th; it sits just under 0.10. BARCS's effect sizes are about half the paper's logFC, because edgeR's per-guide fold changes are summarised per sRNA by averaging while BARCS fits all four guides jointly against library totals and moderates the dispersion. The bulk rank correlation is modest (0.39) because, apart from the two strong hits, the sRNA effects are near zero and noisy.

## Limits

- Only 20 non-targeting controls: calibration cannot be checked (raw 20% at p < 0.05) and no control null is possible, so the short hit list should be read with the paper's |log2FC| cutoff in mind.
- Several guides target more than one sRNA (composite names kept as their own groups), so those sRNAs' knockdown effects are not resolved.
- The paper's edgeR analysis and BARCS both find only two robust sRNA phenotypes, consistent with a screen where most sRNA knockdowns do not change bile fitness.
