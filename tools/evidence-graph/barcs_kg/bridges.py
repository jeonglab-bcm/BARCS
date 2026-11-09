"""a-b-c queries: what links two screen genes, and which genes a screen gene travels with.

    uv run python -m barcs_kg.bridges build/barcs_kg.sqlite        # once per build: screen tables
    uv run python -m barcs_kg.tools find_bridges gene_a=IFNGR1 gene_c=JAK1
    uv run python -m barcs_kg.tools find_c gene_a=QRICH1

Swanson's a-b-c: a and c are linked through some b. Here a and c are genes
that screens hit together, and the question is what b is:

  direct      STRING physical, functional or regulatory link (score >= 700)
              with support beyond text mining (some other channel >= 400);
  term        a GO / Reactome / WikiPathways / Hallmark term both carry, small
              (<= SPECIFIC_TERM proteins) and, for GO, independent of screens
              (ontology.py: not high-throughput, not IEA, not citing a corpus
              paper);
  gene        a protein b linked to both by such STRING links;
  text mining only   the only links are text-mining co-mentions;
  unexplained none of the above: a candidate for a new hypothesis.

The screen layer reuses the pathway map's choices (pathways.py): eligible
primary contrasts of human and mouse, without fitness time courses; mouse genes
join human by identical upper-cased STRING name; hits are FDR < 0.10; a paper's
screens count once. `build` stores it as two tables so queries do not reload
2.9M results:

  screen       contrast_id -> pmid, taxon, selection class, n_tested, n_hits,
               hit rate (on the folded human universe)
  screen_call  contrast_id, human string_id, estimate, fdr (best-p element per
               protein, as analyses.Graph)

Co-hit tests:
  find_bridges  the pathway map's per-pair test: papers in which one screen
                hits both, against the chance each screen co-hits at its hit
                rate squared (Poisson over papers). One pair, so uncorrected.
  find_c        conditional on a: in the screens that hit a, how many papers
                also hit c, against each screen's hit rate (Poisson over
                papers); BH over every gene tested in those screens. A gene
                hit in a handful of papers rarely passes that genome-wide FDR
                (IFNGR1, 6 papers: STAT1 co-hit in 5 vs 0.44 expected, p 9e-5,
                q 0.66), so candidates are returned by p (default p <= 0.001)
                with q and passes_fdr_0.10 alongside: leads, not discoveries.
Hit rates include fitness genes and frequent hitters; those genes are flagged
and, in find_c, left out as candidates by default.
"""

import csv
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

from scipy.stats import poisson

from barcs_kg.analyses import HIT_FDR, Graph, bh

TAXA = (9606, 10090)
STRING_MIN = 700
CHANNEL_MIN = 400   # a non-text-mining channel at STRING "medium" confidence
SPECIFIC_TERM = 50
REPORTS = Path(__file__).resolve().parent.parent / "reports"


def build(db):
    con = sqlite3.connect(db)
    g = Graph(con)
    human = {n.upper(): s for s, n in g.name.items() if s.startswith("9606.")}
    con.executescript("""
    DROP TABLE IF EXISTS screen; DROP TABLE IF EXISTS screen_call;
    CREATE TABLE screen (contrast_id TEXT PRIMARY KEY, pmid TEXT, taxon INTEGER,
      selection TEXT, n_tested INTEGER, n_hits INTEGER, hit_rate REAL);
    CREATE TABLE screen_call (contrast_id TEXT, string_id TEXT, estimate REAL, fdr REAL);
    """)
    n = 0
    for c in g.contrast.values():
        if not c["eligible"] or c["taxon"] not in TAXA or c["selection"] == "fitness_time" \
                or not g.res.get(c["cid"]):
            continue
        best = {}
        for s, (est, p, fdr, _) in g.res[c["cid"]].items():
            hs = human.get(g.name[s].upper())
            if hs is not None and (hs not in best or p < best[hs][1]):
                best[hs] = (est, p, fdr)
        hits = sum(1 for v in best.values() if v[2] is not None and v[2] < HIT_FDR)
        con.execute("INSERT INTO screen VALUES (?,?,?,?,?,?,?)",
                    (c["cid"], c["pmid"], c["taxon"], c["selection"], len(best), hits,
                     hits / len(best) if best else 0.0))
        con.executemany("INSERT INTO screen_call VALUES (?,?,?,?)",
                        [(c["cid"], s, v[0], v[2]) for s, v in best.items()])
        n += 1
    con.executescript("""
    CREATE INDEX sc_sid ON screen_call(string_id);
    CREATE INDEX sc_cid ON screen_call(contrast_id);
    """)
    con.commit()
    print(f"screens: {n}; calls: {con.execute('SELECT count(*) FROM screen_call').fetchone()[0]}")


# ---------------------------------------------------------------- helpers

def _human(con, gene):
    row = con.execute("SELECT string_id, preferred_name FROM string_protein "
                      "WHERE taxon = 9606 AND upper(preferred_name) = upper(?)", (gene,)).fetchone()
    if row:
        return tuple(row)
    row = con.execute("SELECT gp.string_id, sp.preferred_name FROM gene_protein gp "
                      "JOIN string_protein sp USING (string_id) "
                      "WHERE gp.taxon = 9606 AND upper(gp.symbol) = upper(?) "
                      "AND gp.string_id IS NOT NULL", (gene,)).fetchone()
    return tuple(row) if row else (None, None)


def _flags():
    out = {}
    path = REPORTS / "recurrence.tsv"
    if path.exists():
        with open(path) as fh:
            for r in csv.DictReader(fh, delimiter="\t"):
                f = []
                if float(r["q"]) < 0.05 and int(r["n_selection_classes"]) >= 3:
                    f.append("frequent hitter")
                if r["fitness_prior"] == "1":
                    f.append("fitness gene")
                if f:
                    out[r["string_id"]] = f
    return out


def _links(con, sid):
    """STRING neighbours at >= STRING_MIN: {other: [(network, score, best_other_channel)]}."""
    out = defaultdict(list)
    for a, b, s, exp, db, tm in con.execute(
            "SELECT protein_a, protein_b, combined_score, experimental, database, textmining "
            "FROM string_physical WHERE (protein_a = ? OR protein_b = ?) AND combined_score >= ?",
            (sid, sid, STRING_MIN)):
        out[b if a == sid else a].append(("physical", s, max(exp, db)))
    for a, b, s, nb, fu, co, cx, exp, db, tm in con.execute(
            "SELECT protein_a, protein_b, combined_score, neighborhood, fusion, cooccurence, "
            "coexpression, experimental, database, textmining FROM string_functional "
            "WHERE (protein_a = ? OR protein_b = ?) AND combined_score >= ?",
            (sid, sid, STRING_MIN)):
        out[b if a == sid else a].append(("functional", s, max(nb, fu, co, cx, exp, db)))
    for a, b, s, exp, db, tm, pos, neg in con.execute(
            "SELECT protein_a, protein_b, combined_score, experimental, database, textmining, "
            "positive, negative FROM string_regulatory "
            "WHERE (protein_a = ? OR protein_b = ?) AND combined_score >= ?",
            (sid, sid, STRING_MIN)):
        kind = "regulates" if a == sid else "regulated_by"
        out[b if a == sid else a].append((kind, s, max(exp, db)))
    return out


def _supported(edges):
    return [e for e in edges if e[2] >= CHANNEL_MIN]


def _terms(con, sid, max_size):
    return {r[0]: r[1:] for r in con.execute("""
        SELECT t.term_id, t.source, t.name, t.n_proteins, e.independent
        FROM gene_term gt JOIN term t ON t.term_id = gt.term_id AND t.taxon = 9606
        LEFT JOIN gene_term_evidence e ON e.string_id = gt.string_id AND e.term_id = gt.term_id
        WHERE gt.string_id = ? AND t.n_proteins <= ?""", (sid, max_size))}


def _shared_terms(con, sa, sc, max_size):
    ta, tc = _terms(con, sa, max_size), _terms(con, sc, max_size)
    shared = []
    for t in ta.keys() & tc.keys():
        source, name, size, ind_a = ta[t]
        ind_c = tc[t][3]
        go = source.startswith("GO:")
        shared.append({"term_id": t, "source": source, "name": name, "n_proteins": size,
                       "independent": (bool(ind_a) and bool(ind_c)) if go else None})
    ids = [s["term_id"] for s in shared]
    if ids:
        marks = ",".join("?" * len(ids))
        anc = {a for (a,) in con.execute(
            f"SELECT DISTINCT ancestor_id FROM term_ancestor WHERE term_id IN ({marks})", ids)}
        shared = [s for s in shared if s["term_id"] not in anc]
    return sorted(shared, key=lambda s: (s["n_proteins"], s["term_id"]))


def _calls(con, sid):
    return {cid: (est, fdr) for cid, est, fdr in con.execute(
        "SELECT contrast_id, estimate, fdr FROM screen_call WHERE string_id = ?", (sid,))}


def _screens(con):
    return {r[0]: {"pmid": r[1], "rate": r[2], "selection": r[3]} for r in con.execute(
        "SELECT contrast_id, pmid, hit_rate, selection FROM screen")}


def _is_hit(v):
    return v is not None and v[1] is not None and v[1] < HIT_FDR


def _pair_test(screens, ca, cc):
    """The pathway map's test for one pair: co-hit papers vs hit rate squared."""
    obs, miss, same = set(), defaultdict(lambda: 1.0), 0
    co = []
    for cid in ca.keys() & cc.keys():
        s = screens[cid]
        miss[s["pmid"]] *= 1 - s["rate"] ** 2
        if _is_hit(ca[cid]) and _is_hit(cc[cid]):
            obs.add(s["pmid"])
            agree = (ca[cid][0] > 0) == (cc[cid][0] > 0)
            same += agree
            co.append({"contrast_id": cid, "pmid": s["pmid"], "selection": s["selection"],
                       "estimate_a": round(ca[cid][0], 3), "estimate_c": round(cc[cid][0], 3),
                       "same_direction": agree})
    lam = sum(1 - m for m in miss.values())
    n = len(obs)
    return {"papers_both_tested": len(miss), "papers_cohit": n, "expected": round(lam, 3),
            "p_poisson": float(poisson.sf(n - 1, lam)) if n else 1.0,
            "screens_cohit": len(co), "same_direction": same, "cohit_screens": co}


def explain(con, sa, sc, max_term_size=200, bridge_limit=10, flags=None, links_a=None,
            screens=None, calls_a=None):
    """How a and c are linked: direct, through a term, through a gene b, or not at all."""
    flags = _flags() if flags is None else flags
    links_a = _links(con, sa) if links_a is None else links_a
    links_c = _links(con, sc)
    names = {}

    def name(s):
        if s not in names:
            r = con.execute("SELECT preferred_name FROM string_protein WHERE string_id = ?", (s,)).fetchone()
            names[s] = r[0] if r else s
        return names[s]

    direct = [{"network": k, "score": s, "best_other_channel": o, "textmining_only": o < CHANNEL_MIN}
              for k, s, o in links_a.get(sc, [])]
    terms = _shared_terms(con, sa, sc, max_term_size)
    specific = [t for t in terms if t["n_proteins"] <= SPECIFIC_TERM and t["independent"] is not False]

    screens = _screens(con) if screens is None else screens
    calls_a = _calls(con, sa) if calls_a is None else calls_a
    calls_c = _calls(con, sc)
    hit_cids = {cid for cid, v in calls_a.items() if _is_hit((None, v[1]))} | \
               {cid for cid, v in calls_c.items() if _is_hit((None, v[1]))}
    bridges = []
    for b in (links_a.keys() & links_c.keys()) - {sa, sc}:
        ea, ec = _supported(links_a[b]), _supported(links_c[b])
        bridges.append({"gene_b": name(b), "string_id": b,
                        "a_b": [{"network": k, "score": s} for k, s, _ in links_a[b]],
                        "b_c": [{"network": k, "score": s} for k, s, _ in links_c[b]],
                        "supported_both_sides": bool(ea and ec),
                        "min_score": min(max(s for _, s, _ in links_a[b]), max(s for _, s, _ in links_c[b])),
                        "flags": flags.get(b, []), "_sid": b})
    if bridges:
        cb = defaultdict(dict)
        marks = ",".join("?" * len(bridges))
        for cid, s, est, fdr in con.execute(
                f"SELECT contrast_id, string_id, estimate, fdr FROM screen_call WHERE string_id IN ({marks})",
                [x["_sid"] for x in bridges]):
            cb[s][cid] = (est, fdr)
        for x in bridges:
            x["papers_hit_with_a_or_c"] = len({screens[cid]["pmid"] for cid, v in cb[x["_sid"]].items()
                                               if cid in hit_cids and _is_hit(v)})
            del x["_sid"]
    bridges.sort(key=lambda x: (not x["supported_both_sides"], bool(x["flags"]),
                                -x["papers_hit_with_a_or_c"], -x["min_score"], x["gene_b"]))

    if any(not d["textmining_only"] for d in direct):
        kind = "direct"
    elif specific:
        kind = "term"
    elif any(x["supported_both_sides"] for x in bridges):
        kind = "gene"
    elif direct or bridges:
        kind = "text mining only"
    else:
        kind = "unexplained"
    return {"link": kind, "direct": direct, "shared_terms": terms[:15],
            "bridge_genes": bridges[:int(bridge_limit)], "n_bridge_genes": len(bridges),
            "screens": _pair_test(screens, calls_a, calls_c)}


# ---------------------------------------------------------------- tools

def find_bridges(con, gene_a, gene_c, max_term_size=200, limit=10):
    sa, na = _human(con, gene_a)
    sc, nc = _human(con, gene_c)
    if not sa or not sc:
        return {"error": f"no human STRING protein for {gene_a if not sa else gene_c}"}
    flags = _flags()
    out = {"gene_a": na, "gene_c": nc, "flags_a": flags.get(sa, []), "flags_c": flags.get(sc, [])}
    out.update(explain(con, sa, sc, int(max_term_size), int(limit), flags))
    return out


def find_c(con, gene_a, min_papers=2, p_max=0.001, q_max=1.0, include_flagged=False,
           max_term_size=200, unexplained_only=False, limit=30):
    sa, na = _human(con, gene_a)
    if not sa:
        return {"error": f"no human STRING protein for {gene_a}"}
    screens = _screens(con)
    calls_a = _calls(con, sa)
    s_a = [cid for cid, v in calls_a.items() if _is_hit((None, v[1]))]
    if not s_a:
        return {"gene_a": na, "screens_hitting_a": 0, "candidates": [],
                "note": "a is not hit in any eligible screen"}
    marks = ",".join("?" * len(s_a))
    obs, miss = defaultdict(set), defaultdict(lambda: defaultdict(lambda: 1.0))
    for cid, s, est, fdr in con.execute(
            f"SELECT contrast_id, string_id, estimate, fdr FROM screen_call WHERE contrast_id IN ({marks})", s_a):
        if s == sa:
            continue
        p = screens[cid]["pmid"]
        miss[s][p] *= 1 - screens[cid]["rate"]
        if fdr is not None and fdr < HIT_FDR:
            obs[s].add(p)
    flags = _flags()
    genes = list(miss)
    lam = [sum(1 - m for m in miss[s].values()) for s in genes]
    n = [len(obs[s]) for s in genes]
    p = [float(poisson.sf(k - 1, l)) if k else 1.0 for k, l in zip(n, lam)]
    q = bh(p) if genes else []
    keep = [i for i in range(len(genes)) if n[i] >= int(min_papers) and p[i] <= float(p_max)
            and q[i] <= float(q_max)
            and (str(include_flagged).lower() in ("1", "true", "yes") or not flags.get(genes[i]))]
    keep.sort(key=lambda i: (p[i], -n[i]))
    links_a = _links(con, sa)
    out = []
    for i in keep:
        e = explain(con, sa, genes[i], int(max_term_size), 3, flags, links_a, screens, calls_a)
        if str(unexplained_only).lower() in ("1", "true", "yes") and e["link"] != "unexplained":
            continue
        r = con.execute("SELECT preferred_name FROM string_protein WHERE string_id = ?", (genes[i],)).fetchone()
        out.append({"gene_c": r[0], "papers_cohit": n[i], "expected": round(lam[i], 3),
                    "p": p[i], "q": float(q[i]), "passes_fdr_0.10": bool(q[i] < 0.10), "flags": flags.get(genes[i], []), "link": e["link"],
                    "same_direction": e["screens"]["same_direction"],
                    "screens_cohit": e["screens"]["screens_cohit"],
                    "top_terms": [t["name"] for t in e["shared_terms"][:3]],
                    "top_bridges": [b["gene_b"] for b in e["bridge_genes"][:3]]})
        if len(out) >= int(limit):
            break
    return {"gene_a": na, "flags_a": flags.get(sa, []), "screens_hitting_a": len(s_a),
            "papers_hitting_a": len({screens[c]["pmid"] for c in s_a}),
            "genes_tested": len(genes), "candidates": out}


if __name__ == "__main__":
    build(sys.argv[1])
