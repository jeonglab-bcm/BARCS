# Schema, version 1

Authoritative tables are in `schema.sql`. This file explains them.

## Input format

A collection directory contains:

- `collection.json`: `schema_version`, `collection` (`id`, `title`, `synthetic`), and one list
  per record type (`sources`, `datasets`, `studies`, `analyses`, `observations`, `claims`,
  `annotations`).
- `reviews.jsonl`: one review per line. The history is append-only and hash-chained.

Every field must be present. `null` means unknown, and it is displayed as unknown. Unknown fields
are an error.

## Identifiers

Identifiers are opaque and stable: `<prefix>_<12 hex>`. The prefixes are `src`, `ds`, `st`, `an`,
`ob`, `cl`, `at`, `as` and `rv`. A review id is `rv_` plus the first 12 hex characters of its
`entry_hash`. Ids are unique across all types.

## Entities

| Entity | Key fields | Notes |
|---|---|---|
| source | kind, identifier_scheme (`doi`/`pmid`/`url`/`fixture`), identifier, citation, url (https), accessed | `UNIQUE(identifier_scheme, identifier)` |
| dataset | accession, version (nullable), described_by → source | |
| study | dataset_id, title, scope_category, archive_ref, archive_sha256, validation_status, organism | Points to the archive record and its content hash; the archive file itself is not copied |
| analysis | study_id, label, method, method_version, fdr_threshold (nullable), artifact_ref, artifact_sha256 | |
| observation | analysis_id, gene_symbol, gene_id, gene_id_status, source_wording, estimate, estimate_meaning, p_value, fdr, n_elements, direction, limitations | One analysis's result. Never merged across studies |
| claim | source_id, study_id, gene_symbol, gene_id, gene_id_status, source_wording (verbatim), source_location | Author interpretation. No statistics fields |
| annotation | gene_symbol, gene_id, gene_id_status, vocabulary, vocabulary_version, term_id, term_label, attribution, origin (`curated`/`model_generated`) | |
| assessment | study_id, agreement (`agree`/`partial`/`differ`, nullable), verdict_wording, assessed_by, archive_ref, archive_sha256 | The BARCS project's comparison with the paper (meta.json). Not an author claim. Shown in its own section |
| review | target_type, target_id, revision, reviewer, timestamp, decision, rationale, checks, approved_wording, scope_decision, prev_hash, entry_hash | Append-only. Reviewer wording is stored here, never in the source row |

Review `checks` covers `source_identity`, `wording`, `measurement_interpretation`,
`statistical_representation` and `scope`. Each takes one of `confirmed`, `corrected`,
`not_applicable`, `uncertain` or `missing`. If `wording` is `corrected`, `approved_wording` is
required. `approved_wording` is allowed only in that case.

## Gene identity

- `gene_id` is `HGNC:<n>` or `MGI:<n>`.
- `gene_id_status` is one of:
  - `mapped`: an exact current symbol;
  - `synonym`: a unique match through a previous symbol or alias;
  - `ambiguous`: several candidates, and `gene_id` is null;
  - `unmapped`: no candidate, and `gene_id` is null.

Records are grouped by `gene_key`, which is the id when it is mapped or a synonym, and otherwise
`symbol:<SYMBOL>`. So a previous symbol and the current one show on one page, while an unmapped
symbol stays on its own page.

Every status except `mapped` produces a validator warning and a banner on the page. Mapping comes
from pinned HGNC and MGI snapshots (`atlas/genes.py`). The importer records each snapshot's
version and sha256.

## Provenance relationships (view `provenance_edge`)

These are evidence references, not causal assertions:

- dataset `described_by` source
- study `references` dataset
- analysis `derived_from` study
- observation `documented_by` analysis
- claim `attributed_to` source
- annotation `sourced_from` vocabulary
- assessment `reports_on` study
- review `assesses` record

## Eligibility

A reviewable record (study, observation, claim, annotation or assessment) is **approved** only when
**every reviewer's latest review** of it meets all of these conditions:

- the decision is `approve`;
- no check is `uncertain` or `missing`;
- for a study, `scope_decision = in_scope` and the scope check is `confirmed`.

A single dissenting reviewer withholds the record until that same reviewer reviews it again.
There is no automatic resolution.

A record is exported if:

- **study:** it is approved and its `scope_category` is permitted (`developmental_biology` or
  `cell_biology`). The excluded categories (`pathogen`, `host_susceptibility`, `transmission`,
  `virulence`, `immune_evasion`, `toxin`, `security_sensitive`) and `uncertain` can never be
  exported, whatever the review says.
- **observation:** it is approved and its study is exported.
- **claim:** it is approved and its study is exported.
- **annotation:** it is approved and its gene has an exported observation or claim. A
  model-generated annotation needs the same approval as any other.
- **assessment:** it is approved, its study is exported, and that study contributes an exported
  observation or claim.
- **source, dataset, analysis:** only as the provenance of an exported record.

Reviewers appear in the export as `Reviewer n`, numbered by their first review in the
collection. Real names stay in `reviews.jsonl` and the internal database.

The display wording (for observations, claims and assessments) is the latest review's `approved_wording` when there is one. Otherwise it is
`source_wording`. Both are exported.

`fdr_below_threshold` is `true` or `false` only when both the FDR and the analysis threshold were
archived. Otherwise it is `null`. The page never turns significance into a statement about
biology.

## Inputs observed in the archive (M0 inventory, for a future importer)

Inspected on one record, `reanalyses/GSE138776/`. This was read only to learn the structure. It
does not approve that record.

| Archive file | Fields | Would map to |
|---|---|---|
| `meta.json` | gse, pmid, doi, title, journal, published, named_hits, verdict, agreement, analyzed | source (doi/pmid), dataset (gse), study (title) |
| `design.json` | counts_file, samples, analyses[name, formula, term], rationale, counts_md5 | analysis label, estimate meaning |
| `results/<analysis>/run_info.json` | BARCS version and settings | analysis method_version |
| `results/<analysis>/genes.csv.gz` | gene, n_guides, estimate, p_value, fdr, empirical_* | observation (only reviewed rows) |
| `compare.json` | named_hits, direction | candidate claims; the verbatim wording must come from the publication, not from this list |
| `meta.json` agreement, verdict | | assessment |
| `reanalyses/validation.tsv` | per-record validation | study validation_status (no completed rows at review time) |

`meta.json` fields `verdict` and `agreement` map to the `assessment` record, never to a claim.
