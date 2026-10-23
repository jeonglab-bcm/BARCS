"""Condition similarity: which screens report the same gene-level signal.

    uv run python -m barcs_kg.similarity build/barcs_kg.sqlite reports build/similarity.json

Not hit-list overlap. Every gene a contrast tested carries a signed z, so a pair
is judged on its whole genome-wide profile instead of on two FDR thresholds.

Pipeline, in order:

1. z = signed inverse-normal of the gene p-value, sign from the estimate.
2. Inverse-normal transform per contrast, so heavy tails and differing power do
   not decide the correlation.
3. Fitness axis = mean profile of the genome-wide human KO fitness contrasts.
   Every profile is regressed on it and the residual is kept, so "both screens
   deplete essential genes" cannot create an edge. A contrast that helps define
   the axis is regressed on a leave-one-out axis; regressing it on an axis
   containing itself would over-correct and leave the fitness screens
   anti-correlated with one another.
4. Frequent hitters (reports/recurrence.tsv) are dropped.
5. Pairwise-complete Pearson on the residuals = Spearman on the fitness-free
   profile.
6. Null by block permutation: gene labels are shuffled in blocks, so the null
   keeps the gene-gene dependence that a plain permutation destroys. Blocks are
   connected components of STRING physical >= 900, capped at BLOCK_CAP genes:
   one component holds half the genome, and leaving it whole would carry the
   real correspondence straight into the null.

Only cross-paper pairs are tested. Same-paper pairs are held out as positive
controls: they must rank far above the null or the measure is not working.
A pair is also reported with whether the two screens used the same guide
library, since shared guide-efficiency bias can correlate two profiles that
share no biology.
"""

import csv
import json
import sqlite3
import sys
from collections import defaultdict

import numpy as np
from scipy.stats import norm

MIN_GENES = 500          # a contrast needs this many mapped genes to get a profile
MIN_SHARED = 1000        # a pair needs this many genes in common
Q_CUT = 0.05             # BH over cross-paper pairs
R_FLOOR = 0.10           # effect floor: at ~18k genes, q alone passes trivial correlations
MAX_EDGES_WITH_DRIVERS = 600
DRIVERS_PER_EDGE = 25
N_PERM = 200
RNG_SEED = 11
STRING_BLOCK = 900       # components at this score are complexes, not pathways
BLOCK_CAP = 20           # split larger components; the giant one spans half the genome
TAXA = (9606, 10090, 10116, 9913)


def inverse_normal(v):
    """Rank-based inverse-normal transform, ties averaged."""
    n = len(v)
    order = np.argsort(v, kind="stable")
    ranks = np.empty(n)
    ranks[order] = np.arange(1, n + 1)
    # average ties so that a block of identical p-values is not given a direction
    _, inv, counts = np.unique(v, return_inverse=True, return_counts=True)
    if (counts > 1).any():
        sums = np.zeros(len(counts))
        np.add.at(sums, inv, ranks)
        ranks = (sums / counts)[inv]
    return norm.ppf(ranks / (n + 1))


def blocks(con, proteins):
    """Union-find components of STRING physical >= STRING_BLOCK."""
    idx = {p: i for i, p in enumerate(proteins)}
    parent = list(range(len(proteins)))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    for a, b in con.execute("SELECT protein_a, protein_b FROM string_physical WHERE combined_score >= ?",
                            (STRING_BLOCK,)):
        ia, ib = idx.get(a), idx.get(b)
        if ia is None or ib is None:
            continue
        ra, rb = find(ia), find(ib)
        if ra != rb:
            parent[ra] = rb
    comp = np.array([find(i) for i in range(len(proteins))])
    # Split oversized components so the null cannot preserve global correspondence.
    out = np.empty(len(comp), dtype=np.int64)
    nxt = 0
    for c in np.unique(comp):
        members = np.flatnonzero(comp == c)
        for k in range(0, len(members), BLOCK_CAP):
            out[members[k:k + BLOCK_CAP]] = nxt
            nxt += 1
    return out


def pairwise_complete(X, M, Y=None, MY=None):
    """Pearson correlation of every column of X against every column of Y, each
    pair over the rows both tested. Y defaults to X, giving the symmetric matrix.

    X is genes x contrasts with 0 where untested, M the 0/1 mask. Every term is
    a matmul, so the whole matrix comes out in one pass. Passing a row-permuted
    X as one side and the untouched matrix as the other gives the null; permuting
    both sides alike would change nothing, since correlation ignores row order.
    """
    if Y is None:
        Y, MY = X, M
    n = M.T @ MY
    sx = X.T @ MY           # sum of X over rows the pair shares
    sy = (M.T @ Y)          # sum of Y over the same rows
    sxy = X.T @ Y
    sxx = (X * X).T @ MY
    syy = M.T @ (Y * Y)
    with np.errstate(invalid="ignore", divide="ignore"):
        cov = sxy - sx * sy / n
        vx = sxx - sx ** 2 / n
        vy = syy - sy ** 2 / n
        r = cov / np.sqrt(vx * vy)
    r[~np.isfinite(r)] = np.nan
    return r, n


LIBRARIES = ("brunello", "brie", "gecko", "tkov3", "bassik", "calabrese", "crispri-v2",
             "crispra-v2", "minlibcas9", "eko", "crincl", "addgene")


def library(contrast, con):
    """Guide library named in the series text, lower-cased, else None."""
    row = con.execute("SELECT model_text || ' ' || contrast_text FROM series WHERE gse = ?",
                      (contrast["gse"],)).fetchone()
    text = (row[0] or "").lower() if row else ""
    hits = [name for name in LIBRARIES if name.replace("-", "") in text.replace("-", "")]
    return hits[0] if len(hits) == 1 else None


def run(db, reports, out):
    con = sqlite3.connect(db)
    from barcs_kg.analyses import Graph
    g = Graph(con)
    human = {n.upper(): s for s, n in g.name.items() if s.startswith("9606.")}
    rec = list(csv.DictReader(open(f"{reports}/recurrence.tsv"), delimiter="\t"))
    drop = {human[r["gene"].upper()] for r in rec
            if r["taxon"] == "9606" and float(r["q"]) < 0.05 and int(r["n_selection_classes"]) >= 3
            and r["gene"].upper() in human}

    profiles = {}
    for c in g.contrast.values():
        if not c["eligible"] or c["taxon"] not in TAXA or not g.res.get(c["cid"]):
            continue
        v = {}
        for s, (est, p, fdr, _) in g.res[c["cid"]].items():
            hs = human.get(g.name[s].upper())
            if hs is None or p is None or hs in drop:
                continue
            z = -norm.ppf(max(p, 1e-300) / 2) * (1.0 if est > 0 else -1.0)
            if hs not in v or abs(z) > abs(v[hs]):
                v[hs] = z
        if len(v) >= MIN_GENES:
            profiles[c["cid"]] = v

    cids = sorted(profiles)
    proteins = sorted({s for v in profiles.values() for s in v})
    pidx = {p: i for i, p in enumerate(proteins)}
    X = np.zeros((len(proteins), len(cids)))
    M = np.zeros_like(X)
    for j, cid in enumerate(cids):
        rows = np.fromiter((pidx[s] for s in profiles[cid]), int, len(profiles[cid]))
        vals = np.fromiter(profiles[cid].values(), float, len(profiles[cid]))
        X[rows, j] = inverse_normal(vals)
        M[rows, j] = 1.0

    # fitness axis from genome-wide human KO fitness contrasts
    fit_cols = [j for j, cid in enumerate(cids)
                if g.contrast[cid]["selection"] == "fitness_time"
                and g.contrast[cid]["modality"] == "KO" and g.contrast[cid]["taxon"] == 9606
                and (g.contrast[cid]["genes"] or 0) >= 15000]
    fit_set = set(fit_cols)
    cover = M[:, fit_cols].sum(1)
    tot = X[:, fit_cols].sum(1)
    axis_ok = cover >= 2

    def axis_for(j):
        """Leave-one-out when j is one of the contrasts defining the axis."""
        if j not in fit_set:
            return np.divide(tot, cover, out=np.zeros(len(proteins)), where=cover > 0), axis_ok
        c2 = cover - M[:, j]
        t2 = tot - X[:, j]
        return (np.divide(t2, c2, out=np.zeros(len(proteins)), where=c2 > 0), c2 >= 2)

    R = X.copy()
    for j in range(len(cids)):
        axis, ok = axis_for(j)
        m = (M[:, j] > 0) & ok
        if m.sum() < MIN_GENES:
            continue
        a, x = axis[m], X[m, j]
        beta = np.dot(a - a.mean(), x - x.mean()) / max(np.dot(a - a.mean(), a - a.mean()), 1e-9)
        R[m, j] = x - beta * (a - a.mean())
        R[~m, j] = 0.0
        M[~m, j] = 0.0
    R *= M

    r, n = pairwise_complete(R, M)

    blk = blocks(con, proteins)
    rng = np.random.default_rng(RNG_SEED)
    uniq, inv = np.unique(blk, return_inverse=True)
    order = np.argsort(inv, kind="stable")
    starts = np.searchsorted(inv[order], np.arange(len(uniq)))
    bounds = np.append(starts, len(order))
    null_abs = []
    off = ~np.eye(len(cids), dtype=bool)
    # Fisher z of each pair's null draws, accumulated as sum and sum of squares
    # so every pair gets its own null centre and spread without storing 200 matrices.
    nsum = np.zeros((len(cids), len(cids)))
    nsq = np.zeros_like(nsum)
    for _ in range(N_PERM):
        perm_blocks = rng.permutation(len(uniq))
        new_order = np.concatenate([order[bounds[b]:bounds[b + 1]] for b in perm_blocks])
        rp, npair = pairwise_complete(R[new_order], M[new_order], R, M)
        vals = rp[off & (npair >= MIN_SHARED)]
        null_abs.append(np.nanpercentile(np.abs(vals), [50, 95, 99, 99.9]))
        zp = np.arctanh(np.clip(np.nan_to_num(rp), -0.999999, 0.999999))
        zp = (zp + zp.T) / 2     # a pair's two permuted orientations are both draws
        nsum += zp
        nsq += zp ** 2
    null_mean = nsum / N_PERM
    null_sd = np.sqrt(np.maximum(nsq / N_PERM - null_mean ** 2, 1e-12))
    null_abs = np.array(null_abs)
    median_stability = float(np.std(null_abs[:, 0]))   # spread of the null median across permutations
    thresholds = {q: float(np.nanmean(null_abs[:, i]))
                  for i, q in enumerate(("p50", "p95", "p99", "p999"))}
    zobs = np.arctanh(np.clip(np.nan_to_num(r), -0.999999, 0.999999))
    zscore = (zobs - null_mean) / null_sd
    pval = 2 * norm.sf(np.abs(zscore))

    lib = {cid: library(g.contrast[cid], con) for cid in cids}
    pmid = {cid: g.contrast[cid]["pmid"] for cid in cids}
    pairs = []
    iu = np.triu_indices(len(cids), 1)
    for i, j in zip(*iu):
        if n[i, j] < MIN_SHARED or not np.isfinite(r[i, j]):
            continue
        la, lb = lib[cids[i]], lib[cids[j]]
        pairs.append({"a": int(i), "b": int(j), "r": float(r[i, j]), "n": int(n[i, j]),
                      "z": float(zscore[i, j]), "p": float(pval[i, j]),
                      "same_paper": pmid[cids[i]] == pmid[cids[j]],
                      "same_library": bool(la and lb and la == lb)})
    cross_idx = [k for k, p in enumerate(pairs) if not p["same_paper"]]
    ps = np.array([pairs[k]["p"] for k in cross_idx])
    o = np.argsort(ps)
    q = np.minimum.accumulate((ps[o] * len(ps) / np.arange(1, len(ps) + 1))[::-1])[::-1]
    for rank, k in enumerate(np.array(cross_idx)[o]):
        pairs[k]["q"] = float(min(1.0, q[rank]))
    for k, p in enumerate(pairs):
        p.setdefault("q", None)
    cross = np.array([abs(p["r"]) for p in pairs if not p["same_paper"]])
    same = np.array([abs(p["r"]) for p in pairs if p["same_paper"]])
    cut = thresholds["p999"]
    for p in pairs:
        p["beyond_null"] = abs(p["r"]) > cut
    sl = np.array([abs(p["r"]) for p in pairs if not p["same_paper"] and p["same_library"]])
    dl = np.array([abs(p["r"]) for p in pairs if not p["same_paper"] and not p["same_library"]])

    # How much fitness signal each contrast carried before the regression removed
    # it. The residual is zero by construction, so it is this figure that says
    # whether a contrast was mostly proliferation to begin with.
    fit_load = {}
    for j, cid in enumerate(cids):
        axis, ok = axis_for(j)
        m = (M[:, j] > 0) & ok
        if m.sum() < MIN_GENES:
            fit_load[cid] = None
            continue
        a, x = axis[m], X[m, j]
        sa, sx = a.std(), x.std()
        fit_load[cid] = float(np.dot(a - a.mean(), x - x.mean()) / (m.sum() * sa * sx)) if sa and sx else None

    # Driver genes for every reported cross-paper edge: the genes whose residual
    # profiles agree most, which is what a follow-up experiment would test.
    name = {s: g.name[s] for s in proteins}
    sig = [p for p in pairs if not p["same_paper"] and p["q"] is not None
           and p["q"] < Q_CUT and abs(p["r"]) >= R_FLOOR]
    sig.sort(key=lambda p: -abs(p["r"]))
    for p in sig[:MAX_EDGES_WITH_DRIVERS]:
        i, j = p["a"], p["b"]
        m = (M[:, i] > 0) & (M[:, j] > 0)
        prod = R[:, i] * R[:, j] * m
        sign = 1.0 if p["r"] > 0 else -1.0
        top = np.argsort(-sign * prod)[:DRIVERS_PER_EDGE]
        p["drivers"] = [[name[proteins[t]], round(float(R[t, i]), 2), round(float(R[t, j]), 2)]
                        for t in top if sign * prod[t] > 0]
    result = {
        "contrasts": [{"id": cid, "library": lib[cid], "selection": g.contrast[cid]["selection"],
                       "modality": g.contrast[cid]["modality"], "taxon": g.contrast[cid]["taxon"],
                       "pmid": g.contrast[cid]["pmid"], "genes": int(M[:, j].sum()),
                       "fitness_load_r": fit_load[cid]}
                      for j, cid in enumerate(cids)],
        "pairs": pairs,
        "edges_reported": len(sig),
        "r_floor": R_FLOOR, "q_cut": Q_CUT,
        "null": {"permutations": N_PERM, "block_score": STRING_BLOCK, "blocks": int(len(uniq)),
                 "abs_r_quantiles": thresholds, "sd_of_median": median_stability},
        "check": {"cross_paper_pairs": int(len(cross)), "same_paper_pairs": int(len(same)),
                  "median_abs_r_cross": float(np.median(cross)) if len(cross) else None,
                  "median_abs_r_same": float(np.median(same)) if len(same) else None,
                  "cross_q05": int(sum(1 for p in pairs if not p["same_paper"] and p["q"] is not None and p["q"] < Q_CUT)),
                  "cross_q05_and_r_floor": int(sum(1 for p in pairs if not p["same_paper"] and p["q"] is not None and p["q"] < Q_CUT and abs(p["r"]) >= R_FLOOR)),
                  "same_paper_q_free_z_median": float(np.median([p["z"] for p in pairs if p["same_paper"]])),
                  "cross_paper_z_median": float(np.median([p["z"] for p in pairs if not p["same_paper"]])),
                  "cross_beyond_null": int((cross > cut).sum()),
                  "same_beyond_null": int((same > cut).sum()),
                  "library_confound": {
                      "same_library_pairs": int(len(sl)), "diff_library_pairs": int(len(dl)),
                      "median_abs_r_same_library": float(np.median(sl)) if len(sl) else None,
                      "median_abs_r_diff_library": float(np.median(dl)) if len(dl) else None}},
        "params": {"min_shared": MIN_SHARED, "fitness_contrasts": [cids[j] for j in fit_cols],
                   "frequent_hitters_dropped": len(drop), "genes": len(proteins)},
    }
    np.save(f"{out}.npy", np.stack([r, n]))
    with open(out, "w") as fh:
        json.dump(result, fh, separators=(",", ":"), default=float)
    return result


if __name__ == "__main__":
    res = run(*sys.argv[1:4])
    print(json.dumps({k: res[k] for k in ("null", "check", "params")}, indent=2))
