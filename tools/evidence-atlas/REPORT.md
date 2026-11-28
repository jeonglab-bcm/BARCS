# Report: v0.1 (2026-11-28)

## Status by milestone

| Milestone | State |
|---|---|
| M0 Inventory and scope | Archive structure inspected on one record (`schema/SCHEMA.md`). `review/candidates.tsv` lists all 149 records for Kelly; 58 have flag terms. `review/scope_decisions.tsv` is **empty**, so no real study has been approved or imported. Synthetic fixtures were written independently of any archive study. |
| M1 Schema and validators | Done for fixtures. Covers schema v2, foreign keys, uniqueness, immutability triggers, opaque ids, gene ids, the validators, deterministic builds and a manifest. |
| M2 Review workflow | CLI queue and an append-only, hash-chained review log. Original and corrected wording are both kept, and incomplete, uncertain or disputed records are withheld. Reviewers are pseudonymous in the export. There is no web review UI. |
| M3 Browser | Static gene lookup with six sections: observations, claims, statistics, BARCS assessment, annotations and provenance. Lookup works by symbol, previous symbol or id. It is rendered from the public export only and has been checked in Chromium. |
| M4 Evaluation and release | Not started for real data. Per `DECISIONS.md`, the first deployment will be a private artifact after a release review. |

## Synthetic build (fixtures/synthetic)

| Type | Exported | Withheld | Withheld reasons |
|---|---|---|---|
| study | 2 | 3 | rejected or out of scope (1), unreviewed (1), scope uncertain (1) |
| observation | 6 | 7 | study withheld (3), rejected (2, one of them a reviewer disagreement), incomplete checks (1), unreviewed (1) |
| claim | 3 | 1 | unreviewed (1) |
| assessment | 2 | 2 | study withheld (1), unreviewed (1) |
| annotation | 1 | 2 | unreviewed model-generated (1), gene not in collection (1) |

Every exported card resolves to a source with an https link. Rebuilding gives byte-identical
outputs:

- `atlas.json`: sha256 `caa0f4…5060`
- `index.html`: sha256 `ee34b3…186b`
- internal DB content: sha256 `ac0829…f0cf`

Python 3.13 / SQLite 3.53. Other versions may change the DB content hash but not the JSON or the
HTML.

Tests: 50 pass (`python3 -m unittest discover -s tests`). They cover every item of the guide's
testing checklist, plus assessments, pseudonyms, gene-id grouping and the reference mapper. The
isolation check runs when `ATLAS_CHECK_ISOLATION=1`, which CI sets.

## Not measured yet

These need a reviewed real collection:

- reviewer agreement;
- faithful transcription against archived `genes.csv.gz`;
- coverage within the approved scope.

## Limitations

- Synthetic data only. Every gene, study and publication is fictional, including the
  `HGNC:9900xx` ids.
- There is no importer from `reanalyses/` yet. It should read only GSEs marked `include` in
  `review/scope_decisions.tsv`, verify `archive_sha256` and `artifact_sha256`, and map genes with
  `atlas/genes.py`.
- The MGI column layout in `atlas/genes.py` is assumed. Check it against the snapshot. Species
  other than human and mouse stay unmapped.
- The candidate flag terms and the scope tripwire are aids for the reviewer. Scope is decided by a
  person.
- The review files show internal consistency only. A log and head rewritten together are caught by
  the CI append-only check against the base branch and by git history, not by the files.
- The leak scan checks ids everywhere, and withheld gene symbols, gene ids and reviewer names in
  structured fields. A withheld gene or a reviewer's name in the free text of an approved record
  would not be caught.

## Next steps

1. Kelly fills `review/scope_decisions.tsv` for 3–5 benign studies.
2. Build an importer for those records only, with hash checks and pinned HGNC/MGI snapshots.
3. Review the imported records and run the M4 measurements.
4. Hold a release review, then publish a private artifact.
