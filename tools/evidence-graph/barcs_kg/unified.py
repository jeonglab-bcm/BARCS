"""One graph across conditions: genes, the contrasts that call them, and STRING.

    uv run python -m barcs_kg.unified build   build/barcs_kg.sqlite reports build/unified_graph.json
    node viz/layout.mjs build/unified_graph.json build/unified_layout.json
    uv run python -m barcs_kg.unified graphml build/unified_graph.json build/unified_layout.json build/unified_graph.graphml

Nodes are genes and conditions (eligible primary contrasts). Mouse, rat and
cattle calls fold onto the human gene with the same upper-cased STRING name, a
symbol-level orthology that the node records in `species`. Edges:

  call       condition -> gene, BARCS FDR < 0.10, with the signed estimate
  physical   STRING v12.5 physical, score >= 700 (human network)
  regulates  STRING v12.5 regulatory, score >= 700, directed, sign from the
             positive/negative channels when one of them is set

Frequent hitters and fitness genes are kept but flagged; the layout leaves
them out and places them among their neighbours afterwards.
"""

import csv
import json
import sqlite3
import sys
from collections import defaultdict
from xml.sax.saxutils import escape

from barcs_kg.analyses import Graph

SPECIES = {9606: "human", 10090: "mouse", 10116: "rat", 9913: "cattle"}
STRING_MIN = 700


def build(db, reports, out):
    con = sqlite3.connect(db)
    g = Graph(con)
    human = {n.upper(): s for s, n in g.name.items() if s.startswith("9606.")}
    rec = list(csv.DictReader(open(f"{reports}/recurrence.tsv"), delimiter="\t"))
    frequent = {r["gene"].upper() for r in rec if r["taxon"] == "9606"
                and float(r["q"]) < 0.05 and int(r["n_selection_classes"]) >= 3}
    fitness = {r["gene"].upper() for r in rec if r["fitness_prior"] == "1"}
    fitness |= {g.name[s].upper() for s in human.values()
                if s in _fitness_ids(con)}

    order = sorted(g.contrast)
    conditions = [c for c in order if g.contrast[c]["eligible"]
                  and g.contrast[c]["taxon"] in SPECIES]
    nodes, index = [], {}
    for cid in conditions:
        c = g.contrast[cid]
        index[cid] = len(nodes)
        nodes.append({"kind": "condition", "id": cid, "contrast": order.index(cid),
                      "selection": c["selection"], "species": SPECIES[c["taxon"]],
                      "pmid": c["pmid"]})
    best = {}  # (condition, human protein) -> (est, fdr)
    dropped = 0
    for cid in conditions:
        for s, (est, p, fdr, _) in g.hits(cid).items():
            hs = human.get(g.name[s].upper())
            if hs is None:
                dropped += 1
                continue
            if (cid, hs) not in best or fdr < best[(cid, hs)][1]:
                best[(cid, hs)] = (est, fdr)
    papers, species = defaultdict(set), defaultdict(set)
    for (cid, hs) in best:
        papers[hs].add(g.contrast[cid]["pmid"])
        species[hs].add(SPECIES[g.contrast[cid]["taxon"]])
    for hs in sorted(papers, key=lambda s: g.name[s]):
        name = g.name[hs]
        index[hs] = len(nodes)
        nodes.append({"kind": "gene", "id": name, "string_id": hs, "papers": len(papers[hs]),
                      "species": sorted(species[hs]),
                      "frequent": name.upper() in frequent, "fitness": name.upper() in fitness})
    edges = []
    for (cid, hs), (est, fdr) in best.items():
        edges.append([index[cid], index[hs], "call", round(est, 3), float(f"{fdr:.3g}")])
    genes = {n["string_id"] for n in nodes if n["kind"] == "gene"}
    for a, b, score, exp, dbs in con.execute(
            "SELECT protein_a, protein_b, combined_score, experimental, database FROM string_physical "
            "WHERE combined_score >= ? AND protein_a LIKE '9606.%'", (STRING_MIN,)):
        if a in genes and b in genes:
            edges.append([index[a], index[b], "physical", score, int(bool(exp or dbs))])
    for a, b, score, pos, neg in con.execute(
            "SELECT protein_a, protein_b, combined_score, positive, negative FROM string_regulatory "
            "WHERE combined_score >= ? AND protein_a LIKE '9606.%'", (STRING_MIN,)):
        if a in genes and b in genes and a != b:
            sign = "pos" if pos > neg else "neg" if neg > pos else "unsigned"
            edges.append([index[a], index[b], "regulates", score, sign])
    graph = {"nodes": nodes, "edges": edges,
             "note": {"string_version": "12.5", "string_min": STRING_MIN,
                      "calls_without_human_symbol": dropped}}
    with open(out, "w") as fh:
        json.dump(graph, fh, separators=(",", ":"))
    kinds = defaultdict(int)
    for e in edges:
        kinds[e[2]] += 1
    return {"conditions": len(conditions), "genes": len(genes), "edges": dict(kinds),
            "calls_without_human_symbol": dropped}


def _fitness_ids(con):
    """CEGv2 is folded into recurrence.tsv only for recurrent genes; read the file again."""
    import pathlib
    path = pathlib.Path(con.execute("PRAGMA database_list").fetchone()[2]).parent / "reference" / "CEGv2.txt"
    if not path.exists():
        return set()
    names = {line.split("\t")[0].upper() for line in path.read_text().splitlines()[1:] if line}
    ids = {sid for sym, sid in con.execute(
        "SELECT upper(symbol), string_id FROM gene_protein WHERE taxon = 9606 AND string_id IS NOT NULL")
        if sym in names}
    return ids


def graphml(graph_path, layout_path, out):
    graph = json.load(open(graph_path))
    pos = json.load(open(layout_path))
    keys = [("kind", "node", "string"), ("label", "node", "string"), ("papers", "node", "int"),
            ("species", "node", "string"), ("frequent_hitter", "node", "boolean"),
            ("fitness_gene", "node", "boolean"), ("selection", "node", "string"),
            ("x", "node", "double"), ("y", "node", "double"),
            ("type", "edge", "string"), ("estimate", "edge", "double"), ("fdr", "edge", "double"),
            ("string_score", "edge", "int"), ("experimental_or_database", "edge", "boolean"),
            ("sign", "edge", "string")]
    with open(out, "w") as fh:
        fh.write('<?xml version="1.0" encoding="UTF-8"?>\n'
                 '<graphml xmlns="http://graphml.graphdrawing.org/xmlns">\n')
        for k, dom, typ in keys:
            fh.write(f'  <key id="{k}" for="{dom}" attr.name="{k}" attr.type="{typ}"/>\n')
        fh.write('  <graph edgedefault="undirected">\n')
        for i, n in enumerate(graph["nodes"]):
            attrs = {"kind": n["kind"], "label": n["id"], "x": pos[i][0], "y": pos[i][1]}
            if n["kind"] == "gene":
                attrs |= {"papers": n["papers"], "species": ",".join(n["species"]),
                          "frequent_hitter": str(n["frequent"]).lower(),
                          "fitness_gene": str(n["fitness"]).lower()}
            else:
                attrs |= {"selection": n["selection"] or "", "species": n["species"]}
            data = "".join(f'<data key="{k}">{escape(str(v))}</data>' for k, v in attrs.items())
            fh.write(f'    <node id="n{i}">{data}</node>\n')
        for j, e in enumerate(graph["edges"]):
            s, t, typ = e[:3]
            attrs = {"type": typ}
            if typ == "call":
                attrs |= {"estimate": e[3], "fdr": e[4]}
            elif typ == "physical":
                attrs |= {"string_score": e[3], "experimental_or_database": str(bool(e[4])).lower()}
            else:
                attrs |= {"string_score": e[3], "sign": e[4]}
            data = "".join(f'<data key="{k}">{escape(str(v))}</data>' for k, v in attrs.items())
            directed = ' directed="true"' if typ == "regulates" else ""
            fh.write(f'    <edge id="e{j}" source="n{s}" target="n{t}"{directed}>{data}</edge>\n')
        fh.write("  </graph>\n</graphml>\n")


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "build":
        print(build(*sys.argv[2:5]))
    elif cmd == "graphml":
        graphml(*sys.argv[2:5])
