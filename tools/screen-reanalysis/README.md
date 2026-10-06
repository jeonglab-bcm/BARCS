# Screen reanalysis tools

Scripts behind the `screen-reanalysis` Claude Code skill
(`.claude/skills/screen-reanalysis/SKILL.md`). They find a recent pooled CRISPR
screen in PubMed with counts in GEO, rerun it with BARCS, and compare the
result with what the paper reported. The scripts do the mechanical steps; the
agent (or you) writes `design.json` and `compare.json`.

| Script | Does |
|---|---|
| `search_pubmed.R` | PubMed papers with linked GEO series, scored for "looks like a pooled screen" |
| `fetch_geo.R` | Series metadata (`series.json`, `samples.tsv`) and supplementary files |
| `inspect_counts.R` | Header, integer check, totals, replicate correlations, control labels |
| `run_barcs.R` | BARCS per analysis in `design.json` -> `results/<analysis>/` |
| `compare_results.R` | Named-hit ranks, rank correlation and top-N overlap with a published table |
| `archive_run.R` | Copy a finished run (with `meta.json`) into `reanalyses/<GSE>/` |
| `build_site.R` | Static website from `reanalyses/` into `_site/` |

Use it from Claude Code with `/screen-reanalysis` (optionally with a PMID or a
GSE number), or by hand:

```sh
Rscript tools/screen-reanalysis/search_pubmed.R --days 180 --out work/screens.tsv
Rscript tools/screen-reanalysis/fetch_geo.R GSE333513 --dir work
Rscript tools/screen-reanalysis/inspect_counts.R work/GSE333513/suppl/GSE333513_merged_counts.txt.gz
Rscript tools/screen-reanalysis/run_barcs.R work/GSE333513/design.json
Rscript tools/screen-reanalysis/compare_results.R work/GSE333513/compare.json
Rscript tools/screen-reanalysis/archive_run.R work/GSE333513
Rscript tools/screen-reanalysis/build_site.R
```

`reanalyses/<GSE>/` is the tracked record of each published run (design,
comparison spec, report, run info, trimmed gene tables). Pushing changes there
to `main` rebuilds the website with GitHub Pages
(`.github/workflows/reanalysis-site.yaml`; enable Pages with source "GitHub
Actions" once in the repository settings). Needs R packages BARCS, jsonlite and readxl; `NCBI_API_KEY` is
optional. Output goes to `work/`, which is git-ignored and excluded from the
package build.
