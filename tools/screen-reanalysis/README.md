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

Use it from Claude Code with `/screen-reanalysis` (optionally with a PMID or a
GSE number), or by hand:

```sh
Rscript tools/screen-reanalysis/search_pubmed.R --days 180 --out work/screens.tsv
Rscript tools/screen-reanalysis/fetch_geo.R GSE333513 --dir work
Rscript tools/screen-reanalysis/inspect_counts.R work/GSE333513/suppl/GSE333513_merged_counts.txt.gz
Rscript tools/screen-reanalysis/run_barcs.R work/GSE333513/design.json
Rscript tools/screen-reanalysis/compare_results.R work/GSE333513/compare.json
```

`examples/GSE333513/` holds the design, comparison spec, and report from a
worked run. Needs R packages BARCS, jsonlite and readxl; `NCBI_API_KEY` is
optional. Output goes to `work/`, which is git-ignored and excluded from the
package build.
