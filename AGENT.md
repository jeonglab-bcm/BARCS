# Handover notes for BARCS

These notes are for Kelly, who is taking over as maintainer of this repository, and for any coding agent (Claude Code or similar) working with her. They cover what the repository holds, how to work in it, what was done most recently, and what is still open. Last updated 2026-10-09.

## What BARCS is

BARCS (Beta-binomial Analysis and Regression for CRISPR pooled Screens) is an R package. It fits a beta-binomial regression to each guide's read counts, then combines guides into gene-level results. Design choices that matter when changing the code:

- **Guide model** (`R/bbreg.R`). Logit-link beta-binomial, fitted by feasible IRLS. The overdispersion ρ comes from the Pearson estimating equation. Tests use a t reference with **residual degrees of freedom = number of libraries − number of coefficients**, never read depth.
- **Screen-wide fitting** (`R/screen.R`). `bb_screen()` fits every guide. By default it moderates dispersions toward an abundance trend (`bb_moderate_dispersion()`, Smyth scaled-F) when at least 50 guides are usable. It also estimates the within-gene guide correlation (attribute `"guide_correlation"`).
- **Gene summaries** (`R/gene.R`). `bb_gene_stouffer()` is a directional Stouffer that widens the null by the guide correlation. Other `bb_gene_*()` summaries exist.
- **Recalibration** (`R/calibrate.R`). `bb_calibrate_controls()` rescales test statistics so that non-targeting guides follow the null (`qq_slope` or `tail_quantile`).
- **Library totals** (`R/utils.R`). `barcs_control_totals()` normalizes to control guides when the composition of the library shifts.
- **Speed.** C++ (Rcpp/RcppArmadillo, `src/`) handles the weighted least-squares solves; R fallbacks exist.

### Changes in 0.2.1 (PR #2, merged)

- **`bb_screen(test = c("wald", "lr", "auto"))`**
  - The Wald test is still the default.
  - `"auto"` uses a fixed-dispersion likelihood-ratio test only for guides whose fitted proportions span more than 100-fold (`lr_fold`). That is where the Wald standard error blows up (Hauck–Donner).
  - The LR result is reported as the standard error it implies, so moderation, calibration and gene summaries work unchanged.
- **`bbreg(firth = TRUE)`**
  - Guides with zero reads in every library of one condition (complete separation) used to fail to converge and were dropped.
  - They are now refitted with Firth's correction. Fits that do not separate are untouched.
- **Evidence** is in the PR #2 description and `NEWS.md`.
  - The CRISPulator benchmark is unchanged or slightly better.
  - Null calibration is not inflated.
  - Two real screens were fixed: BAX in GSE291338 and CCNC in GSE316868.

## Daily work

```sh
R CMD INSTALL .                                   # install from source
Rscript -e 'testthat::test_local(".")'            # unit tests (tests/testthat)
Rscript -e 'roxygen2::roxygenise()'               # after changing roxygen comments
R CMD build . && LANG=C.UTF-8 LC_ALL=C.UTF-8 R CMD check --no-manual BARCS_*.tar.gz
```

- **Locale.** Run `R CMD check` under a UTF-8 locale (as above). In a container without `en_US.UTF-8` there is one environment-only `Sys.setlocale` warning that is not a package problem.
- **Version bumps.**
  - Bump `Version` in `DESCRIPTION`, `version` in `CITATION.cff` and the `NEWS.md` heading together.
  - Pushing a new version to `main` triggers `.github/workflows/release.yaml`, which tags and publishes a release.
  - The guard in that workflow skips versions already tagged.
- **CI.** `.github/workflows/R-CMD-check.yaml` runs on Linux, macOS and Windows for pull requests and `main`.
- **Benchmarks before changing inference code.** Rerun the CRISPulator FACS benchmark and a null simulation before and after. Both harnesses live in `barcs-manuscript` (see below).
  - Report precision, FDP, recall and the share of null guides at p < 0.05.
  - A change that looks better on one real screen but inflates the null is not an improvement.

## Repository map

| Path | What it is |
|---|---|
| `R/`, `src/`, `man/`, `tests/`, `vignettes/` | The package |
| `data/`, `data-raw/` | `evers_rt112` example data and the script that builds it |
| `.claude/skills/screen-reanalysis/SKILL.md` | Claude Code skill: reanalyze a published screen (see below) |
| `tools/screen-reanalysis/` | Scripts the skill drives, plus a README |
| `reanalyses/<GSE>/` | Recorded reanalyses (design, comparison spec, report, run info, trimmed gene tables) |
| `reanalyses/excluded.tsv` | Every candidate series that was checked and could not be reanalyzed, with the reason |
| `.github/workflows/reanalysis-site.yaml` | Builds the reanalysis website and deploys it with GitHub Pages |

`.claude/`, `tools/`, `reanalyses/`, `work/` and `_site/` are excluded from the package build (`.Rbuildignore`). `work/` and `_site/` are git-ignored scratch space.

## Screen-reanalysis workflow (PR #3, merged)

The workflow checks BARCS against newly published screens:
1. Search PubMed for recent pooled CRISPR screens with counts in GEO.
2. Rerun each one with BARCS.
3. Compare with what each paper reported.
4. Publish the comparisons as a static website.

In Claude Code, run `/screen-reanalysis` (optionally with a PMID or GSE). The steps are in the skill file; the scripts are:

```sh
Rscript tools/screen-reanalysis/search_pubmed.R --days 365 --out work/screens.tsv
Rscript tools/screen-reanalysis/fetch_geo.R GSE123456 --dir work
Rscript tools/screen-reanalysis/inspect_counts.R work/GSE123456/suppl/<file>
Rscript tools/screen-reanalysis/run_barcs.R work/GSE123456/design.json     # agent writes design.json
Rscript tools/screen-reanalysis/compare_results.R work/GSE123456/compare.json
Rscript tools/screen-reanalysis/archive_run.R work/GSE123456              # needs meta.json
Rscript tools/screen-reanalysis/build_site.R                              # preview in _site/index.html
```

### Safeguards in `run_barcs.R`

Keep these safeguards:
- **Composition check.** The script records the share of reads held by the top 1% of guides and warns above 25%. When a few clones take over, use `"totals": "median_ratio"` and interpret enrichment first.
- **Control-guide calibration.** It records the share of non-targeting guides at p < 0.05 (`control_p05_raw`, `control_p05`). When that share exceeds 7.5% and there are at least 50 controls, it calibrates to them by default.
  - Sort and in vivo screens showed 14–56% before calibration.
  - Screens whose replicates are split from one infected population need this most.
- **Test choice.** It uses `test = "auto"` when the installed BARCS supports it.

### Current state of the reanalyses

The last search (2026-10-09) covered 3 years: 241 papers and 118 screen-like candidate series.
- **Reanalyzed: 25.** 17 agree, 5 partly agree, 3 differ.
- **Screened out: 86**, with reasons in `reanalyses/excluded.tsv`. The most common reasons are a paper's companion assays (Hi-C, CUT&Tag…), one library per condition, and normalized counts only.
- **Usable but not reanalyzed yet: 7**, listed as `pending` in `reanalyses/search.json` and on the site.
- About one screen-like series in four is usable, and about 80 matching papers appear per year, so 100 screens needs either a 6-7 year window or counting from raw reads (see open items).

Each report states its assumptions. Inferred column mappings are marked as inferred.

### Using the agent well

The agent makes four judgment calls:
- whether a series is a usable screen;
- how count columns map to samples;
- which contrast answers the paper's question;
- what the paper actually claimed.

Check these four in every new report before publishing it. Agents have made mistakes here before, for example claiming a gene's guides "disagree" without looking at the counts. Ask the agent to show the raw counts behind any surprising claim.

## Website

- **Build.** `build_site.R` turns `reanalyses/` into `_site/`: an index, one page per screen, and the screened-out table.
- **Deploy.** The workflow deploys on pushes to `main` that touch `reanalyses/` or the builder.
- **Live at https://jeonglab-bcm.github.io/BARCS/** (Pages enabled 2026-10-09, source: GitHub Actions).
- **Private preview.** A copy is published as a claude.ai artifact for Hyun-Hwan: https://claude.ai/artifact/S3Rr2ysKDuMfQzz2J78TgM. It is private to his account; ask him to share it if needed.

## Related repositories

| Repository | Role |
|---|---|
| `jeonglab-bcm/BARCS-manuscript` | Benchmark code, results and figures. It pins this package as the `BARCS/` submodule and the LaTeX as `overleaf/`. Read its `DEVELOPMENT.md` first. |
| `jeonglab-bcm/BARCS-tex` | Manuscript LaTeX; a public mirror of the Overleaf project. |

## Open items

**Package**
1. **Done (2026-10-08).** `BARCS-manuscript` branch `claude/sleepy-planck-2h1yvx` pins v0.2.1 (it builds on the unmerged `barcs-0.2.0-rerun`) and requires BARCS >= 0.2.1. Every benchmark was rerun under R 4.6.1.
   - BARCS numbers held to the fourth decimal everywhere; the null grid now converges for every guide.
   - Comparators drifted with newer tools, and four quoted numbers in `barcs-0.2.0-revision` no longer match: edgeR-QL AP 0.874 -> 0.875, Figure 1 disagreements 62 -> 61, CRISPulator MAGeCK-MLE F1 0.711 -> 0.704, simCRISPR BARCS F1 0.917 -> 0.911 (the simulator itself changed).
2. Decide whether `test = "auto"` should become the default. It matched Wald on the benchmark and fixed two real screens. Changing the default would change published numbers, so it needs a manuscript decision.
3. **Done in 0.2.2 (released).** `bb_gene_empirical_null()` reads gene p-values off pseudo-genes of control guides (signed, widened to the guide correlation). `centre = "targets"` takes the null's location from the targeting guides when the controls are offset; non-cutting controls in knockout screens sit 0.3-0.75 z away, and `run_barcs.R` centres automatically above 0.25 z. `run_barcs.R` records it and the site shows a control-null column.
   - Simulation (`tools/empirical-null-sim/`): with heavy-tailed clonal noise it held FDP at 0.09 where control calibration gave 0.22.
   - Limit: with one guide per element its smallest p-value is 2 / (controls + 1). GSE302335 (ICAM1) therefore gets no calls at FDR 0.10, although 65 elements lie beyond every control. The earlier "45" came from an uncorrected estimate and was replaced.

**Manuscript** (carried over; check status before acting)
4. Unmerged branches: `barcs-0.2.0-rerun` in `BARCS-manuscript` (patched scripts and reruns, plus `teaching/`) and `barcs-0.2.0-revision` in `BARCS-tex` (rewritten text for 0.2.0). Review and merge or close them.
5. Sync `BARCS-tex` to Overleaf with `BARCS-manuscript/scripts/manuscript_sync.sh`.
6. Before submission:
   - get a Zenodo DOI for the release;
   - decide the copyright holder (currently Hyun-Hwan Jeong as `cph` in `DESCRIPTION`);
   - add author contributions, a competing-interests statement and grant numbers.

**Reanalysis website**
7. **Done.** GitHub Pages is enabled and deploys on pushes to `main`.
8. Rerun `search_pubmed.R` periodically, perhaps monthly.
   - Triage new candidates and add the usable ones.
   - Add every rejection to `reanalyses/excluded.tsv` so the site shows full coverage.
9. GSE328830 was skipped only because its main count file is 657 MB, larger than the pipeline downloads. It can be reanalyzed with `--max-mb 800`.
10. Reanalyze the 7 pending series (GSE203240, GSE222531, GSE226977, GSE236257, GSE241933, GSE276161, GSE280676). Triage notes are in `work/triage3y/` of the session that found them; re-triage if that is gone. GSE280676 and GSE280666 (same bovine paper, same design) were triaged inconsistently: one usable, one rejected for clonal takeover; settle them together.
11. To reach 100 screens, count guides from raw reads with `barcs_quant()` for series that deposited only normalized values but have FASTQ in SRA (8 of the first 42 rejections were of that kind).

## People

- Hyun-Hwan Jeong (hyun-hwan.jeong@bcm.edu): package author, previous maintainer.
- Kelly: incoming maintainer.

Session history for the most recent work (October 2026) was exported as a transcript and given to Hyun-Hwan.
