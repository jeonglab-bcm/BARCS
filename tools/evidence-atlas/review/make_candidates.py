"""List archive records for scope review: review/candidates.tsv.

    python3 review/make_candidates.py      (from tools/evidence-atlas)

Reads only reanalyses/*/meta.json (title, model, contrast). Makes no decision: the
`flag_terms` column lists words that often mark excluded topics (pathogens, immune
evasion, toxins...) so the reviewer looks twice; an empty column does not mean in scope.
Decisions go in scope_decisions.tsv, written by the reviewer.
"""

import csv
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPO = ROOT.parent.parent
sys.path.insert(0, str(ROOT))

from atlas.validate import SCOPE_TRIPWIRE  # noqa: E402

REVIEW_FLAGS = re.compile(
    r"\b(immun\w*|T[- ]cells?|NK|CAR|interferon\w*|IFN\w*|cytotox\w*|antigen\w*|MHC|HLA|"
    r"inflamm\w*|lethal\w*|drug resistan\w*)\b", re.I)


def main():
    rows = []
    for meta in sorted((REPO / "reanalyses").glob("*/meta.json")):
        m = json.loads(meta.read_text(encoding="utf-8"))
        text = " ".join(str(m.get(k, "")) for k in ("title", "model", "contrast"))
        terms = sorted({t.group(0).lower() for pat in (SCOPE_TRIPWIRE, REVIEW_FLAGS) for t in pat.finditer(text)})
        rows.append({"gse": m.get("gse", meta.parent.name), "pmid": m.get("pmid", ""),
                     "title": m.get("title", ""), "model": m.get("model", ""),
                     "flag_terms": ",".join(terms)})
    out = ROOT / "review" / "candidates.tsv"
    with out.open("w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0]), delimiter="\t", lineterminator="\n")
        w.writeheader()
        w.writerows(rows)
    flagged = sum(1 for r in rows if r["flag_terms"])
    print(f"wrote {out}: {len(rows)} records, {flagged} with flag terms")


if __name__ == "__main__":
    main()
