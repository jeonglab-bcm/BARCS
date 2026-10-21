# Evidence graph

An evidence graph over every record in `reanalyses/`, joined to STRING v12.5,
with deterministic query tools for an agent, a set of gap analyses and a static
explorer page. It is stored in SQLite, so it can be queried with SQL or loaded
into a graph database later.

Live page: https://jeonglab-bcm.github.io/BARCS/evidence-graph/

```sh
tools/evidence-graph/build.sh      # download STRING v12.5 + CEGv2 once (~600 MB), build, analyse, write viz/explorer.html (~8 min)
cd tools/evidence-graph
uv run python -m barcs_kg.tools get_gene_evidence gene=IL2RA
sqlite3 build/barcs_kg.sqlite
```

Needs `uv` and Node. `build/` (SQLite, STRING files) is git-ignored; `reports/`
and `viz/explorer.html` are committed. The site workflow does not run the build:
it copies the committed `viz/explorer.html` to `_site/evidence-graph/`, so rerun
`build.sh` and commit the page after `reanalyses/` changes.

Findings from the first build are in [`reports/FINDINGS.md`](reports/FINDINGS.md).

## Pathway map

The explorer's first tab. `pathways.py` asks which interacting genes are hit
together in screens from different papers. For every STRING physical pair
(score ≥ 700) it counts the papers in which one screen calls both genes, against
the count each paper's hit rate predicts (Poisson, one paper's screens counted
once, BH over all pairs). Replicated pairs join into modules; each module is
shown with the screens that hit it and the direction of every call. Fitness
genes, the rest of each essential machine (ribosome, spliceosome, EIF3) and
frequent hitters are removed before counting.

Module names and themes come from `curation/module_names.tsv`, screen labels
from `curation/screen_labels.tsv`. Both are drafts written while building the
page; edit them and rebuild.

What the map can and cannot say: requiring a known physical interaction and
replication across papers selects robust, mostly known biology (IFN-γ
receptor–JAK, TAP/B2M and FADD–CASP8 in tumour cells under T or NK cell attack;
IL-2–STAT5 for CD25). It validates the reanalyses and catalogues generic hits
(EMC, Mediator, SAGA in reporter sorts); it is not a discovery screen by itself.

An earlier version of the page correlated whole screens (`similarity.py`, kept
but not run by `build.sh`). Its edges tracked how much growth signal each screen
carried: across 8,546 cross-paper pairs, r correlated 0.72 with the product of
the two screens' fitness loads, and 98.5% of reported edges had the sign that
product predicts. Regressing on more fitness profiles lowered but did not remove
this, so that view was replaced by the gene-level one.

## What is in the graph

| Layer | Table | Source |
|---|---|---|
| Publication, GEO series | `publication`, `series` | `meta.json` |
| Experiment design, samples | `design`, `sample` | `design*.json` |
| Contrast (with orientation of a positive estimate) | `contrast` | `design*.json` analyses + `run_info.json` |
| Gene-level result, **every tested element** | `result` | `results/<analysis>/genes.csv.gz` |
| Paper claim (named gene) | `claim`, `comparison` | `compare*.json` |
| Organism, modality, selection class | `series_annotation`, `contrast_annotation` | rules in `annotate.py`, each with a `*_basis` |
| Element type and gene identity | `element`, `element_gene` | `annotate.py` (promoters, peaks, pairs, miRNA, lncRNA, Excel-mangled names) |
| Gene → STRING protein | `gene_protein` | STRING aliases; ambiguous and unmapped symbols kept with their match type |
| STRING physical (≥400), functional (≥700), regulatory (≥400, directed, signed channels) | `string_*` | STRING v12.5 bulk files |

The three sign conventions stay separate: `contrast_annotation.modality`
(what the perturbation does), `contrast.orientation` (what a positive
estimate means for guide abundance), and `string_regulatory.positive/negative`
(biological regulation). The link between the second and a phenotype,
`contrast_annotation.readout` / `positive_estimate_means`, is **not filled
in**; `interpret_perturbation_effect` abstains until it is.

## Curation

`curation/*.template.tsv` are written on every build with what the graph
already knows. Copy one to `contrast_readout.tsv` or `claim_direction.tsv`,
fill the blank columns, and rebuild; `annotate.py` merges whatever is filled.

## Modules

| File | Does |
|---|---|
| `barcs_kg/ingest.py` | BARCS records → SQLite |
| `barcs_kg/annotate.py` | organism, modality, selection class, element types, curation merge |
| `barcs_kg/string_db.py` | STRING v12.5 mapping and networks |
| `barcs_kg/analyses.py` | gap analyses → `reports/*.tsv`, `reports/summary.json` |
| `barcs_kg/pathways.py` | pathway map: STRING pairs hit together across papers, grouped into modules |
| `barcs_kg/unified.py`, `viz/layout.mjs` | the whole graph as JSON and GraphML, with a ForceAtlas2 layout |
| `barcs_kg/export_viz.py` | inlines the page's data into `viz/explorer.template.html` → `viz/explorer.html` |
| `barcs_kg/similarity.py` | screen-to-screen profile correlation (not in the build; confounded by fitness, see above) |
| `barcs_kg/tools.py` | agent tools (JSON in, JSON out) |
