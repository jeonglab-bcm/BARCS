# Decisions

Hyun-Hwan Jeong made these decisions on 2026-11-28. Change a decision by adding a new entry. Do
not edit old ones.

| # | Question | Decision | Where it is implemented |
|---|---|---|---|
| 1 | Who approves which archive studies are imported (M0)? | **Kelly** (incoming maintainer) | `review/README.md`; `review/candidates.tsv` is prepared for her, and `review/scope_decisions.tsv` is hers to fill |
| 2 | Size of the first real collection | **3–5 studies** | `review/README.md` |
| 3 | Reviewer identity in public output | **Hidden**: exported as "Reviewer n"; real names stay in `reviews.jsonl` and the internal DB | `build.reviewer_pseudonyms`, checked in `verify_export` |
| 4 | Show the BARCS project's own `agreement` and `verdict` (meta.json)? | **Yes, as a separate section**, labelled as a project assessment and not as an author claim | `assessment` record type; section 4 of the page |
| 5 | Does that assessment need review? | **Yes, the same review as other records**; it is withheld until approved | `eligible_assessment` view; `eligibility.py` |
| 6 | Deployment | **A private claude.ai artifact first**, after a release review. Nothing is deployed yet | Not built |
| 7 | CI | **Add a workflow** for atlas changes only | `.github/workflows/evidence-atlas.yaml` |
| 8 | Gene identity | **Add HGNC/MGI ids** from **pinned HGNC and MGI snapshots**. Unmapped, ambiguous and synonym matches are flagged for review, not blocked | `gene_id`, `gene_id_status`, `gene_key`; `atlas/genes.py` |
| 9 | Branch history | **Squash before the PR** | Done on `claude/barcs-evidence-platform-r7lnct` |
| 10 | Next step | **Implement the items above, then open a PR**. Importing real records waits for decision 1 | This PR |

## Still open

- **Release review:** who does it, and what is the checklist before the private artifact?
- **MGI layout:** the column names for the MGI bulk file are assumed in `atlas/genes.py`
  (`LAYOUTS["mgi"]`). Check them against the downloaded snapshot before the first import.
- **Other species:** some archive screens use species other than human or mouse. With
  decision 8 they stay `unmapped` unless another reference is added.
