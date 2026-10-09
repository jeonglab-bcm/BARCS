---
name: screen-reanalysis
description: Find a recently published pooled CRISPR screen in PubMed with counts deposited in GEO, reanalyze it with BARCS, and report how BARCS differs from the paper's own results. Use when asked to reanalyze, re-check, or benchmark BARCS on a new or latest published screen, or on a specific PMID or GSE accession.
---

# Reanalyze a published CRISPR screen with BARCS

You drive the scripts in `tools/screen-reanalysis/`. The scripts do the
mechanical work; you make the judgment calls the scripts cannot: which series
is a real screen with raw counts, how count columns map to samples, which
coefficient answers the paper's question, and what the paper reported.

Work in `work/<GSE>/` (git-ignored). Run every script from the repository
root. Install BARCS first if needed: `R CMD INSTALL .`.

## 1. Find a candidate screen

If the user named a PMID or GSE, skip the search.

```sh
Rscript tools/screen-reanalysis/search_pubmed.R --days 180 --out work/screens.tsv
```

To extend the website rather than analyze one screen, search a longer window
(`--days 1095 --max 2000`), drop series already in `reanalyses/` or
`reanalyses/excluded.tsv`, and triage every remaining series with
`screen_score` of 2 or more. Every series you check ends up either reanalyzed
or in `excluded.tsv` with a one-sentence reason, so the site shows full
coverage; usable series not analyzed yet go in `search.json` as `pending`.

Pick the newest series with `screen_score` 3 (GEO type "Other" plus screen
keywords) and enough libraries for inference: at least two replicates per
condition you will compare. Prefer series whose supplementary files look like
a count matrix (`*count*`, `*sgrna*`, `*.txt.gz`, `*.csv`). Skip arrayed
screens, single-cell CRISPR (Perturb-seq), base/prime-editing variant scans,
and RNA-seq companion series. Tell the user which series you chose and why,
in one or two sentences.

## 2. Fetch and inspect

```sh
Rscript tools/screen-reanalysis/fetch_geo.R GSE123456 --dir work
Rscript tools/screen-reanalysis/inspect_counts.R work/GSE123456/suppl/<file>
```

Read `work/<GSE>/series.json` (summary, overall design) and `samples.tsv`
(one row per GSM). If no series-level count file exists, rerun `fetch_geo.R`
with `--sample-files` and combine the per-sample files yourself.

Decide, and write down why:

- **Is it raw counts?** Every sample column must be integer-valued. Never feed
  normalized, log-transformed, or CPM values to BARCS; if only those exist,
  stop and report that the screen cannot be reanalyzed faithfully.
- **Column-to-sample mapping.** Use column names, the GSM titles, and the
  correlation matrix from `inspect_counts.R` (replicates of one condition
  correlate most strongly). Generic names such as `S1..S9` usually follow GSM
  order; confirm with the correlations before relying on it.
- **Controls.** Note non-targeting or safe-harbor labels for
  `control_gene_pattern`.

## 3. Write `work/<GSE>/design.json`

```json
{
  "gse": "GSE123456",
  "pmid": "12345678",
  "counts_file": "suppl/GSE123456_counts.txt.gz",
  "guide_column": "sgRNA",
  "gene_column": "Gene",
  "control_gene_pattern": "^(NonTargeting|NTC)",
  "min_total_count": 30,
  "samples": [
    {"column": "S1", "gsm": "GSM1", "condition": "T0", "replicate": "1"},
    {"column": "S4", "gsm": "GSM4", "condition": "untreated", "replicate": "1"}
  ],
  "factor_levels": {"condition": ["T0", "untreated", "drug"]},
  "analyses": [
    {"name": "drug_vs_untreated", "columns": ["S4", "S5", "S7", "S8"],
     "formula": "~ condition", "term": "conditiondrug"}
  ],
  "rationale": "Why this mapping and these contrasts answer the paper's question."
}
```

Rules:

- The first level in `factor_levels` is the reference; `term` must be a
  model-matrix column name (for a factor: variable name + level).
- Reproduce the paper's main comparison first (for example drug versus
  vehicle, end point versus T0, high versus low sort). Add a second analysis
  only when the paper relies on one.
- Add a replicate or batch term only when replicates are paired across
  conditions (same infection or same donor); otherwise leave it out.
- Restrict `columns` to the samples in that comparison. Library totals are
  always computed over all guides before filtering, so do not filter guides.
- Set `"totals": "control"` only if the paper normalized to controls or the
  screen has strong composition shift and good controls; say so in
  `rationale`.

```sh
Rscript tools/screen-reanalysis/run_barcs.R work/GSE123456/design.json
```

Check the composition warning `run_barcs.R` prints (`top1pct_read_share` in
`run_info.json`). An unselected library puts 2-5% of reads on its top 1% of
guides. Above about 25%, strong selection or a few resistant clones dominate:
library totals then call most genes depleted. Rerun with
`"totals": "median_ratio"` and read enrichment first. If median-ratio totals
are reported as capped (single guides hold most of a library), say so: depletion
is uninterpretable. `run_barcs.R` uses `test = "auto"` (BARCS >= 0.2.1), which
tests guides whose abundance moves more than 100-fold by likelihood ratio; on
BARCS 0.2.0 the Wald test can miss the strongest enrichment (huge effect, huge
standard error). `guides_lr` in `run_info.json` counts the switched guides.

Check control calibration: `control_p05` in `run_info.json` is the share of
non-targeting guides at p < 0.05 and should be near 5%. `run_barcs.R`
calibrates to the controls automatically when the raw rate exceeds 7.5%
(`control_p05_raw`); say so in the report, because it shortens the hit list.
Without controls, say that calibration could not be checked.

Check the control null (BARCS >= 0.2.2, 100 or more usable controls):
`genes_empirical_fdr_0_10` counts genes against pseudo-genes built from the
controls, and the site shows it next to the model FDR. `control_shift` is how
far the targeting guides sit from the controls in z. Non-targeting controls
make no cut, so in knockout screens they often sit 0.3-0.75 z away; then
`run_barcs.R` centres the null on the targeting guides (`empirical_centre`
"targets"). Report the centred count. If a control-null count is far larger
than the model's and the null is still centred on the controls, the controls
are offset: do not quote that number. With one guide per gene the null cannot
go below p = 2 / (controls + 1); read zero calls there as "the controls cannot
confirm the model", not "no hits".

Look at the guides behind the top calls. A gene called from one guide with a
jackpot count (one library holding thousands of reads where the others hold
tens) is an artifact of a single clone; name such genes in the report and
discount them. Where controls are far more abundant than targeting guides,
they cannot show the noise of sparse guides, so a long hit list can still be
inflated after calibration; rerun with a higher `min_total_count` as a
sensitivity check and report both.

Check `results/<analysis>/run_info.json`: residual degrees of freedom of at
least 2, moderation applied, and a plausible guide correlation (real screens
are usually below 0.05; a large value suggests shared artifacts or a wrong
mapping).

## 4. Find what the paper reported

Collect, in this order of preference:

1. A gene-level results table (MAGeCK `gene_summary`, BAGEL, a supplementary
   Excel table) from GEO supplementary files or the paper's supplement. For
   open-access papers, list supplements with
   `https://www.ebi.ac.uk/europepmc/webservices/rest/<PMCID>/supplementaryFiles`.
2. The genes the paper highlights (abstract, title, validated hits).

Write `work/<GSE>/compare.json`:

```json
{
  "barcs_genes": "results/drug_vs_untreated/genes.csv",
  "direction": "depleted",
  "named_hits": ["GENE1", "GENE2"],
  "published": {
    "file": "paper/TableS2.xlsx", "sheet": "drug vs vehicle",
    "gene_column": "id", "score_column": "neg|score", "score_better": "lower",
    "effect_column": "neg|lfc"
  },
  "top_n": [50, 100, 200]
}
```

Omit `published` when no table is available; the named hits still give a
comparison. Match `direction` to the paper's question (sensitizers and
essential genes are depleted; resistance genes are enriched).

```sh
Rscript tools/screen-reanalysis/compare_results.R work/GSE123456/compare.json
```

## 5. Report

Write `work/<GSE>/REPORT.md` and give the user a short summary:

- the paper (PMID, title), series, and the comparison you reproduced;
- the design you chose and anything uncertain about it;
- where BARCS agrees with the paper (named hits' ranks, top-N overlap, rank
  correlation) and where it differs, with the strongest BARCS-only and
  paper-only genes;
- likely reasons for differences: replicate-aware degrees of freedom and
  dispersion moderation in BARCS, versus pooled or median-normalized counts,
  RRA rank aggregation, or permutation p-values in the original method;
- limits: processed inputs, dependent libraries, missing replicates.

State plainly when the reanalysis could not reproduce the paper's setup, and
never present a guessed column mapping as certain.

## 6. Publish to the website

Write `work/<GSE>/meta.json` with the headline facts the site shows:

```json
{
  "gse": "GSE123456", "pmid": "12345678", "doi": "10.xxxx/yyyy",
  "title": "Paper title", "journal": "Journal", "published": "2026",
  "model": "Cell line, library", "contrast": "Drug vs vehicle, day 14 (3 vs 3)",
  "paper_method": "MAGeCK-RRA", "paper_calls": "42 genes at FDR 0.05",
  "barcs_calls": "35 genes at FDR 0.10", "named_hits": "4/5 recovered",
  "verdict": "One sentence: where BARCS and the paper agree and differ.",
  "agreement": "agree", "analyzed": "2026-10-06"
}
```

`agreement` is `agree` (the paper's main hits pass FDR 0.10 in BARCS),
`partial` (some do), or `differ` (none do, or BARCS contradicts them). Then:

```sh
Rscript tools/screen-reanalysis/archive_run.R work/GSE123456
Rscript tools/screen-reanalysis/build_site.R      # preview in _site/index.html
```

Every record must be reproducible from public data. If you built the count
file or the paper's table by hand (merged per-sample files, summed barcodes,
fixed an encoding, converted a supplement), put that code in
`work/<GSE>/prepare.R` (R only, URLs in the code; it takes the work directory
as its argument) and archive it with the record. Add `"fetch"` options and
`counts_md5` (`tools::md5sum` of the count file) to `design.json`, then check:

```sh
Rscript tools/screen-reanalysis/reproduce.R GSE123456          # must print OK
```

Commit `reanalyses/<GSE>/` on a branch and open a pull request only if the
user asks. Merging to `main` rebuilds and deploys the site
(`.github/workflows/reanalysis-site.yaml`).
