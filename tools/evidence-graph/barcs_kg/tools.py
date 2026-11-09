"""Deterministic query tools over the evidence graph, for an agent harness.

    uv run python -m barcs_kg.tools get_gene_evidence gene=IL2RA
    uv run python -m barcs_kg.tools interpret_perturbation_effect contrast_id=GSE171674:CD25_high_vs_low gene=IL2RA

Every function returns a JSON-serializable dict. Each one keeps four things
apart: not tested, tested and not called, called by BARCS, and named by the
paper. STRING scores are confidences, never effects. Each function fills
`limitations` and abstains rather than guess.
"""

import csv
import json
import sqlite3
import sys
from pathlib import Path

from scipy.stats import hypergeom

DB = Path(__file__).resolve().parent.parent / "build" / "barcs_kg.sqlite"
REPORTS = Path(__file__).resolve().parent.parent / "reports"
HIT_FDR = 0.10
TAXON = {"human": 9606, "mouse": 10090, "rat": 10116, "cattle": 9913, "bovine": 9913}


def _con():
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    return con


def _taxon(organism):
    if organism is None:
        return None
    return TAXON.get(str(organism).lower(), int(organism) if str(organism).isdigit() else None)


def _priors():
    """Gene-level context flags written by analyses.py."""
    flags = {}
    path = REPORTS / "recurrence.tsv"
    if path.exists():
        with open(path) as fh:
            for r in csv.DictReader(fh, delimiter="\t"):
                flags[r["string_id"]] = {
                    "papers_hit": int(r["papers_hit"]), "papers_tested": int(r["papers_tested"]),
                    "papers_expected": float(r["papers_expected"]),
                    "frequent_hitter": float(r["q"]) < 0.05 and int(r["n_selection_classes"]) >= 3,
                    "fitness_prior": r["fitness_prior"] == "1"}
    return flags


def _contrast_row(con, contrast_id):
    return con.execute("""
        SELECT c.*, a.modality, a.selection_class, a.library_scope, a.readout,
               a.positive_estimate_means, a.curated_by, sa.taxon, sa.organism, s.pmid,
               p.title, p.doi, s.agreement
        FROM contrast c JOIN contrast_annotation a USING (contrast_id)
        JOIN series_annotation sa USING (gse) JOIN series s USING (gse)
        JOIN publication p ON p.pmid = s.pmid WHERE c.contrast_id = ?""", (contrast_id,)).fetchone()


def _qc(row):
    flags = []
    if row["residual_df"] == 0:
        flags.append("no residual df: no replicate-based variance, p-values rest on the dispersion prior")
    elif row["residual_df"] == 1:
        flags.append("one residual df")
    if not row["control_guides"]:
        flags.append("no control guides: calibration and the control null were impossible")
    if row["genes"] and row["n_fdr10"] is not None and row["n_fdr10"] / row["genes"] > 0.10:
        flags.append(f"calls {row['n_fdr10']}/{row['genes']} elements: hit list is not gene-specific")
    if row["top1pct_max"] and row["top1pct_max"] > 0.25:
        flags.append(f"composition skew: top 1% of guides hold {row['top1pct_max']:.0%} of reads")
    return flags


def _proteins(con, taxon, gene):
    return [r[0] for r in con.execute(
        "SELECT string_id FROM gene_protein WHERE taxon = ? AND upper(symbol) = upper(?) "
        "AND string_id IS NOT NULL", (taxon, gene))] or [r[0] for r in con.execute(
        "SELECT string_id FROM string_protein WHERE taxon = ? AND upper(preferred_name) = upper(?)",
        (taxon, gene))]


def search_contrasts(keyword, organism=None, limit=20):
    """Contrasts whose paper, model, contrast or name mention `keyword`."""
    con = _con()
    taxon = _taxon(organism)
    like = f"%{keyword}%"
    rows = con.execute("""
        SELECT c.contrast_id, sa.organism, a.modality, a.selection_class, c.orientation,
               c.residual_df, c.n_fdr10, c.genes, p.title
        FROM contrast c JOIN contrast_annotation a USING (contrast_id)
        JOIN series s USING (gse) JOIN series_annotation sa USING (gse)
        JOIN publication p ON p.pmid = s.pmid
        WHERE (p.title LIKE ? OR s.model_text LIKE ? OR s.contrast_text LIKE ? OR c.name LIKE ?)
          AND (? IS NULL OR sa.taxon = ?)
        LIMIT ?""", (like, like, like, like, taxon, taxon, int(limit))).fetchall()
    return {"query": keyword, "n": len(rows), "contrasts": [dict(r) for r in rows],
            "limitations": ["modality and selection class are rule-based, not curated"]}


def get_contrast_result(contrast_id, gene):
    """Exact BARCS result for one element, or an explicit 'not tested'."""
    con = _con()
    c = _contrast_row(con, contrast_id)
    if c is None:
        return {"error": f"unknown contrast {contrast_id}"}
    r = con.execute("""SELECT gene, n_guides, estimate, p_value, fdr, empirical_p, empirical_fdr, rank_p
                       FROM result WHERE contrast_id = ? AND upper(gene) = upper(?)""",
                    (contrast_id, gene)).fetchone()
    if r is None:
        for sid in _proteins(con, c["taxon"], gene):
            r = con.execute("""
                SELECT r.gene, r.n_guides, r.estimate, r.p_value, r.fdr, r.empirical_p,
                       r.empirical_fdr, r.rank_p
                FROM result r JOIN element_gene eg ON eg.gse = ? AND eg.element_id = r.gene
                JOIN gene_protein gp ON gp.taxon = ? AND gp.symbol = eg.symbol
                WHERE r.contrast_id = ? AND gp.string_id = ? ORDER BY r.p_value LIMIT 1""",
                (c["gse"], c["taxon"], contrast_id, sid)).fetchone()
            if r:
                break
    out = {"contrast_id": contrast_id, "gene": gene, "orientation": c["orientation"],
           "formula": c["formula"], "term": c["term"], "residual_df": c["residual_df"],
           "tested_elements": c["genes"], "qc_flags": _qc(c)}
    if r is None:
        out.update(status="not_tested",
                   limitations=["absent from this library or from the deposited counts; "
                                "this says nothing about the gene's effect"])
        return out
    out.update(dict(r))
    out["status"] = "called" if r["fdr"] is not None and r["fdr"] < HIT_FDR else "tested_not_called"
    out["limitations"] = (["not called at FDR 0.10; not evidence of no effect (power depends on "
                           f"residual df = {c['residual_df']}, guides = {r['n_guides']})"]
                          if out["status"] == "tested_not_called" else [])
    return out


def get_gene_evidence(gene, organism="human"):
    """All BARCS results for a gene, with paper claims kept separate."""
    con = _con()
    taxon = _taxon(organism)
    sids = _proteins(con, taxon, gene)
    rows = con.execute("""
        SELECT r.contrast_id, r.gene AS element, r.estimate, r.p_value, r.fdr, r.rank_p,
               c.orientation, c.residual_df, c.n_fdr10, c.genes, a.selection_class, a.modality
        FROM result r JOIN contrast c USING (contrast_id) JOIN contrast_annotation a USING (contrast_id)
        JOIN series_annotation sa ON sa.gse = c.gse
        JOIN element_gene eg ON eg.gse = c.gse AND eg.element_id = r.gene
                             AND eg.relation IN ('is', 'promoter_of')
        LEFT JOIN gene_protein gp ON gp.taxon = sa.taxon AND gp.symbol = eg.symbol
        WHERE sa.taxon = ? AND (upper(eg.symbol) = upper(?) OR gp.string_id IN (%s))
        ORDER BY r.p_value""" % ",".join("?" * len(sids)), (taxon, gene, *sids)).fetchall()
    claims = con.execute("""
        SELECT cl.contrast_id, cl.gene, cl.claimed_direction, s.paper_calls
        FROM claim cl JOIN series s USING (gse) JOIN series_annotation sa USING (gse)
        WHERE sa.taxon = ? AND upper(cl.gene) = upper(?)""", (taxon, gene)).fetchall()
    calls = [dict(r) for r in rows if r["fdr"] is not None and r["fdr"] < HIT_FDR]
    prior = next((_priors().get(s) for s in sids if s in _priors()), None)
    lim = ["paper claims carry no direction yet (compare.json lists names only)"]
    if prior and prior["frequent_hitter"]:
        lim.append(f"frequent hitter: called in {prior['papers_hit']} of {prior['papers_tested']} "
                   f"papers vs {prior['papers_expected']:.1f} expected; treat phenotype-specific "
                   "interpretations with caution")
    if prior and prior["fitness_prior"]:
        lim.append("fitness gene (CEGv2 or BARCS fitness screens): calls in non-fitness "
                   "contrasts may reflect differential proliferation")
    return {"gene": gene, "taxon": taxon, "string_ids": sids,
            "barcs_called": calls, "tested_not_called": len(rows) - len(calls),
            "paper_named": [dict(r) for r in claims], "prior": prior, "limitations": lim}


def get_string_neighbors(gene, organism="human", network="physical", min_score=700, limit=50):
    """STRING v12.5 neighbors with channel scores; flags text-mining-only links."""
    con = _con()
    taxon = _taxon(organism)
    sids = _proteins(con, taxon, gene)
    if not sids:
        return {"gene": gene, "error": "no unambiguous STRING mapping", "edges": []}
    sid = sids[0]
    if network == "regulatory":
        q = """SELECT protein_a, protein_b, combined_score, experimental, database, textmining,
                      positive, negative FROM string_regulatory
               WHERE (protein_a = ? OR protein_b = ?) AND combined_score >= ?
               ORDER BY combined_score DESC LIMIT ?"""
    else:
        table = "string_physical" if network == "physical" else "string_functional"
        q = f"""SELECT protein_a, protein_b, combined_score, experimental, database, textmining
                FROM {table} WHERE (protein_a = ? OR protein_b = ?) AND combined_score >= ?
                ORDER BY combined_score DESC LIMIT ?"""
    names = dict(con.execute("SELECT string_id, preferred_name FROM string_protein WHERE taxon = ?",
                             (taxon,)))
    edges = []
    for r in con.execute(q, (sid, sid, int(min_score), int(limit))):
        d = dict(r)
        d["source"], d["target"] = names.get(d.pop("protein_a")), names.get(d.pop("protein_b"))
        d["textmining_only"] = not (d["experimental"] or d["database"])
        edges.append(d)
    return {"gene": gene, "string_id": sid, "network": network, "string_version": "12.5",
            "min_score": min_score, "edges": edges,
            "limitations": ["scores are STRING confidences, not effects",
                            "physical includes predicted links; check experimental/database channels",
                            "regulatory edges are directed source -> target"]}


def compare_contrasts(contrast_a, contrast_b):
    """Hit overlap over the shared tested universe (STRING protein identity)."""
    con = _con()
    sets = {}
    for cid in (contrast_a, contrast_b):
        c = _contrast_row(con, cid)
        if c is None:
            return {"error": f"unknown contrast {cid}"}
        rows = con.execute("""
            SELECT gp.string_id, min(r.fdr) AS fdr, sp.preferred_name
            FROM result r JOIN element_gene eg ON eg.gse = ? AND eg.element_id = r.gene
                                             AND eg.relation IN ('is', 'promoter_of')
            JOIN gene_protein gp ON gp.taxon = ? AND gp.symbol = eg.symbol
            JOIN string_protein sp ON sp.string_id = gp.string_id
            WHERE r.contrast_id = ? GROUP BY gp.string_id""", (c["gse"], c["taxon"], cid)).fetchall()
        sets[cid] = (c, {r[0]: (r[1], r[2]) for r in rows})
    (ca, a), (cb, b) = sets[contrast_a], sets[contrast_b]
    if ca["taxon"] != cb["taxon"]:
        return {"error": "contrasts are from different organisms; no orthology join is loaded"}
    uni = set(a) & set(b)
    ha = {s for s in uni if a[s][0] is not None and a[s][0] < HIT_FDR}
    hb = {s for s in uni if b[s][0] is not None and b[s][0] < HIT_FDR}
    k = ha & hb
    p = hypergeom.sf(len(k) - 1, len(uni), len(ha), len(hb)) if k else 1.0
    return {"contrast_a": contrast_a, "contrast_b": contrast_b, "shared_universe": len(uni),
            "hits_a": len(ha), "hits_b": len(hb), "shared_hits": sorted(a[s][1] for s in k),
            "p_hypergeometric": p, "same_paper": ca["pmid"] == cb["pmid"],
            "qc_flags": {contrast_a: _qc(ca), contrast_b: _qc(cb)},
            "limitations": ["no adjustment for fitness or frequent hitters here; "
                            "see reports/convergence.tsv for the filtered version"]}


def trace_evidence_path(contrast_id, gene):
    """Publication -> series -> contrast -> result -> claim, plus STRING
    neighbors of the gene that are also called in the same contrast."""
    con = _con()
    c = _contrast_row(con, contrast_id)
    if c is None:
        return {"error": f"unknown contrast {contrast_id}"}
    res = get_contrast_result(contrast_id, gene)
    claim = con.execute("SELECT 1 FROM claim WHERE contrast_id = ? AND upper(gene) = upper(?)",
                        (contrast_id, gene)).fetchone()
    neighbors = []
    for e in get_string_neighbors(gene, c["taxon"], "physical", 700, 200).get("edges", []):
        other = e["target"] if e["source"].upper() == gene.upper() else e["source"]
        r = get_contrast_result(contrast_id, other)
        if r.get("status") == "called":
            neighbors.append({"gene": other, "string_score": e["combined_score"],
                              "experimental": e["experimental"], "database": e["database"],
                              "estimate": r["estimate"], "fdr": r["fdr"]})
    return {"publication": {"pmid": c["pmid"], "doi": c["doi"], "title": c["title"]},
            "series": c["gse"], "site_verdict": c["agreement"],
            "contrast": {"id": contrast_id, "orientation": c["orientation"],
                         "modality": c["modality"], "selection": c["selection_class"]},
            "result": res, "paper_named_this_gene": bool(claim),
            "called_string_neighbors": neighbors,
            "limitations": ["STRING neighbors are hypotheses for shared function, not evidence "
                            "that the screen measured an interaction"]}


def interpret_perturbation_effect(contrast_id, gene):
    """A conditional reading of one result, or an abstention naming what is missing."""
    con = _con()
    c = _contrast_row(con, contrast_id)
    if c is None:
        return {"error": f"unknown contrast {contrast_id}"}
    res = get_contrast_result(contrast_id, gene)
    missing = [f for f, v in (("modality", c["modality"]), ("orientation", c["orientation"]),
                              ("readout", c["readout"]),
                              ("positive_estimate_means", c["positive_estimate_means"])) if not v]
    if missing or res.get("status") != "called":
        return {"abstain": True, "missing_fields": missing, "result": res,
                "what_is_known": {"modality": c["modality"], "orientation": c["orientation"]},
                "reason": ("readout semantics are not curated for this contrast"
                           if missing else "the gene is not called in this contrast")}
    direction = "positive" if res["estimate"] > 0 else "negative"
    return {"abstain": False, "result": res,
            "statement": (f"Conditional on the curated readout ({c['readout']}), a {direction} "
                          f"estimate under {c['modality']} means: {c['positive_estimate_means']} "
                          f"{'holds' if direction == 'positive' else 'is reversed'} for {gene}."),
            "assumptions": [c["orientation"], f"modality {c['modality']} reduces/increases function as labelled",
                            f"curated by {c['curated_by']}"],
            "qc_flags": _qc(c)}


TOOLS = {f.__name__: f for f in (search_contrasts, get_contrast_result, get_gene_evidence,
                                 get_string_neighbors, compare_contrasts, trace_evidence_path,
                                 interpret_perturbation_effect)}

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in TOOLS:
        print("tools:", ", ".join(TOOLS))
        sys.exit(1)
    kwargs = dict(a.split("=", 1) for a in sys.argv[2:])
    print(json.dumps(TOOLS[sys.argv[1]](**kwargs), indent=2, default=str))
