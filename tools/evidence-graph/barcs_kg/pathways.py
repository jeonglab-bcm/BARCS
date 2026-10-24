"""Pathway map: gene modules that screens from different papers hit together.

    uv run python -m barcs_kg.pathways build/barcs_kg.sqlite reports build/string_v12.5 viz/pathways.json

The screen-to-screen correlation map turned out to track how much growth signal
each screen carries, so this view links screens through genes instead. The unit
of evidence is a STRING physical interaction whose two genes are both hits in
the same screen, in more papers than the papers' hit rates predict. Such
replicated pairs join into modules, and a screen joins a module through the
pairs it hits.

Pipeline, in order:

1. Screens: eligible primary contrasts (analyses.py), human or mouse, minus the
   fitness time courses. Mouse genes join human by identical symbol.
2. Hits are FDR < 0.10. Fitness-prior genes, frequent hitters and the rest of
   each essential machine (ribosome, spliceosome, EIF3: members of a mostly
   fitness gene set that also deplete in a BARCS fitness screen) are removed
   from hits and from the tested set alike, so none of them can make a link.
3. For every STRING physical pair (score >= 700) of tested genes: the papers in
   which some screen hits both genes, against the number expected if each
   screen picked its hits at random (Poisson over papers; one paper's screens
   share cells and count once). BH over all pairs.
4. Replicated pairs (q < Q_CUT, >= MIN_PAPERS papers) form modules by
   connected components; a component too large to read is split at a stricter
   STRING score.
5. Each module is named by the Reactome pathway or STRING cluster that best
   matches its genes; the name is a label, the genes are the evidence.
"""

import csv
import gzip
import json
import os
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np
from scipy.stats import hypergeom, poisson

from barcs_kg.analyses import HIT_FDR, PHYS_HIGH, Graph, essential_reference

MIN_PAPERS = 2
# PATHWAYS_PAIR_TEST=off keeps pairs co-hit in MIN_PAPERS papers without the
# per-pair Poisson test and reports a shuffled-hit control instead.
PAIR_TEST = os.environ.get("PATHWAYS_PAIR_TEST", "on") != "off"
SHUFFLES = 50
Q_CUT = 0.05             # BH over every tested STRING pair
SCORES = (PHYS_HIGH, 800, 900, 950, 990)  # STRING physical score steps for splitting
MODULE_MAX = 15          # genes in a module before it is split at a stricter score
MIN_GENES = 3
MACHINERY_SHARE = 0.6    # a set this full of fitness genes is essential machinery...
MACHINERY_MAX = 150      # ...if it is small enough to be one machine, not a whole process
NAME_COVER = 0.4         # a set names a module only if it holds this share of its genes
TAXA = (9606, 10090)
CATEGORIES = {"Reactome Pathways": "Reactome", "Local Network Cluster (STRING)": "STRING cluster"}


def bh(p):
    p = np.asarray(p, float)
    o = np.argsort(p)
    q = np.minimum.accumulate((p[o] * len(p) / np.arange(1, len(p) + 1))[::-1])[::-1]
    out = np.empty_like(q)
    out[o] = np.minimum(q, 1.0)
    return out


def run(db, reports, string_dir, out):
    con = sqlite3.connect(db)
    g = Graph(con)
    human = {n.upper(): s for s, n in g.name.items() if s.startswith("9606.")}
    # recurrence.tsv lists only genes hit somewhere, so the fitness prior comes from its source
    fitness = essential_reference(g, Path(db).parent / "reference" / "CEGv2.txt")[0][9606]
    rec = list(csv.DictReader(open(f"{reports}/recurrence.tsv"), delimiter="\t"))
    frequent = {human[r["gene"].upper()] for r in rec if r["gene"].upper() in human
                and float(r["q"]) < 0.05 and int(r["n_selection_classes"]) >= 3}
    members, names = defaultdict(set), {}
    with gzip.open(f"{string_dir}/9606.protein.enrichment.terms.v12.5.txt.gz", "rt") as fh:
        next(fh)
        for line in fh:
            sid, cat, term, desc = line.rstrip("\n").split("\t")
            if cat in CATEGORIES:
                members[term].add(sid)
                names[term] = (desc, CATEGORIES[cat])
    # The fitness prior misses part of each essential machine (ribosome, spliceosome,
    # EIF3). A gene in a set that is mostly fitness genes, and that is depleted in
    # at least one BARCS fitness screen itself, is treated as fitness too.
    depleted = set()
    for c in g.primaries():
        if c["selection"] == "fitness_time" and c["modality"] in ("KO", "CRISPRi", "KO+CRISPRi"):
            depleted |= {human[g.name[s].upper()] for s, (est, p, fdr, _) in g.res[c["cid"]].items()
                         if fdr is not None and fdr < HIT_FDR and est < 0 and g.name[s].upper() in human}
    machinery = depleted & set().union(*(m for m in members.values() if MIN_GENES <= len(m) <= MACHINERY_MAX
                                         and len(m & fitness) >= MACHINERY_SHARE * len(m)))
    excluded = fitness | frequent | machinery

    meta = {r[0]: r[1:] for r in con.execute("""
        SELECT c.contrast_id, p.title, p.pmid, p.doi, c.orientation, sa.organism, c.gse
        FROM contrast c JOIN series s USING (gse) JOIN publication p ON p.pmid = s.pmid
        JOIN series_annotation sa USING (gse)""")}

    screens = {}
    for c in g.contrast.values():
        if not c["eligible"] or c["taxon"] not in TAXA or c["selection"] == "fitness_time" \
                or not g.res.get(c["cid"]):
            continue
        tested, hits = set(), {}
        for s, (est, p, fdr, _) in g.res[c["cid"]].items():
            hs = human.get(g.name[s].upper())
            if hs is None or hs in excluded:
                continue
            tested.add(hs)
            if fdr is not None and fdr < HIT_FDR:
                hits[hs] = (est, fdr)
        if hits:
            screens[c["cid"]] = {"tested": tested, "hits": hits, "c": c}

    cids = sorted(screens)
    genes = sorted(set().union(*(s["tested"] for s in screens.values())))
    gidx = {s: i for i, s in enumerate(genes)}
    gset = set(genes)
    T = np.zeros((len(genes), len(cids)), bool)
    H = np.zeros_like(T)
    for j, cid in enumerate(cids):
        T[[gidx[s] for s in screens[cid]["tested"]], j] = True
        H[[gidx[s] for s in screens[cid]["hits"]], j] = True
    rate = H.sum(0) / T.sum(0)
    pmids = sorted({screens[cid]["c"]["pmid"] for cid in cids})
    paper_of = np.array([pmids.index(screens[cid]["c"]["pmid"]) for cid in cids])

    pa, pb = [], []
    for a, nb in g.adj_phys.items():
        if a not in gidx:
            continue
        for b in nb:
            if b in gidx and gidx[a] < gidx[b]:
                pa.append(gidx[a])
                pb.append(gidx[b])
    pa, pb = np.array(pa), np.array(pb)
    both_tested = T[pa] & T[pb]
    cohit = H[pa] & H[pb]
    # Collapse screens to papers: observed = papers with a co-hit, expected = the
    # chance that at least one of that paper's screens co-hits at its hit rate.
    obs = np.zeros((len(pa), len(pmids)), bool)
    miss = np.ones((len(pa), len(pmids)))
    for j in range(len(cids)):
        obs[:, paper_of[j]] |= cohit[:, j]
        miss[:, paper_of[j]] *= np.where(both_tested[:, j], 1 - rate[j] ** 2, 1.0)
    n_obs = obs.sum(1)
    lam = (1 - miss).sum(1)
    testable = ((1 - miss) > 0).sum(1) >= MIN_PAPERS
    p = np.where(n_obs >= MIN_PAPERS, poisson.sf(n_obs - 1, lam), 1.0)
    q = np.ones(len(pa))
    q[testable] = bh(p[testable])
    keep = testable & (q < Q_CUT) & (n_obs >= MIN_PAPERS)
    shuffled = None
    if not PAIR_TEST:
        # Small corpora (the developmental page): no single pair can pass the
        # per-pair test, so keep every pair co-hit in MIN_PAPERS papers and
        # report the same count on shuffled hits (each screen keeps its number
        # of hits among the genes it tested) as a corpus-level check.
        keep = n_obs >= MIN_PAPERS
        rng = np.random.default_rng(20261024)
        counts = []
        for _ in range(SHUFFLES):
            Hs = np.zeros_like(H)
            for j in range(len(cids)):
                idx = np.flatnonzero(T[:, j])
                Hs[rng.choice(idx, int(H[:, j].sum()), replace=False), j] = True
            co = Hs[pa] & Hs[pb]
            ob = np.zeros((len(pa), len(pmids)), bool)
            for j in range(len(cids)):
                ob[:, paper_of[j]] |= co[:, j]
            counts.append(int((ob.sum(1) >= MIN_PAPERS).sum()))
        shuffled = {"mean": round(float(np.mean(counts)), 1), "min": int(min(counts)),
                    "max": int(max(counts)), "runs": SHUFFLES}
    pair_stat = {}
    adj = defaultdict(set)
    for k in np.flatnonzero(keep):
        a, b = genes[pa[k]], genes[pb[k]]
        adj[a].add(b)
        adj[b].add(a)
        pair_stat[frozenset((a, b))] = (int(n_obs[k]), float(lam[k]), float(q[k]))

    def split(nodes, k=0):
        """Connected components of replicated pairs at STRING score SCORES[k]; a
        component too large to read as one module is split at the next score."""
        out, left = [], set(nodes)
        while left:
            x = left.pop()
            comp, stack = {x}, [x]
            while stack:
                y = stack.pop()
                for z in adj[y] & left:
                    if g.adj_phys[y][z][0] >= SCORES[k]:
                        left.discard(z)
                        comp.add(z)
                        stack.append(z)
            if len(comp) > MODULE_MAX and k + 1 < len(SCORES):
                out += split(comp, k + 1)
            elif len(comp) >= MIN_GENES:
                out.append(comp)
        return out

    modules = []
    for m in split(list(adj)):
        inner = sorted((a, b) for a in m for b in adj[a] & m if a < b)
        on = {}
        for cid in cids:
            hs = screens[cid]["hits"]
            got = {x for a, b in inner if a in hs and b in hs for x in (a, b)}
            if got:
                on[cid] = got
        pm = {screens[cid]["c"]["pmid"] for cid in on}
        # name: the most specific set covering enough of the module, if any does
        need = max(2, round(NAME_COVER * len(m)))
        named = [(hypergeom.sf(len(m & ms) - 1, len(genes), len(ms & gset), len(m)), t)
                 for t, ms in members.items() if len(m & ms) >= need]
        modules.append((m, inner, on, pm, min(named)[1] if named else None))
    modules.sort(key=lambda x: (-len(x[3]), -len(x[0]), sorted(g.name[s] for s in x[0])))

    curation = Path(__file__).resolve().parent.parent / "curation"
    labels, names_by_anchor = {}, []
    if (curation / "screen_labels.tsv").exists():
        labels = {r["contrast_id"]: r["label"] for r in csv.DictReader(
            open(curation / "screen_labels.tsv"), delimiter="\t") if r["label"].strip()}
    # A curated name applies to the module that holds all of its anchor genes, so
    # it survives a rebuild that adds or drops a gene at the module's edge.
    if (curation / "module_names.tsv").exists():
        names_by_anchor = [({x.strip().upper() for x in r["anchor_genes"].split(",")}, r["name"], r["theme"])
                           for r in csv.DictReader(open(curation / "module_names.tsv"), delimiter="\t")]
    used = sorted({cid for x in modules for cid in x[2]})
    sidx = {cid: i for i, cid in enumerate(used)}
    out_screens = []
    for cid in used:
        c = screens[cid]["c"]
        title, pmid, doi, orient, organism, gse = meta[cid]
        out_screens.append({"id": cid, "label": labels.get(cid), "gse": gse, "title": title,
                            "pmid": pmid, "doi": doi,
                            "orientation": orient, "organism": organism,
                            "selection": c["selection"], "modality": c["modality"],
                            "tested": len(screens[cid]["tested"]),
                            "hits": len(screens[cid]["hits"])})
    out_modules = []
    for m, inner, on, pm, best in modules:
        papers_of = {s: {screens[cid]["c"]["pmid"] for cid, got in on.items() if s in got} for s in m}
        order = sorted(m, key=lambda s: (-len(papers_of[s]), g.name[s]))
        gi = {s: i for i, s in enumerate(order)}
        edges = sorted([gi[a], gi[b], g.adj_phys[a][b][0], *pair_stat[frozenset((a, b))]] for a, b in inner)
        for e in edges:
            e[4], e[5] = round(e[4], 2), float(f"{e[5]:.2g}")
        links = []
        for cid, got in sorted(on.items(), key=lambda kv: -len(kv[1])):
            hs = screens[cid]["hits"]
            links.append({"s": sidx[cid], "genes": [[gi[s], round(hs[s][0], 3), float(f"{hs[s][1]:.2g}")]
                                                     for s in sorted(got, key=lambda x: gi[x])]})
        desc, source = names[best] if best else (None, None)
        upper = {g.name[s].upper() for s in m}
        curated = next(((n, t) for anchor, n, t in names_by_anchor if anchor <= upper), (None, None))
        out_modules.append({"name": curated[0], "theme": curated[1], "genes": [g.name[s] for s in order],
                            "gene_papers": [len(papers_of[s]) for s in order], "edges": edges,
                            "set": desc, "source": source,
                            "set_size": len(members[best] & gset) if best else None,
                            "set_overlap": len(m & members[best]) if best else None,
                            "papers": len(pm), "links": links})
    data = {"screens": out_screens, "modules": out_modules,
            "params": {"hit_fdr": HIT_FDR, "q_cut": Q_CUT, "min_papers": MIN_PAPERS,
                       "string_physical": PHYS_HIGH, "fitness_genes": len(fitness),
                       "frequent_hitters": len(frequent), "machinery_genes": len(machinery - fitness),
                       "screens_tested": len(cids), "papers": len(pmids),
                       "pairs_tested": int(testable.sum()), "pairs_replicated": int(keep.sum()),
                       "pair_test": "on" if PAIR_TEST else "off", "shuffled": shuffled}}
    with open(out, "w") as fh:
        json.dump(data, fh, separators=(",", ":"))
    return data


if __name__ == "__main__":
    d = run(*sys.argv[1:5])
    print(json.dumps(d["params"]))
    print(len(d["modules"]), "modules,", len(d["screens"]), "screens")
