# Empirical-null simulation

`empirical_null_sim.R` simulates a two-replicate sort screen (3,000 genes x 4
guides, 1,000 non-targeting guides, 150 true hits) in which every guide
carries clonal noise on the sort effect that is shared by both replicates, so
the replicate residual cannot see it. It scores gene calls at FDR 0.10 from
the model, after `bb_calibrate_controls()`, and from
`bb_gene_empirical_null()`.

```sh
Rscript tools/empirical-null-sim/empirical_null_sim.R <tau> <seed> [reps] [normal|t3]
```

`results.tsv` holds 6 seeds per setting (Gaussian tau 0, 0.1, 0.2, 0.3; t3
tau 0.15, 0.3). Mean realized FDP (target 0.10):

| Clonal noise | Controls p < 0.05 | Model | Calibrated | Empirical | Empirical power |
|---|---|---|---|---|---|
| none | 4.7% | 0.100 | 0.095 | 0.097 | 0.997 |
| Gaussian 0.1 | 8.2% | 0.290 | 0.152 | 0.128 | 0.988 |
| Gaussian 0.2 | 19% | 0.678 | 0.116 | 0.103 | 0.942 |
| Gaussian 0.3 | 30% | 0.841 | 0.109 | 0.107 | 0.802 |
| t3 0.15 | 14% | 0.520 | 0.215 | 0.094 | 0.963 |
| t3 0.3 | 30% | 0.845 | 0.143 | 0.242 | 0.634 |

The empirical FDP was at or below the calibrated FDP in 11 of 12 heavy-tailed
runs. The t3 0.3 mean is driven by one seed in which both remedies broke down
(calibration made no calls; the empirical null made 3, all false); the other
five seeds gave empirical FDP 0.02-0.19.
