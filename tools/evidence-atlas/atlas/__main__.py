"""Command line: python -m atlas <command> ...  (run from tools/evidence-atlas)."""

import argparse
import json
import sys
from pathlib import Path

from . import build as B, model as M, review as R
from .validate import errors, validate

DEFAULT_OUT = M.ROOT / "build"


def main(argv=None):
    p = argparse.ArgumentParser(prog="python -m atlas")
    sub = p.add_subparsers(dest="cmd", required=True)

    v = sub.add_parser("validate", help="validate a collection directory")
    v.add_argument("collection")

    b = sub.add_parser("build", help="validate, build the internal DB and the gated public export")
    b.add_argument("collection")
    b.add_argument("--out", default=str(DEFAULT_OUT))

    q = sub.add_parser("queue", help="list withheld records and why")
    q.add_argument("collection")

    r = sub.add_parser("review", help="append a review (history is append-only)")
    r.add_argument("collection")
    r.add_argument("--target", required=True)
    r.add_argument("--reviewer", required=True)
    r.add_argument("--decision", required=True, choices=M.DECISIONS)
    r.add_argument("--rationale", required=True)
    r.add_argument("--check", action="append", default=[], metavar="NAME=VALUE",
                   help=f"one of {M.CHECKS} = {M.CHECK_VALUES}; unspecified checks are 'missing'")
    r.add_argument("--approved-wording")
    r.add_argument("--scope-decision", choices=M.SCOPE_DECISIONS)
    r.add_argument("--timestamp", help="YYYY-MM-DDTHH:MM:SSZ (default: now, UTC)")

    lk = sub.add_parser("lookup", help="look up a gene in a built public export")
    lk.add_argument("gene")
    lk.add_argument("--out", default=str(DEFAULT_OUT))

    a = p.parse_args(argv)
    if a.cmd == "validate":
        probs = validate(M.load(a.collection))
        for pr in probs:
            print(pr)
        print(f"{len(errors(probs))} errors, {len(probs) - len(errors(probs))} warnings")
        return 1 if errors(probs) else 0
    if a.cmd == "build":
        try:
            manifest, warnings = B.build(a.collection, a.out)
        except B.BuildError as e:
            print(e, file=sys.stderr)
            return 1
        for w in warnings:
            print(w)
        print(json.dumps(manifest["counts"], indent=2))
        print(f"wrote {Path(a.out) / 'public'}")
        return 0
    if a.cmd == "queue":
        rows = R.queue(M.load(a.collection))
        for t, rid, label, rs in rows:
            print(f"{t}\t{rid}\t{label}\t{','.join(rs)}")
        print(f"{len(rows)} withheld", file=sys.stderr)
        return 0
    if a.cmd == "review":
        checks = {}
        for item in a.check:
            k, _, val = item.partition("=")
            checks[k] = val
        try:
            e = R.append(a.collection, target_id=a.target, reviewer=a.reviewer, decision=a.decision,
                         rationale=a.rationale, checks=checks, approved_wording=a.approved_wording,
                         scope_decision=a.scope_decision, timestamp=a.timestamp)
        except ValueError as err:
            print(err, file=sys.stderr)
            return 1
        print(f"appended {e['id']} (revision {e['revision']} of {a.target})")
        return 0
    if a.cmd == "lookup":
        exp = json.loads((Path(a.out) / "public" / "atlas.json").read_text(encoding="utf-8"))
        g = exp["genes"].get(a.gene)
        if not g:
            print(f"{a.gene}: no approved records in this collection (unknown, not absent)")
            return 0
        print(json.dumps({k: [exp[k][i] for i in g[k]] for k in ("observations", "claims", "annotations")},
                         indent=2, sort_keys=True))
        return 0
    return 2


if __name__ == "__main__":
    sys.exit(main())
