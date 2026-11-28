"""Eligibility rules in Python, written independently of the SQL views in schema.sql.

The export selects records with the SQL views; verify_export() then recomputes
eligibility here and refuses any export that differs. Two implementations of the
same rule guard the export boundary against a bug in either.
"""

from collections import defaultdict

from . import model as M


def _full_approval(rv):
    if rv["decision"] != "approve":
        return False
    if any(rv["checks"].get(c) in M.INCOMPLETE_CHECK_VALUES or c not in rv["checks"] for c in M.CHECKS):
        return False
    if rv["target_type"] == "study":
        return rv["scope_decision"] == "in_scope" and rv["checks"]["scope"] == "confirmed"
    return True


def review_state(coll):
    """(type, id) -> list of reviews in history order."""
    hist = defaultdict(list)
    for rv in coll.reviews:
        hist[(rv["target_type"], rv["target_id"])].append(rv)
    return hist


def record_reasons(coll):
    """(type, id) -> list of reasons it is withheld; empty list = eligible.

    Covers every reviewable record. Reasons are machine-readable codes.
    """
    hist = review_state(coll)
    idx = coll.index()
    reasons = {}

    def own_reasons(rtype, rid):
        revs = hist.get((rtype, rid), [])
        if not revs:
            return ["unreviewed"]
        latest_by_reviewer = {}
        for rv in revs:
            latest_by_reviewer[rv["reviewer"]] = rv
        r = []
        decisions = {rv["decision"] for rv in latest_by_reviewer.values()}
        if len(latest_by_reviewer) > 1 and len({_full_approval(v) for v in latest_by_reviewer.values()}) > 1:
            r.append("reviewer_disagreement")
        for rv in latest_by_reviewer.values():
            if rv["decision"] == "approve" and not _full_approval(rv):
                if rtype == "study" and rv["scope_decision"] != "in_scope":
                    r.append(f"scope_{rv['scope_decision'] or 'missing'}")
                else:
                    r.append("incomplete_checks")
        for d in sorted(decisions - {"approve"}):
            r.append(f"decision_{d}")
        return sorted(set(r))

    for rid, (rtype, rec) in idx.items():
        if rtype == "study":
            r = own_reasons(rtype, rid)
            if rec["scope_category"] not in M.PERMITTED_SCOPE:
                r.append(f"scope_category_{rec['scope_category']}")
            reasons[(rtype, rid)] = sorted(set(r))
    for rid, (rtype, rec) in idx.items():
        if rtype == "observation":
            r = own_reasons(rtype, rid)
            an = idx.get(rec["analysis_id"])
            st_id = an[1]["study_id"] if an else None
            if reasons.get(("study", st_id), ["missing_study"]):
                r.append("study_withheld")
            reasons[(rtype, rid)] = sorted(set(r))
        elif rtype == "claim":
            r = own_reasons(rtype, rid)
            if reasons.get(("study", rec["study_id"]), ["missing_study"]):
                r.append("study_withheld")
            reasons[(rtype, rid)] = sorted(set(r))
    shown = [idx[rid] for (t, rid), rs in reasons.items() if t in ("observation", "claim") and not rs]
    genes = {M.gene_key(rec) for _, rec in shown}
    shown_studies = {rec["study_id"] if t == "claim" else idx[rec["analysis_id"]][1]["study_id"]
                     for t, rec in shown}
    for rid, (rtype, rec) in idx.items():
        if rtype == "annotation":
            r = own_reasons(rtype, rid)
            if M.gene_key(rec) not in genes:
                r.append("gene_not_in_collection")
            reasons[(rtype, rid)] = sorted(set(r))
        elif rtype == "assessment":
            r = own_reasons(rtype, rid)
            if reasons.get(("study", rec["study_id"]), ["missing_study"]):
                r.append("study_withheld")
            elif rec["study_id"] not in shown_studies:
                r.append("study_not_displayed")
            reasons[(rtype, rid)] = sorted(set(r))
    return reasons


def eligible_ids(coll):
    """Every record id allowed in a public export, including provenance carriers."""
    reasons = record_reasons(coll)
    idx = coll.index()
    ok = {rid for (t, rid), rs in reasons.items() if not rs}
    for rid in list(ok):
        rtype, rec = idx[rid]
        if rtype == "observation":
            an = idx[rec["analysis_id"]][1]
            ok.add(an["id"])
        if rtype == "study":
            ds = idx[rec["dataset_id"]][1]
            ok.update({ds["id"], ds["described_by"]})
        if rtype == "claim":
            ok.add(rec["source_id"])
    return ok


def withheld_genes(coll):
    """Gene symbols and gene ids that appear only in withheld records."""
    reasons = record_reasons(coll)
    idx = coll.index()
    shown, everything = set(), set()
    for (t, rid), rs in reasons.items():
        rec = idx[rid][1]
        if "gene_symbol" not in rec:
            continue
        names = {rec["gene_symbol"]} | ({rec["gene_id"]} if rec["gene_id"] else set())
        everything |= names
        if not rs and t in ("observation", "claim", "annotation"):
            shown |= names
    return everything - shown
