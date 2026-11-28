"""Build: validate -> internal SQLite -> gated public export -> verify -> site -> manifest."""

import json
import re
import shutil
import sqlite3
from pathlib import Path

from . import eligibility, model as M, site
from .validate import errors, validate

NOTICES = {
    "observation": "Reviewed result from one archived analysis. Observations from different "
                   "studies are never merged, even when they concern the same gene.",
    "claim": "Author interpretation, quoted from the publication. Not an observation and not "
             "checked against the statistical assessment.",
    "statistics": "Statistical assessment as archived, with the analysis version that produced it. "
                  "It measures evidence against no change in this experiment; it does not establish "
                  "a causal or mechanistic relationship.",
    "not_below_threshold": "Not below the archived FDR threshold. This is not evidence that a "
                           "biological relationship is absent.",
    "unknown": "Not recorded in the source. Shown as unknown; nothing is inferred.",
    "annotation": "External vocabulary annotation, kept separate from experimental observations.",
    "assessment": "The BARCS project's comparison of its reanalysis with the paper's results. "
                  "Not an author claim and not an observation; it concerns the whole study, not this gene alone.",
    "gene_identity": "Gene identity was not matched exactly to a current symbol; see the review of source identity.",
    "reviewers": "Reviewers are shown by pseudonym, numbered in order of their first review in this collection.",
    "direction_conflict": "Records report different directions. They are shown separately and not reconciled.",
}


class BuildError(Exception):
    pass


def create_db(path):
    path = Path(path)
    if path.exists():
        path.unlink()
    con = sqlite3.connect(path)
    con.executescript(M.SCHEMA_SQL.read_text(encoding="utf-8"))
    con.execute("PRAGMA foreign_keys = ON")
    return con


def load_db(con, coll):
    for rtype in M.TYPES:
        cols = list(M.FIELDS[rtype])
        rows = sorted(coll.records(rtype), key=lambda r: r["id"])
        con.executemany(
            f"INSERT INTO {rtype} ({','.join(cols)}) VALUES ({','.join('?' * len(cols))})",
            [tuple(r[c] for c in cols) for r in rows])
    for seq, rv in enumerate(coll.reviews, 1):
        con.execute(
            "INSERT INTO review (id, seq, target_type, target_id, revision, reviewer, timestamp, decision,"
            " rationale, check_source_identity, check_wording, check_measurement_interpretation,"
            " check_statistical_representation, check_scope, approved_wording, scope_decision,"
            " prev_hash, entry_hash) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            (rv["id"], seq, rv["target_type"], rv["target_id"], rv["revision"], rv["reviewer"],
             rv["timestamp"], rv["decision"], rv["rationale"], *(rv["checks"][c] for c in M.CHECKS),
             rv["approved_wording"], rv["scope_decision"], rv["prev_hash"], rv["entry_hash"]))
    con.commit()


def db_content_hash(con):
    return M.sha256_bytes("\n".join(con.iterdump()).encode("utf-8"))


def _rows(con, view):
    con.row_factory = sqlite3.Row
    rows = [dict(r) for r in con.execute(f"SELECT * FROM {view} ORDER BY id")]
    con.row_factory = None
    return rows


def export(con, coll):
    """Public export, selected only through the eligible_* views."""
    out = {
        "schema_version": M.SCHEMA_VERSION,
        "tool_version": M.TOOL_VERSION,
        "collection": coll.data["collection"],
        "notices": NOTICES,
    }
    for key, view in (("sources", "eligible_source"), ("datasets", "eligible_dataset"),
                      ("studies", "eligible_study"), ("analyses", "eligible_analysis"),
                      ("observations", "eligible_observation"), ("claims", "eligible_claim"),
                      ("annotations", "eligible_annotation"), ("assessments", "eligible_assessment")):
        out[key] = {r["id"]: r for r in _rows(con, view)}

    exported_targets = set()
    for key in ("studies", "observations", "claims", "annotations", "assessments"):
        exported_targets |= set(out[key])
    pseudonyms = reviewer_pseudonyms(coll)
    con.row_factory = sqlite3.Row
    reviews = {}
    for r in con.execute("SELECT * FROM review ORDER BY seq"):
        if r["target_id"] in exported_targets:
            reviews.setdefault(r["target_id"], []).append({
                "id": r["id"], "revision": r["revision"], "reviewer": pseudonyms[r["reviewer"]],
                "timestamp": r["timestamp"], "decision": r["decision"], "rationale": r["rationale"],
                "checks": {c: r[f"check_{c}"] for c in M.CHECKS},
                "approved_wording": r["approved_wording"], "scope_decision": r["scope_decision"],
            })
    con.row_factory = None
    out["reviews"] = reviews

    for kind, field in (("observations", "source_wording"), ("claims", "source_wording"),
                        ("assessments", "verdict_wording")):
        for rec in out[kind].values():
            hist = reviews[rec["id"]]
            # The latest correction in the history stands until a later review replaces it.
            approved = next((h["approved_wording"] for h in reversed(hist) if h["approved_wording"]), None)
            rec["display_wording"] = approved if approved else rec[field]
            rec["wording_corrected"] = bool(approved)
    for ob in out["observations"].values():
        thr = out["analyses"][ob["analysis_id"]]["fdr_threshold"]
        ob["fdr_below_threshold"] = None if (thr is None or ob["fdr"] is None) else ob["fdr"] < thr

    genes = {}
    for kind in ("observations", "claims", "annotations"):
        for rec in out[kind].values():
            g = genes.setdefault(rec["gene_key"], {"symbols": set(), "gene_id": rec["gene_id"] if rec["gene_key"] == rec["gene_id"] else None,
                                                    "gene_id_statuses": set(), "studies": set(),
                                                    "observations": [], "claims": [], "annotations": []})
            g["symbols"].add(rec["gene_symbol"])
            g["gene_id_statuses"].add(rec["gene_id_status"])
            g[kind].append(rec["id"])
            if kind == "claims":
                g["studies"].add(rec["study_id"])
            elif kind == "observations":
                g["studies"].add(out["analyses"][rec["analysis_id"]]["study_id"])
    for key, g in genes.items():
        dirs = {out["observations"][i]["direction"] for i in g["observations"]} - {None}
        g["direction_conflict"] = len(dirs) > 1
        g["assessments"] = sorted(a["id"] for a in out["assessments"].values() if a["study_id"] in g["studies"])
        g["symbols"] = sorted(g["symbols"])
        g["gene_id_statuses"] = sorted(g["gene_id_statuses"])
        del g["studies"]
        for k in ("observations", "claims", "annotations"):
            g[k].sort()
    out["genes"] = dict(sorted(genes.items()))
    return out


EXPORT_RECORD_KEYS = ("sources", "datasets", "studies", "analyses", "observations", "claims", "annotations",
                      "assessments")


def reviewer_pseudonyms(coll):
    """Real reviewer name -> 'Reviewer n', numbered by first appearance in the history."""
    out = {}
    for rv in coll.reviews:
        out.setdefault(rv["reviewer"], f"Reviewer {len(out) + 1}")
    return out


def verify_export(coll, exp, rendered_texts):
    """Independent check of the export boundary. Raises BuildError on any leak or omission."""
    allowed = eligibility.eligible_ids(coll)
    exported = set()
    for key in EXPORT_RECORD_KEYS:
        exported |= set(exp[key])
    problems = []
    if exported - allowed:
        problems.append(f"export contains ineligible records: {sorted(exported - allowed)}")
    if allowed - exported:
        problems.append(f"export omits eligible records: {sorted(allowed - exported)}")
    if set(exp["reviews"]) - exported:
        problems.append("export contains review history for unexported records")
    for rid, hist in exp["reviews"].items():
        if rid in exp["sources"] or rid in exp["datasets"] or rid in exp["analyses"]:
            continue
        if not hist or hist[-1]["decision"] != "approve":
            problems.append(f"{rid}: exported without a final approval")
    hidden_genes = eligibility.withheld_genes(coll)
    leaked = hidden_genes & set(exp["genes"])
    for g in exp["genes"].values():
        leaked |= hidden_genes & set(g["symbols"])
    for key in ("observations", "claims", "annotations"):
        leaked |= hidden_genes & {r["gene_symbol"] for r in exp[key].values()}
        leaked |= hidden_genes & {r["gene_id"] for r in exp[key].values()}
    if leaked:
        problems.append(f"withheld genes reachable: {sorted(leaked)}")
    real_names = set(reviewer_pseudonyms(coll)) - set(reviewer_pseudonyms(coll).values())
    if real_names & {r["reviewer"] for hist in exp["reviews"].values() for r in hist}:
        problems.append("export contains real reviewer names")
    blocked_ids = set(coll.index()) - allowed
    blocked_ids |= {rv["id"] for rv in coll.reviews if rv["target_id"] not in exported}
    pattern = re.compile("|".join(re.escape(i) for i in sorted(blocked_ids))) if blocked_ids else None
    for name, text in rendered_texts.items():
        if pattern and (m := pattern.search(text)):
            problems.append(f"{name}: contains withheld identifier {m.group(0)}")
    if problems:
        raise BuildError("export verification failed:\n  " + "\n  ".join(problems))


def _reset_dir(path, out_root):
    path = Path(path).resolve()
    if out_root.resolve() not in path.parents:
        raise BuildError(f"refusing to clear {path}")
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True)


def build(collection_dir, out_dir):
    out_dir = Path(out_dir)
    coll = M.load(collection_dir)
    probs = validate(coll)
    if errors(probs):
        raise BuildError("validation failed:\n  " + "\n  ".join(map(str, errors(probs))))
    out_dir.mkdir(parents=True, exist_ok=True)
    internal, public = out_dir / "internal", out_dir / "public"
    _reset_dir(internal, out_dir)
    _reset_dir(public, out_dir)

    db_path = internal / "atlas.sqlite"
    con = create_db(db_path)
    load_db(con, coll)
    if con.execute("PRAGMA foreign_key_check").fetchall():
        raise BuildError("foreign key check failed")
    content_hash = db_content_hash(con)
    exp = export(con, coll)
    con.close()

    export_text = M.canonical_json(exp) + "\n"
    html = site.render(exp)
    verify_export(coll, exp, {"atlas.json": export_text, "index.html": html})

    (public / "atlas.json").write_text(export_text, encoding="utf-8")
    (public / "index.html").write_text(html, encoding="utf-8")

    reasons = eligibility.record_reasons(coll)
    counts = summarize(reasons)
    manifest = {
        "schema_version": M.SCHEMA_VERSION,
        "tool_version": M.TOOL_VERSION,
        "collection_id": coll.data["collection"]["id"],
        "synthetic": coll.data["collection"]["synthetic"],
        "inputs": [{"path": p.name, "sha256": M.sha256_file(p)} for p in coll.input_files() if p.exists()],
        "schema_sha256": M.sha256_file(M.SCHEMA_SQL),
        "internal_db_content_sha256": content_hash,
        "outputs": [{"path": n, "sha256": M.sha256_file(public / n)} for n in ("atlas.json", "index.html")],
        "counts": counts,
    }
    (public / "MANIFEST.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    (internal / "withheld.tsv").write_text(_withheld_tsv(reasons), encoding="utf-8")
    return manifest, [p for p in probs if p.severity == "warning"]


def summarize(reasons):
    counts = {}
    for (t, _), rs in reasons.items():
        c = counts.setdefault(t, {"eligible": 0, "withheld": 0, "withheld_by_reason": {}})
        if rs:
            c["withheld"] += 1
            for r in rs:
                c["withheld_by_reason"][r] = c["withheld_by_reason"].get(r, 0) + 1
        else:
            c["eligible"] += 1
    return dict(sorted(counts.items()))


def _withheld_tsv(reasons):
    lines = ["type\tid\treasons"]
    for (t, rid), rs in sorted(reasons.items()):
        if rs:
            lines.append(f"{t}\t{rid}\t{','.join(rs)}")
    return "\n".join(lines) + "\n"
