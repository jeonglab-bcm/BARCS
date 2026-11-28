"""Record types, field specifications and loading of a collection directory.

A collection directory holds two files:
  collection.json  schema_version, collection metadata and the source records
  reviews.jsonl    the append-only, hash-chained review history (one review per line)
"""

import hashlib
import json
from pathlib import Path

SCHEMA_VERSION = 2
TOOL_VERSION = "0.1.0"
ROOT = Path(__file__).resolve().parent.parent
SCHEMA_SQL = ROOT / "schema" / "schema.sql"

# Record type -> (collection.json key, id prefix)
TYPES = {
    "source": ("sources", "src"),
    "dataset": ("datasets", "ds"),
    "study": ("studies", "st"),
    "analysis": ("analyses", "an"),
    "observation": ("observations", "ob"),
    "claim": ("claims", "cl"),
    "annotation": ("annotations", "at"),
    "assessment": ("assessments", "as"),
}
REVIEW_PREFIX = "rv"
REVIEWABLE = ("study", "observation", "claim", "annotation", "assessment")

PERMITTED_SCOPE = ("developmental_biology", "cell_biology")
EXCLUDED_SCOPE = (
    "pathogen", "host_susceptibility", "transmission", "virulence",
    "immune_evasion", "toxin", "security_sensitive",
)
SCOPE_CATEGORIES = PERMITTED_SCOPE + EXCLUDED_SCOPE + ("uncertain",)

CHECKS = ("source_identity", "wording", "measurement_interpretation",
          "statistical_representation", "scope")
CHECK_VALUES = ("confirmed", "corrected", "not_applicable", "uncertain", "missing")
INCOMPLETE_CHECK_VALUES = ("uncertain", "missing")
DECISIONS = ("approve", "needs_changes", "reject", "uncertain")
SCOPE_DECISIONS = ("in_scope", "out_of_scope", "uncertain")
GENESIS_HASH = "0" * 64
AGREEMENTS = ("agree", "partial", "differ")
# mapped: exact current symbol; synonym: unique match through a previous symbol or alias;
# ambiguous: several candidates; unmapped: no candidate. Only "mapped" carries no flag.
GENE_ID_STATUSES = ("mapped", "synonym", "ambiguous", "unmapped")
GENE_ID_RE = r"^(HGNC:\d+|MGI:\d+)$"

# field -> (python types, required). Optional fields may be null (= unknown) but must be present.
STR, NUM, INT = (str,), (int, float), (int,)
FIELDS = {
    "source": {
        "id": (STR, True), "kind": (STR, True), "identifier_scheme": (STR, True),
        "identifier": (STR, True), "citation": (STR, True), "url": (STR, True),
        "accessed": (STR, True),
    },
    "dataset": {
        "id": (STR, True), "accession": (STR, True), "version": (STR, False),
        "described_by": (STR, True),
    },
    "study": {
        "id": (STR, True), "dataset_id": (STR, True), "title": (STR, True),
        "scope_category": (STR, True), "archive_ref": (STR, True),
        "archive_sha256": (STR, True), "validation_status": (STR, True),
        "organism": (STR, True),
    },
    "analysis": {
        "id": (STR, True), "study_id": (STR, True), "label": (STR, True),
        "method": (STR, True), "method_version": (STR, True),
        "fdr_threshold": (NUM, False), "artifact_ref": (STR, True),
        "artifact_sha256": (STR, True),
    },
    "observation": {
        "id": (STR, True), "analysis_id": (STR, True), "gene_symbol": (STR, True), "gene_id": (STR, False), "gene_id_status": (STR, True),
        "source_wording": (STR, True), "estimate": (NUM, False),
        "estimate_meaning": (STR, False), "p_value": (NUM, False), "fdr": (NUM, False),
        "n_elements": (INT, False), "direction": (STR, False), "limitations": (STR, False),
    },
    "claim": {
        "id": (STR, True), "source_id": (STR, True), "study_id": (STR, True),
        "gene_symbol": (STR, True), "gene_id": (STR, False), "gene_id_status": (STR, True), "source_wording": (STR, True),
        "source_location": (STR, True),
    },
    "annotation": {
        "id": (STR, True), "gene_symbol": (STR, True), "gene_id": (STR, False), "gene_id_status": (STR, True), "vocabulary": (STR, True),
        "vocabulary_version": (STR, True), "term_id": (STR, True),
        "term_label": (STR, True), "attribution": (STR, True), "origin": (STR, True),
    },
    # The BARCS project's own comparison with the paper (meta.json agreement and verdict).
    # Not an author claim and not an observation.
    "assessment": {
        "id": (STR, True), "study_id": (STR, True), "agreement": (STR, False),
        "verdict_wording": (STR, True), "assessed_by": (STR, True),
        "archive_ref": (STR, True), "archive_sha256": (STR, True),
    },
}
REVIEW_FIELDS = {
    "id": (STR, True), "target_type": (STR, True), "target_id": (STR, True),
    "revision": (INT, True), "reviewer": (STR, True), "timestamp": (STR, True),
    "decision": (STR, True), "rationale": (STR, True), "checks": ((dict,), True),
    "approved_wording": (STR, False), "scope_decision": (STR, False),
    "prev_hash": (STR, True), "entry_hash": (STR, True),
}


def canonical_json(obj):
    """Byte-stable JSON used for hashing and for every written output."""
    return json.dumps(obj, sort_keys=True, ensure_ascii=False, separators=(",", ":"),
                      allow_nan=False)


def sha256_bytes(data):
    return hashlib.sha256(data).hexdigest()


def sha256_file(path):
    return sha256_bytes(Path(path).read_bytes())


def review_entry_hash(entry):
    body = {k: v for k, v in entry.items() if k not in ("entry_hash", "id")}
    return sha256_bytes(canonical_json(body).encode("utf-8"))


def gene_key(rec):
    """Grouping key for a gene: its stable id when mapped (directly or via synonym), else the symbol."""
    if rec.get("gene_id") and rec.get("gene_id_status") in ("mapped", "synonym"):
        return rec["gene_id"]
    return f"symbol:{rec['gene_symbol']}"


def opaque_id(prefix, seed):
    """Stable opaque identifier derived from a seed string."""
    return f"{prefix}_{sha256_bytes(seed.encode('utf-8'))[:12]}"


class Collection:
    def __init__(self, directory, data, reviews, raw_review_lines):
        self.directory = Path(directory)
        self.data = data
        self.reviews = reviews
        self.raw_review_lines = raw_review_lines

    def records(self, rtype):
        return self.data.get(TYPES[rtype][0], [])

    def index(self):
        """id -> (type, record) for every source record (reviews excluded)."""
        out = {}
        for rtype in TYPES:
            for rec in self.records(rtype):
                if isinstance(rec, dict) and isinstance(rec.get("id"), str):
                    out.setdefault(rec["id"], (rtype, rec))
        return out

    def input_files(self):
        return [self.directory / "collection.json", self.directory / "reviews.jsonl"]


class LoadError(Exception):
    pass


def load(directory):
    directory = Path(directory)
    cpath, rpath = directory / "collection.json", directory / "reviews.jsonl"
    if not cpath.is_file():
        raise LoadError(f"{cpath}: missing")
    try:
        data = json.loads(cpath.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        raise LoadError(f"{cpath}: invalid JSON ({e})") from e
    if not isinstance(data, dict):
        raise LoadError(f"{cpath}: top level must be an object")
    reviews, raw = [], []
    if rpath.is_file():
        for n, line in enumerate(rpath.read_text(encoding="utf-8").splitlines(), 1):
            if not line.strip():
                raise LoadError(f"{rpath}:{n}: blank line (history must be contiguous)")
            raw.append(line)
            try:
                reviews.append(json.loads(line))
            except json.JSONDecodeError as e:
                raise LoadError(f"{rpath}:{n}: invalid JSON ({e})") from e
    return Collection(directory, data, reviews, raw)
