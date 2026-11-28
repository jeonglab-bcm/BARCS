# Evidence atlas (v0.1, synthetic data only)

A read-only, gene-centric browser over an explicitly approved collection of benign
developmental and cell biology studies. Every card traces back to its source record and
publication. Observations, author claims, statistics, BARCS reanalysis assessments and external
annotations are kept apart. Nothing is published without a complete review.

This is separate from `tools/evidence-graph/` and does not touch the R package or
`reanalyses/`. Right now it contains **only fictional fixtures**. No archive record has been
imported. Kelly decides the scope first (see `review/README.md` and `DECISIONS.md`).

```sh
cd tools/evidence-atlas
python3 -m unittest discover -s tests               # stdlib only (Python >= 3.11)
python3 -m atlas validate fixtures/synthetic
python3 -m atlas build fixtures/synthetic           # -> build/public/{atlas.json,index.html,MANIFEST.json}
python3 -m atlas queue fixtures/synthetic           # withheld records and why
python3 -m atlas lookup DEMO1                       # reads the public export only
python3 -m atlas check-append-only --base origin/main   # review logs only grew (CI runs this)
python3 -m atlas review fixtures/synthetic --target ob_... --reviewer NAME --decision approve \
    --rationale "..." --check source_identity=confirmed --check wording=corrected ... \
    --approved-wording "..."                        # appends; never rewrites
python3 fixtures/make_synthetic.py                  # regenerate fixtures (tests check they are current)
python3 review/make_candidates.py                   # regenerate the scope-review candidate list
```

Open `build/public/index.html` in a browser. `build/` is git-ignored. CI
(`.github/workflows/evidence-atlas.yaml`) runs the tests and a determinism check on Python 3.11
and 3.13.

## Layout

| Path | What |
|---|---|
| `DECISIONS.md` | Decisions taken and still open |
| `schema/schema.sql` | Versioned SQLite schema: tables, immutability triggers, provenance and eligibility views |
| `schema/SCHEMA.md` | Entity and field documentation, eligibility rule, input format |
| `atlas/validate.py` | Validators (fields, ids, references, uniqueness, identifiers, gene ids, review hash chain) |
| `atlas/eligibility.py` | Second, independent implementation of the eligibility rule, with withheld reasons |
| `atlas/build.py` | Build, gated export, export verification, reviewer pseudonyms, manifest |
| `atlas/review.py` | Append-only review entries and the review queue |
| `atlas/genes.py` | Symbol to HGNC/MGI id mapping from pinned reference snapshots (for the importer) |
| `atlas/site.py`, `web/template.html` | Static browser rendered from the public export |
| `fixtures/` | Fictional collection and its generator |
| `review/` | Candidate list, scope-decision log (empty) and the review procedure |
| `tests/` | Unit and integration tests |
| `REPORT.md` | Coverage and limitations |

The guide suggested a `validators/` directory. The validators live in `atlas/validate.py`
instead, so they can be imported as one package.

## Review log integrity

What is detected, and by what:

| Change to `reviews.jsonl` | Caught by |
|---|---|
| An entry edited | `entry_hash` (validator) |
| Entries removed from the middle or reordered | `prev_hash` chain (validator) |
| Entries removed from the end | `reviews.head.json` count and last hash (validator) |
| An entry appended by hand | `reviews.head.json`, unless the head is also edited by hand |
| The whole log and head rewritten consistently | Only the CI check `check-append-only` against the base branch, plus git history |

So the files alone show internal consistency. Being append-only over time is enforced by CI on
every PR and push, and by code review of the diff.

## Output boundaries

1. **Build:** validation errors stop the build.
2. **Export:** records are selected only through the `eligible_*` SQL views.
3. **Verification:** `verify_export` recomputes eligibility in Python. It fails the build if the
   two implementations differ, if any withheld id appears in the JSON or HTML, if a withheld gene
   symbol or id is reachable, or if a real reviewer name is exported.
4. **Application:** the page renders a record only if its embedded history ends in an approval.

The internal database (`build/internal/atlas.sqlite`) holds everything, including real reviewer
names, so the review queue can work. It is not an output and must not be published. The public
site is static and contains nothing but the export, so a direct URL cannot reach a withheld
record.
