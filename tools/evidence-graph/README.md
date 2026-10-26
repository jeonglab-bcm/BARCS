# Evidence graph

An evidence graph over every record in `reanalyses/`, joined to STRING v12.5,
with deterministic query tools for an agent, a set of gap analyses and a static
explorer page. It is stored in SQLite, so it can be queried with SQL or loaded
into a graph database later.

Live page: https://jeonglab-bcm.github.io/BARCS/evidence-graph/

```sh
tools/evidence-graph/build.sh      # download STRING v12.5 + CEGv2 once (~600 MB), build, analyse, write viz/explorer.html (~8 min)
tools/evidence-graph/build_areas.sh  # then: one pathway map per biology area, re-export the page (~7 min)
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

The buttons under the tabs filter every view to one biology area
(`curation/screen_areas.tsv`: one area per GEO series, by the question the screen
asks). The pathway map is not the full map with other screens hidden:
`build_areas.sh` rebuilds it on each area's screens alone, with that area's own
growth genes and frequent hitters, into `viz/pathways_<area>.json`. Areas with
10+ eligible papers use the main settings and the per-pair test; smaller ones
fall back to a shuffled-hit control, admitting focused libraries and, only if
nothing passes otherwise, screens that call over 10% of genes (the page says so).

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

## Biolink knowledge graph

`export_biolink.py` writes the findings as a knowledge graph in the schema of
an existing knowledge base: the [Biolink Model](https://biolink.github.io/biolink-model/)
4.4.6, the data model of the NCATS Translator and Monarch graphs, in KGX TSV
(`build/biolink/nodes.tsv`, `edges.tsv`, `prefixes.json`, `stats.json`). Every
category, predicate, qualifier value and required edge slot is checked against
the pinned `biolink-model.yaml` before anything is written.

```sh
uv run python -m barcs_kg.export_biolink build/barcs_kg.sqlite build/string_v12.5 \
  build/reference/biolink-model-4.4.6.yaml build/biolink
```

| Node category | Identifier | What |
|---|---|---|
| `biolink:Gene` | `NCBIGene` (human), `ENSEMBL` (mouse, rat, cow) via STRING aliases; `BARCS.GENE:<taxon>-<symbol>` when unmapped | tested genes |
| `biolink:PhenotypicFeature` | `BARCS.SCREEN_PHENOTYPE:<GSE>.<contrast>` | relative guide abundance between a contrast's two conditions |
| `biolink:PhenotypicFeature` | `BARCS.PHENOTYPE:<readout>` | curated readout of 80 screens (`curation/contrast_readout.tsv`) |
| `biolink:Study` | `BARCS.SCREEN:<GSE>.<contrast>`, xref `GEO:` | one screen contrast |
| `biolink:Publication`, `biolink:OrganismTaxon` | `PMID`, `NCBITaxon` | |

| Layer | Edge | Category | Qualifiers and provenance |
|---|---|---|---|
| screen | gene `contributes_to` screen phenotype | `GeneToPhenotypicFeatureAssociation` | every call at FDR < 0.10; `subject_form_or_variant_qualifier` loss/gain-of-function form (KO, CRISPRi / CRISPRa); `object_direction_qualifier` increased when guides are more abundant in the first condition; `effect_size`, `p_value`, `adjusted_p_value`; statistical_association, data_analysis_pipeline |
| readout | gene `contributes_to` readout | same | the same calls on 75 curated screens, direction mapped through `curation/readout_direction.tsv` |
| claim | gene `associated_with` readout or screen phenotype | same | genes the paper names; knowledge_assertion, manual_agent, no direction |
| string | gene `physically_interacts_with` gene | `PairwiseGeneToGeneInteraction` | STRING physical ≥ 700, `has_confidence_score`, `infores:string` |
| string | gene `regulates` gene | `GeneRegulatesGeneAssociation` | STRING regulatory ≥ 700 with one sign channel ≥ 700 and the other < 400; `qualified_predicate` causes, aspect activity_or_abundance, direction from the sign |

Every BARCS edge carries `publications` (the paper whose data were reanalysed)
and `has_supporting_studies` (the screen). Only primary contrasts are exported,
and each gene keeps its best-p element per contrast. Reading an edge:
`NCBIGene:3559 (IL2RA) contributes_to "CD25 (IL2RA) surface level"`, loss-of-function
form, decreased: knocking out IL2RA lowers CD25.

Limits: the `BARCS.*` prefixes are local namespaces (no public identifiers exist
for these screens and readouts), so `kgx validate` reports them as unknown
prefixes; `infores:barcs` is not in the Translator registry. Readout labels are
free text, so near-duplicates (`CD25 (IL2RA) surface level`, `Surface CD25 (IL2RA)
level`) are separate nodes until the curation names them alike or maps them to an
ontology term. Five readouts abstain on direction (differential dropout, two-sided
or mixed readouts). `readout_direction.tsv`, like the other curation files, is
unreviewed.

`export_kg.py` remains the plain typed graph with a time split for link prediction.

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
| `barcs_kg/export_biolink.py` | Biolink Model knowledge graph, KGX TSV, validated against the model |
| `barcs_kg/export_kg.py` | plain typed graph with a time-based split for link prediction |
| `barcs_kg/export_viz.py` | inlines the page's data into `viz/explorer.template.html` → `viz/explorer.html` |
| `barcs_kg/similarity.py` | screen-to-screen profile correlation (not in the build; confounded by fitness, see above) |
| `barcs_kg/tools.py` | agent tools (JSON in, JSON out) |
