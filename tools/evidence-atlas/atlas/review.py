"""Append-only review history and the review queue."""

from datetime import datetime, timezone

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
    probs = errors(validate(coll))
    if probs:
        raise ValueError("review rejected:\n  " + "\n  ".join(map(str, probs)))
    path = coll.directory / "reviews.jsonl"
    with path.open("a", encoding="utf-8") as fh:
        fh.write(M.canonical_json(entry) + "\n")
    return entry


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
