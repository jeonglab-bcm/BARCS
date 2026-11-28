"""Append-only review history and the review queue."""

from datetime import datetime, timezone
from pathlib import Path

from . import eligibility, model as M
from .validate import errors, validate


def make_entry(prev_hash, revision, target_type, target_id, reviewer, decision, rationale,
               checks, approved_wording=None, scope_decision=None, timestamp=None):
    entry = {
        "target_type": target_type, "target_id": target_id, "revision": revision,
        "reviewer": reviewer,
        "timestamp": timestamp or datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "decision": decision, "rationale": rationale,
        "checks": {c: checks.get(c, "missing") for c in M.CHECKS},
        "approved_wording": approved_wording, "scope_decision": scope_decision,
        "prev_hash": prev_hash,
    }
    entry["entry_hash"] = M.review_entry_hash(entry)
    entry["id"] = f"{M.REVIEW_PREFIX}_{entry['entry_hash'][:12]}"
    return entry


def append(collection_dir, **kw):
    """Append one review to reviews.jsonl after validating the result. Never rewrites history."""
    coll = M.load(collection_dir)
    idx = coll.index()
    target_id = kw["target_id"]
    if target_id not in idx:
        raise ValueError(f"unknown record {target_id}")
    target_type = idx[target_id][0]
    prev = coll.reviews[-1]["entry_hash"] if coll.reviews else M.GENESIS_HASH
    revision = 1 + sum(1 for r in coll.reviews if r["target_id"] == target_id)
    entry = make_entry(prev, revision, target_type, **kw)
    coll.reviews.append(entry)
    coll.head = M.review_head(coll.reviews)   # the head this append will write
    probs = errors(validate(coll))
    if probs:
        raise ValueError("review rejected:\n  " + "\n  ".join(map(str, probs)))
    path = coll.directory / "reviews.jsonl"
    with path.open("a", encoding="utf-8") as fh:
        fh.write(M.canonical_json(entry) + "\n")
    M.write_head(coll.directory, coll.reviews)
    return entry


def check_append_only(base, repo):
    """Compare every reviews.jsonl in the working tree of `repo` with git ref `base`.

    Fails closed: an unresolvable base, or a log present at base but missing now
    (deleted or moved), is a problem. Returns (problems, notes).
    """
    import subprocess

    def git(*args, check=True):
        return subprocess.run(["git", "-C", str(repo), *args], capture_output=True, text=True, check=check)

    if git("rev-parse", "--verify", "--quiet", f"{base}^{{commit}}", check=False).returncode != 0:
        return [f"base ref {base!r} does not resolve to a commit (fetch it, e.g. fetch-depth: 0)"], []
    top = git("rev-parse", "--show-toplevel").stdout.strip()
    is_log = lambda p: p == "reviews.jsonl" or p.endswith("/reviews.jsonl")  # noqa: E731
    at_base = {p for p in git("ls-tree", "-r", "--full-tree", "--name-only", base).stdout.splitlines() if is_log(p)}
    now = {p for p in git("ls-files", "--full-name", "--cached", "--others", "--exclude-standard",
                          ":(top)").stdout.splitlines() if is_log(p) and (Path(top) / p).is_file()}
    problems, notes = [], []
    for p in sorted(at_base - now):
        problems.append(f"{p}: present at {base} but missing now (deleted or moved)")
    for p in sorted(at_base & now):
        old = git("show", f"{base}:{p}").stdout
        new = (Path(top) / p).read_text(encoding="utf-8")
        problems += [f"{p}: {msg} relative to {base}" for msg in append_only_problems(old, new)]
    for p in sorted(now - at_base):
        notes.append(f"{p}: new since {base}, nothing to compare")
    notes.append(f"checked {len(at_base & now)} review log(s) against {base}")
    return problems, notes


def append_only_problems(old_text, new_text):
    """Problems if new_text is not old_text with lines added at the end (empty list = fine)."""
    old, new = old_text.splitlines(), new_text.splitlines()
    if len(new) < len(old):
        return [f"{len(old) - len(new)} review line(s) removed"]
    for n, (a, b) in enumerate(zip(old, new), 1):
        if a != b:
            return [f"line {n} changed"]
    return []


def queue(coll):
    """Reviewable records that are withheld, with reasons, sorted by type then id."""
    reasons = eligibility.record_reasons(coll)
    idx = coll.index()
    rows = []
    for (t, rid), rs in sorted(reasons.items()):
        if rs:
            rec = idx[rid][1]
            label = rec.get("title") or rec.get("gene_symbol") or ""
            rows.append((t, rid, label, rs))
    return rows
