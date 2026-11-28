"""Validation of a collection before it is built. Any error stops the build."""

import re
from dataclasses import dataclass

from . import model as M

ID_RE = re.compile(r"^(src|ds|st|an|ob|cl|at|as|rv)_[0-9a-f]{12}$")
GENE_ID_RE = re.compile(M.GENE_ID_RE)
SHA_RE = re.compile(r"^[0-9a-f]{64}$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
TS_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
GENE_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$")
IDENTIFIER_RE = {
    "doi": re.compile(r"^10\.\d{4,9}/\S+$"),
    "pmid": re.compile(r"^[1-9]\d{0,8}$"),
    "url": re.compile(r"^https://\S+$"),
    "fixture": re.compile(r"^fixture:[a-z0-9-]+$"),
}
ENUMS = {
    ("source", "kind"): ("publication", "archive"),
    ("source", "identifier_scheme"): tuple(IDENTIFIER_RE),
    ("study", "scope_category"): M.SCOPE_CATEGORIES,
    ("study", "validation_status"): ("not_validated", "validated", "validation_failed"),
    ("observation", "direction"): ("enriched", "depleted"),
    ("annotation", "origin"): ("curated", "model_generated"),
    ("assessment", "agreement"): M.AGREEMENTS,
    ("observation", "gene_id_status"): M.GENE_ID_STATUSES,
    ("claim", "gene_id_status"): M.GENE_ID_STATUSES,
    ("annotation", "gene_id_status"): M.GENE_ID_STATUSES,
}
FOREIGN_KEYS = {
    ("dataset", "described_by"): "source",
    ("study", "dataset_id"): "dataset",
    ("analysis", "study_id"): "study",
    ("observation", "analysis_id"): "analysis",
    ("claim", "source_id"): "source",
    ("claim", "study_id"): "study",
    ("assessment", "study_id"): "study",
}
# Words that suggest a study may fall outside the permitted scope. A hit is a
# warning for the reviewer, not a decision: scope is decided by review only.
SCOPE_TRIPWIRE = re.compile(
    r"\b(\w*(pathogen|virus|viral|virulen|infect|toxin|bacteri|parasit|prion|phage)\w*|"
    r"host[- ]factors?|transmissi\w*|immune[- ]evasion)\b", re.I)


@dataclass(frozen=True)
class Problem:
    severity: str  # "error" | "warning"
    code: str
    where: str
    message: str

    def __str__(self):
        return f"{self.severity}: {self.code}: {self.where}: {self.message}"


def _check_fields(rtype, rec, spec, where, out):
    if not isinstance(rec, dict):
        out.append(Problem("error", "not_an_object", where, "record must be a JSON object"))
        return False
    for key in rec:
        if key not in spec:
            out.append(Problem("error", "unknown_field", where, f"unknown field '{key}'"))
    ok = True
    for key, (types, required) in spec.items():
        if key not in rec:
            out.append(Problem("error", "missing_field", where,
                               f"field '{key}' is missing (use null for unknown)"))
            ok = False
            continue
        val = rec[key]
        if val is None:
            if required:
                out.append(Problem("error", "required_null", where, f"'{key}' is required"))
                ok = False
            continue
        if isinstance(val, bool) or not isinstance(val, types):
            out.append(Problem("error", "bad_type", where, f"'{key}' has the wrong type"))
            ok = False
        elif isinstance(val, str) and required and not val.strip():
            out.append(Problem("error", "empty_value", where, f"'{key}' is empty"))
            ok = False
    return ok


def validate(coll):
    out = []
    data = coll.data
    if data.get("schema_version") != M.SCHEMA_VERSION:
        out.append(Problem("error", "schema_version", "collection.json",
                           f"schema_version must be {M.SCHEMA_VERSION}, got {data.get('schema_version')!r}"))
    allowed_top = {"schema_version", "collection"} | {k for k, _ in M.TYPES.values()}
    for key in data:
        if key not in allowed_top:
            out.append(Problem("error", "unknown_field", "collection.json", f"unknown key '{key}'"))
    meta = data.get("collection")
    if not (isinstance(meta, dict) and isinstance(meta.get("id"), str)
            and isinstance(meta.get("title"), str) and isinstance(meta.get("synthetic"), bool)):
        out.append(Problem("error", "collection_meta", "collection.json",
                           "'collection' needs string id, string title and boolean synthetic"))

    seen = {}
    good = {}  # id -> (type, rec) for records whose fields are well-formed
    for rtype, (key, prefix) in M.TYPES.items():
        recs = data.get(key, [])
        if not isinstance(recs, list):
            out.append(Problem("error", "not_a_list", f"collection.json:{key}", "must be a list"))
            continue
        for i, rec in enumerate(recs):
            where = f"{key}[{i}]"
            if not _check_fields(rtype, rec, M.FIELDS[rtype], where, out):
                continue
            rid = rec["id"]
            where = f"{rtype} {rid}"
            if not ID_RE.match(rid) or not rid.startswith(prefix + "_"):
                out.append(Problem("error", "bad_id", where, f"id must match {prefix}_<12 hex>"))
            if rid in seen:
                out.append(Problem("error", "duplicate_id", where, f"id also used by {seen[rid]}"))
                continue
            seen[rid] = rtype
            good[rid] = (rtype, rec)
            for (et, field), allowed in ENUMS.items():
                if et == rtype and rec[field] is not None and rec[field] not in allowed:
                    out.append(Problem("error", "bad_enum", where, f"'{field}'={rec[field]!r} not in {allowed}"))
            for field in ("archive_sha256", "artifact_sha256"):
                if field in rec and not SHA_RE.match(rec[field]):
                    out.append(Problem("error", "bad_hash", where, f"'{field}' must be 64 hex"))
            if "gene_symbol" in rec:
                if not GENE_RE.match(rec["gene_symbol"]):
                    out.append(Problem("error", "bad_gene_symbol", where, rec["gene_symbol"]))
                gid, status = rec["gene_id"], rec["gene_id_status"]
                if gid is not None and not GENE_ID_RE.match(gid):
                    out.append(Problem("error", "bad_gene_id", where, f"gene_id {gid!r} must be HGNC:<n> or MGI:<n>"))
                if status in ("mapped", "synonym") and gid is None:
                    out.append(Problem("error", "gene_id_status", where, f"status {status} needs a gene_id"))
                if status in ("ambiguous", "unmapped") and gid is not None:
                    out.append(Problem("error", "gene_id_status", where, f"status {status} must have gene_id null"))
                if status in ("synonym", "ambiguous", "unmapped"):
                    out.append(Problem("warning", f"gene_{status}", where,
                                       f"gene identity for {rec['gene_symbol']} is {status}; reviewer must confirm source_identity"))
            for field in ("p_value", "fdr"):
                v = rec.get(field)
                if v is not None and not (0 <= v <= 1):
                    out.append(Problem("error", "out_of_range", where, f"'{field}' must be in [0, 1]"))
            if rtype == "observation" and rec["n_elements"] is not None and rec["n_elements"] < 1:
                out.append(Problem("error", "out_of_range", where, "'n_elements' must be >= 1"))
            if rtype == "analysis" and rec["fdr_threshold"] is not None and not (0 < rec["fdr_threshold"] < 1):
                out.append(Problem("error", "out_of_range", where, "'fdr_threshold' must be in (0, 1)"))
            if rtype == "source":
                pat = IDENTIFIER_RE.get(rec["identifier_scheme"])
                if pat and not pat.match(rec["identifier"]):
                    out.append(Problem("error", "bad_identifier", where,
                                       f"{rec['identifier_scheme']} identifier {rec['identifier']!r} is malformed"))
                if not rec["url"].startswith("https://"):
                    out.append(Problem("error", "bad_url", where, "url must be https://"))
                if not DATE_RE.match(rec["accessed"]):
                    out.append(Problem("error", "bad_date", where, "accessed must be YYYY-MM-DD"))
            if rtype == "study" and SCOPE_TRIPWIRE.search(rec["title"]):
                out.append(Problem("warning", "scope_tripwire", where,
                                   "title contains a term associated with excluded scope; reviewer must confirm scope"))

    # Referential integrity
    for rid, (rtype, rec) in good.items():
        for (et, field), target in FOREIGN_KEYS.items():
            if et != rtype:
                continue
            ref = rec[field]
            if ref not in good or good[ref][0] != target:
                out.append(Problem("error", "unresolved_reference", f"{rtype} {rid}",
                                   f"'{field}' -> {ref!r} does not resolve to a {target}"))
    # Uniqueness constraints mirrored from the schema
    _unique(good, "source", ("identifier_scheme", "identifier"), out)
    _unique(good, "dataset", ("accession", "version"), out)
    _unique(good, "annotation", ("gene_symbol", "vocabulary", "vocabulary_version", "term_id"), out)

    _validate_reviews(coll, good, seen, out)
    _validate_head(coll, out)
    return out


def _validate_head(coll, out):
    """The chain alone cannot see lines removed from the end; the recorded head can."""
    if coll.head is None:
        if coll.reviews:
            out.append(Problem("error", "missing_head", M.HEAD_FILE,
                               "review log has entries but no recorded head"))
        return
    if coll.head != M.review_head(coll.reviews):
        out.append(Problem("error", "head_mismatch", M.HEAD_FILE,
                           f"reviews.jsonl does not end at the recorded head {coll.head} "
                           "(entries removed from the end, added by hand, or the log rewritten)"))


def _unique(good, rtype, fields, out):
    seen = {}
    for rid, (t, rec) in sorted(good.items()):
        if t != rtype:
            continue
        key = tuple(rec[f] for f in fields)
        if key in seen:
            out.append(Problem("error", "duplicate_record", f"{rtype} {rid}",
                               f"same {'/'.join(fields)} as {seen[key]}"))
        else:
            seen[key] = rid


def _validate_reviews(coll, good, seen_ids, out):
    prev = M.GENESIS_HASH
    revisions = {}
    last_ts = {}
    for n, rv in enumerate(coll.reviews, 1):
        where = f"reviews.jsonl:{n}"
        if not _check_fields("review", rv, M.REVIEW_FIELDS, where, out):
            prev = rv.get("entry_hash", prev) if isinstance(rv, dict) else prev
            continue
        if rv["prev_hash"] != prev:
            out.append(Problem("error", "broken_chain", where,
                               "prev_hash does not match the previous entry (history edited or reordered)"))
        expected = M.review_entry_hash(rv)
        if rv["entry_hash"] != expected:
            out.append(Problem("error", "bad_entry_hash", where, "entry_hash does not match the entry's content"))
        if rv["id"] != f"{M.REVIEW_PREFIX}_{rv['entry_hash'][:12]}":
            out.append(Problem("error", "bad_id", where, "review id must be rv_ + first 12 hex of entry_hash"))
        if rv["id"] in seen_ids:
            out.append(Problem("error", "duplicate_id", where, rv["id"]))
        seen_ids[rv["id"]] = "review"
        prev = rv["entry_hash"]

        tt, tid = rv["target_type"], rv["target_id"]
        if tt not in M.REVIEWABLE:
            out.append(Problem("error", "bad_enum", where, f"target_type {tt!r} is not reviewable"))
        elif tid not in good or good[tid][0] != tt:
            out.append(Problem("error", "unresolved_reference", where, f"target {tt} {tid} does not exist"))
        key = (tt, tid)
        want = revisions.get(key, 0) + 1
        if rv["revision"] != want:
            out.append(Problem("error", "revision_gap", where,
                               f"revision {rv['revision']} for {tid}; expected {want}"))
        revisions[key] = max(revisions.get(key, 0), rv["revision"])
        if not TS_RE.match(rv["timestamp"]):
            out.append(Problem("error", "bad_timestamp", where, "timestamp must be YYYY-MM-DDTHH:MM:SSZ"))
        elif key in last_ts and rv["timestamp"] < last_ts[key]:
            out.append(Problem("error", "timestamp_order", where, "timestamp earlier than the previous review"))
        last_ts[key] = max(last_ts.get(key, ""), rv["timestamp"])
        if rv["decision"] not in M.DECISIONS:
            out.append(Problem("error", "bad_enum", where, f"decision {rv['decision']!r}"))
        checks = rv["checks"]
        if set(checks) != set(M.CHECKS):
            out.append(Problem("error", "bad_checks", where, f"checks must have exactly {M.CHECKS}"))
        for c, v in checks.items():
            if v not in M.CHECK_VALUES:
                out.append(Problem("error", "bad_enum", where, f"check {c}={v!r}"))
        if tt == "study":
            if rv["scope_decision"] not in M.SCOPE_DECISIONS:
                out.append(Problem("error", "missing_scope_decision", where, "study reviews need a scope_decision"))
        elif rv["scope_decision"] is not None:
            out.append(Problem("error", "unexpected_scope_decision", where, "scope_decision applies to studies only"))
        wording_corrected = checks.get("wording") == "corrected"
        if wording_corrected and not (rv["approved_wording"] or "").strip():
            out.append(Problem("error", "missing_approved_wording", where,
                               "wording marked corrected but no approved_wording given"))
        if rv["approved_wording"] is not None and not wording_corrected:
            out.append(Problem("error", "unexpected_approved_wording", where,
                               "approved_wording given but wording not marked corrected"))
        if not rv["rationale"].strip():
            out.append(Problem("error", "empty_value", where, "rationale is required"))


def errors(problems):
    return [p for p in problems if p.severity == "error"]
