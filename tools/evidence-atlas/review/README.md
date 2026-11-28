# Review procedure

## M0: scope decisions for real studies (not started)

No archive study is eligible yet. Kelly is the scope reviewer (`../DECISIONS.md`).

`candidates.tsv` lists every archive record with its title, its model and `flag_terms`. Flag
terms are words that often mark excluded topics. The list makes no decision, and an empty flag
column does not mean a study is in scope. Regenerate it with `python3 review/make_candidates.py`.

Before anything is imported, the reviewer records one row per chosen candidate in
`scope_decisions.tsv`:

| Column | Values |
|---|---|
| gse | archive record, `reanalyses/<GSE>/` |
| decision | `include`, `exclude` or `uncertain` (only `include` may be imported; `uncertain` stays out) |
| scope_category | one of the categories in `schema/SCHEMA.md` |
| permitted_display | what may be shown, e.g. `observations,claims` |
| reviewer, date | who decided and when |
| rationale | one sentence |

Exclude anything about pathogens, host susceptibility, transmission, virulence, immune evasion,
toxins or other security-sensitive topics, and anything derived from such studies. When in doubt,
mark it `uncertain`, which keeps it out. The first collection is 3–5 studies.

Then append the decisions to the file. Do not edit earlier rows. A changed decision is a new
row.

## M2: record review

For each imported record, run `python3 -m atlas queue <collection>` to see what is waiting. Then
append a review with `python3 -m atlas review ...` and confirm each check:

- **source_identity:** the record matches its publication or archive entry and its gene identity
  is unambiguous.
- **wording:** the text says what was measured. If it does not, mark it `corrected` and give
  `--approved-wording`. The original wording is kept.
- **measurement_interpretation:** the direction and the meaning of a positive estimate match the
  design.
- **statistical_representation:** the numbers match the archived artifact, including the analysis
  version.
- **scope:** for studies, it falls within the permitted scope.

If any check is `uncertain` or `missing`, the record is withheld. Never edit `reviews.jsonl` by
hand. The hash chain detects edits, deletions and reordering, `reviews.head.json` detects lines
removed from the end, and CI rejects any PR in which the log does more than grow. A model-generated annotation or
wording is never approved by the tool itself. A person must approve it.
