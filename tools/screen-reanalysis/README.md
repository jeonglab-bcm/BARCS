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
| `reproduce.R` | Rebuild recorded reanalyses from GEO and check them against `reanalyses/` |

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

## Reproducing a recorded reanalysis

Every record can be rebuilt from public data with one command:

```sh
R CMD INSTALL .                                               # the BARCS version in run_info.json
Rscript tools/screen-reanalysis/reproduce.R GSE243761         # one record
Rscript tools/screen-reanalysis/reproduce.R --all             # every record
```

It downloads the GEO inputs, runs the record's `prepare.R`, checks the count
file against `counts_md5`, reruns BARCS on every `design*.json`, and compares
each archived gene table and its call counts with the new run (OK, DIFFERS or
FAIL per series, non-zero exit if any is not OK). Work goes to
`work/reproduce/`.

What a record holds so that this works:

- `design.json`, plus a `design_*.json` for every other analysis in `results/`.
  `"fetch": {"sample_files": true, "max_mb": 800}` records `fetch_geo.R`
  options when the default download is not enough, and `counts_md5` the
  checksum of the count file BARCS reads.
- `prepare.R`, when the count file or the paper's published table is not a
  file GEO serves as is. Run as `Rscript reanalyses/<GSE>/prepare.R <workdir>`
  after `fetch_geo.R`, it builds both inside `<workdir>`: merging per-sample
  files, summing barcodes, fixing encodings, downloading and converting the
  paper's supplementary table. Base R, jsonlite and readxl only, with every
  URL in the code.
- `run_info.json` records the BARCS, R and package versions of the run.

`.github/workflows/reproduce-reanalyses.yaml` runs three small records on pull
requests that touch the package or the records and weekly; dispatch it with
`all` to check every record.

