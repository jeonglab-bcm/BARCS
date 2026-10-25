"""Export the slices of the graph the explorer page draws, and inline them.

    uv run python -m barcs_kg.export_viz build/barcs_kg.sqlite reports viz

Reads viz/explorer.template.html, replaces the DATA placeholder with JSON and
writes viz/explorer.html. Run after analyses.py: it reads the report TSVs.
"""

import csv
import json
import sqlite3
import sys

import numpy as np
from collections import Counter, defaultdict
from pathlib import Path

from barcs_kg.analyses import HIT_FDR, Graph, essential_reference

NET_TOP = 60


def tsv(path):
    with open(path) as fh:
        return list(csv.DictReader(fh, delimiter="\t"))


def r3(x):
    return None if x is None else float(f"{x:.3g}")


def run(db, reports, outdir):
    reports, outdir = Path(reports), Path(outdir)
    con = sqlite3.connect(db)
    g = Graph(con)
    summary = json.loads((reports / "summary.json").read_text())
    flags = {r["contrast_id"]: r["flags"] for r in tsv(reports / "contrast_flags.tsv")}
    meta = {r[0]: r[1:] for r in con.execute("""
        SELECT c.contrast_id, p.title, p.pmid, p.doi, c.orientation, sa.organism
        FROM contrast c JOIN series s USING (gse) JOIN publication p ON p.pmid = s.pmid
        JOIN series_annotation sa USING (gse)""")}
    claims = defaultdict(set)
    for r in tsv(reports / "claim_audit.tsv"):
        claims[r["contrast_id"]].add(r["gene"].upper())

    area_tsv = Path(__file__).resolve().parent.parent / "curation" / "screen_areas.tsv"
    areas = {}
    if area_tsv.exists():
        rows = [l.rstrip("\n").split("\t") for l in area_tsv.read_text().splitlines()
                if l and not l.startswith("#")]
        areas = {r[0]: r[1] for r in rows[1:]}

    # Baseline: the median gene estimate of each contrast. Arrows on the page are the
    # sign of the estimate against 0, so a contrast whose genes are shifted as a whole
    # (median more than one MAD from 0) is flagged and its baseline shown.
    est = defaultdict(list)
    for cid, e in con.execute("SELECT contrast_id, estimate FROM result WHERE estimate IS NOT NULL"):
        est[cid].append(e)
    baseline = {}
    for cid, v in est.items():
        v = np.asarray(v); med = float(np.median(v)); mad = 1.4826 * float(np.median(np.abs(v - med)))
        baseline[cid] = (round(med, 2), int(abs(med) > mad))

    # What a positive estimate compares: guides more abundant in level `pos` than in the
    # reference (baseline) level `ref`. An interaction term has no single reference.
    levels = {}
    for cid, t, r, term in con.execute("SELECT contrast_id, treatment_level, reference_level, term FROM contrast"):
        levels[cid] = (t, r) if r is not None else (term.replace(":", " × "), "interaction")

    # Curated meaning of each sign for the perturbed gene (curation/contrast_readout.tsv).
    meaning = {r[0]: r[1:] for r in con.execute("""SELECT contrast_id, readout, positive_estimate_means,
        negative_estimate_means, interest FROM contrast_annotation WHERE positive_estimate_means IS NOT NULL""")}

    order = sorted(g.contrast)
    index = {cid: i for i, cid in enumerate(order)}
    contrasts = []
    for cid in order:
        c = g.contrast[cid]
        title, pmid, doi, orient, organism = meta[cid]
        entry = {
            "id": cid, "title": title, "pmid": pmid, "doi": doi, "orientation": orient,
            "organism": organism, "taxon": c["taxon"], "modality": c["modality"],
            "selection": c["selection"], "df": c["df"], "controls": c["controls"],
            "tested": c["genes"], "hits": c["n_hits"], "eligible": c["eligible"],
            "primary": c["primary"], "flags": [f for f in flags.get(cid, "").split(",") if f],
            "named": len(claims[cid])}
        if cid.split(":")[0] in areas:
            entry["area"] = areas[cid.split(":")[0]]
        if cid in levels:
            entry["pos"], entry["ref"] = levels[cid]
        if cid in meaning:
            entry["readout"], entry["up_means"], entry["down_means"], entry["interest"] = meaning[cid]
        if cid in baseline:
            entry["base"], entry["base_off"] = baseline[cid]
        contrasts.append(entry)

    claim_df = defaultdict(Counter)
    for r in tsv(reports / "claim_audit.tsv"):
        if r["status"] == "not_tested":
            continue
        df = int(r["residual_df"]) if r["residual_df"] else None
        claim_df["0" if df == 0 else "1" if df == 1 else "2+"][r["status"]] += 1

    rec_rows = tsv(reports / "recurrence.tsv")
    recurrence = [[r["gene"], int(r["taxon"]), int(r["papers_tested"]), int(r["papers_hit"]),
                   float(r["papers_expected"]), r3(float(r["q"])), r["selection_classes"],
                   int(r["fitness_prior"])] for r in rec_rows]
    # recurrence.tsv lists only genes hit somewhere, so the fitness prior comes from its source
    ess = essential_reference(g, Path(db).parent / "reference" / "CEGv2.txt")[0]
    fitness = ess.get(9606, set()) | ess.get(10090, set())
    frequent = {r["string_id"] for r in rec_rows
                if float(r["q"]) < 0.05 and int(r["n_selection_classes"]) >= 3}
    # analyses.py borrows human frequent hitters for mouse by name; do the same here
    human_freq = {g.name[s].upper() for s in frequent if s.startswith("9606.")}
    frequent |= {s for s, n in g.name.items() if s.startswith("10090.") and n.upper() in human_freq}
    ess_names = {g.name[s].upper() for s in fitness if s.startswith("9606.")}

    leads = defaultdict(dict)
    for r in tsv(reports / "priority_unreported.tsv"):
        leads[r["contrast_id"]][r["gene"].upper()] = r

    sym2prot = defaultdict(set)
    for t, s, sid in con.execute(
            "SELECT taxon, symbol, string_id FROM gene_protein WHERE string_id IS NOT NULL"):
        sym2prot[(t, s.upper())].add(sid)

    nets = {}
    for cid in order:
        c = g.contrast[cid]
        if not c["primary"] or c["taxon"] not in (9606, 10090) or not g.res.get(cid):
            continue
        hits = sorted(g.hits(cid).items(), key=lambda kv: kv[1][1])
        if len(hits) < 5:
            continue
        named_prot = set()
        for gname in claims[cid]:
            named_prot |= {s for s in sym2prot.get((c["taxon"], gname), ()) if s in g.res[cid]}
        lead_prot = {s for s, _ in hits if g.name.get(s, "").upper() in leads[cid]}
        keep = [s for s, _ in hits[:NET_TOP]]
        keep += [s for s in sorted(named_prot | lead_prot) if s not in keep]
        pos = {s: i for i, s in enumerate(keep)}
        nodes = []
        for s in keep:
            est, p, fdr, elem = g.res[cid][s]
            called = fdr is not None and fdr < HIT_FDR
            role = ("named" if s in named_prot and called else "named_nc" if s in named_prot
                    else "lead" if s in lead_prot else "hit")
            ctx = (1 if (s in fitness or g.name.get(s, "").upper() in ess_names) else 0) | \
                  (2 if s in frequent else 0)
            nodes.append([g.name.get(s, elem), r3(est), r3(fdr), role, ctx])
        edges = []
        for s in keep:
            for t, (score, exp, dbs) in g.adj_phys.get(s, {}).items():
                if t in pos and pos[t] > pos[s]:
                    edges.append([pos[s], pos[t], score, int(bool(exp or dbs))])
        lead_rows = [[r["gene"], int(r["rank_among_strict_hits"]), r3(float(r["fdr"])),
                      r["physical_links_to_named(score,exp,db)"],
                      r["functional900_links_to_named"]]
                     for r in leads[cid].values()]
        nets[str(index[cid])] = {"n": nodes, "e": edges, "leads": lead_rows}

    genes = defaultdict(lambda: {"c": [], "t": 0})
    for cid in order:
        c = g.contrast[cid]
        if not c["primary"]:
            continue
        for s, (est, p, fdr, elem) in g.res[cid].items():
            key = f"{g.name.get(s, elem)}|{c['taxon']}"
            genes[key]["t"] += 1
            if fdr is not None and fdr < HIT_FDR:
                genes[key]["c"].append([index[cid], r3(est), r3(fdr)])
    genes = {k: v for k, v in genes.items() if v["c"]}

    data = {
        "meta": {"commit": con.execute("SELECT value FROM source WHERE key = 'barcs_commit'").fetchone()[0][:7],
                 "string": "12.5", "summary": {k: summary[k] for k in ("inventory", "hit_load", "unreported")}},
        "contrasts": contrasts, "claims_by_df": claim_df, "recurrence": recurrence,
        "nets": nets, "genes": genes,
        "fitness": sorted({f"{g.name[s]}|{s.split('.')[0]}" for s in fitness}
                          | {f"{n}|10090" for s, n in g.name.items()
                             if s.startswith("10090.") and n.upper() in ess_names}),
        "frequent": sorted(f"{g.name[s]}|{s.split('.')[0]}" for s in frequent)}
    blob = json.dumps(data, separators=(",", ":")).replace("</", "<\\/")
    path_path = outdir / "pathways.json"
    pathways = path_path.read_text().replace("</", "<\\/") if path_path.exists() else "null"
    # One pathway map per area, rebuilt on that area's screens alone (build_areas.sh),
    # shown when the page is filtered to the area.
    by_area = {f.stem.removeprefix("pathways_"): json.loads(f.read_text())
               for f in sorted(outdir.glob("pathways_*.json"))}
    pathways_area = json.dumps(by_area, separators=(",", ":")).replace("</", "<\\/")
    template = (outdir / "explorer.template.html").read_text()
    (outdir / "explorer.html").write_text(
        template.replace("/*__DATA__*/null", blob).replace("/*__PATH__*/null", pathways)
        .replace("/*__PATH_AREA__*/null", pathways_area))
    return {"bytes": len(blob) + len(pathways), "contrasts": len(contrasts), "nets": len(nets),
            "genes": len(genes), "pathways": pathways != "null"}


if __name__ == "__main__":
    print(run(sys.argv[1], sys.argv[2], sys.argv[3]))
