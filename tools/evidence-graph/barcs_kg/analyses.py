"""Gap analyses over the evidence graph: what the screens support that nobody
has looked at, and what the graph cannot yet say.

    uv run python -m barcs_kg.analyses build/barcs_kg.sqlite reports

Writes one TSV per analysis plus summary.json. Definitions used throughout:

- hit: BARCS gene-level FDR < 0.10 (the threshold the reanalysis site reports).
- primary contrast: every contrast except sensitivity re-runs of the same
  comparison (median-ratio totals, library totals, unpaired, tech sorts...).
- gene identity: the STRING protein an element maps to unambiguously, so
  aliases and title-case human symbols collapse to one node. Elements that are
  near a gene, pair members or shared-paralog guides are not identity-mapped.
- independence: the publication (PMID). Several contrasts from one paper count once.
- eligible contrast: primary, >= 1,000 elements tested, and <= 10% of them called.
  Contrasts that call more (composition shifts, uncalibrated drug arms, candidate
  validation pools) would otherwise dominate every cross-screen count.
"""

import csv
import json
import random
import re
import sqlite3
import sys
from collections import Counter, defaultdict
from itertools import combinations
from pathlib import Path

import statistics

from scipy.stats import fisher_exact, hypergeom, poisson, spearmanr

HIT_FDR = 0.10
STRICT_FDR = 0.05
PHYS_HIGH = 700
FUNC_TOP = 900
SENSITIVITY = re.compile(r"median_?ratio|library_totals|_library$|unpaired|techsorts|noR1|mtc150", re.I)
ESSENTIAL_MIN_PAPERS = 3
PERMUTATIONS = 200
ELIGIBLE_MIN_TESTED = 1000
ELIGIBLE_MAX_HIT_FRACTION = 0.10


def bh(pvals):
    n = len(pvals)
    order = sorted(range(n), key=lambda i: pvals[i])
    q = [0.0] * n
    prev = 1.0
    for rank, i in reversed(list(enumerate(order, 1))):
        prev = min(prev, pvals[i] * n / rank)
        q[i] = prev
    return q


def write_tsv(path, header, rows):
    with open(path, "w", newline="") as fh:
        w = csv.writer(fh, delimiter="\t", lineterminator="\n")
        w.writerow(header)
        w.writerows(rows)


class Graph:
    def __init__(self, con):
        self.con = con
        self.contrast = {}
        for row in con.execute("""
            SELECT c.contrast_id, c.gse, s.pmid, sa.taxon, a.modality, a.selection_class,
                   c.residual_df, c.n_fdr10, c.control_guides, c.control_p05, c.top1pct_max,
                   c.genes, c.name, c.n_emp_fdr10
            FROM contrast c JOIN series s USING (gse) JOIN series_annotation sa USING (gse)
            JOIN contrast_annotation a USING (contrast_id) WHERE c.has_results = 1"""):
            d = dict(zip(("cid", "gse", "pmid", "taxon", "modality", "selection", "df",
                          "n_hits", "controls", "control_p05", "top1", "genes", "name",
                          "n_emp_hits"), row))
            d["primary"] = not SENSITIVITY.search(d["name"])
            d["hit_fraction"] = (d["n_hits"] or 0) / d["genes"] if d["genes"] else None
            d["eligible"] = (d["primary"] and (d["genes"] or 0) >= ELIGIBLE_MIN_TESTED
                             and d["hit_fraction"] <= ELIGIBLE_MAX_HIT_FRACTION)
            self.contrast[d["cid"]] = d
        self.name = dict(con.execute("SELECT string_id, preferred_name FROM string_protein"))
        # best-p element per protein per contrast
        self.res = defaultdict(dict)  # cid -> protein -> (estimate, p, fdr, element)
        for cid, sid, est, p, fdr, elem in con.execute("""
            SELECT r.contrast_id, gp.string_id, r.estimate, r.p_value, r.fdr, r.gene
            FROM result r JOIN contrast c USING (contrast_id)
            JOIN series_annotation sa USING (gse)
            JOIN element_gene eg ON eg.gse = c.gse AND eg.element_id = r.gene
                                 AND eg.relation IN ('is', 'promoter_of')
            JOIN gene_protein gp ON gp.taxon = sa.taxon AND gp.symbol = eg.symbol
            WHERE gp.string_id IS NOT NULL AND r.p_value IS NOT NULL
            ORDER BY r.contrast_id, r.p_value"""):
            if sid not in self.res[cid]:
                self.res[cid][sid] = (est, p, fdr, elem)
        self.adj_phys = defaultdict(dict)
        for a, b, s, exp, db in con.execute(
                "SELECT protein_a, protein_b, combined_score, experimental, database "
                "FROM string_physical WHERE combined_score >= ?", (PHYS_HIGH,)):
            self.adj_phys[a][b] = self.adj_phys[b][a] = (s, exp, db)
        self.adj_func = defaultdict(dict)
        for a, b, s in con.execute(
                "SELECT protein_a, protein_b, combined_score FROM string_functional "
                "WHERE combined_score >= ?", (FUNC_TOP,)):
            self.adj_func[a][b] = self.adj_func[b][a] = s

    def hits(self, cid, fdr=HIT_FDR):
        return {s: v for s, v in self.res[cid].items() if v[2] is not None and v[2] < fdr}

    def primaries(self, taxon=None, exclude=(), eligible=False):
        return [c for c in self.contrast.values() if c["primary"]
                and (not eligible or c["eligible"])
                and (taxon is None or c["taxon"] == taxon) and c["selection"] not in exclude
                and self.res.get(c["cid"])]


def claim_audit(g, out):
    """Every gene a paper named, scored against the BARCS contrast it was compared with."""
    rows = []
    claims = g.con.execute("""
        SELECT cl.compare_id, cl.gse, cl.contrast_id, cl.gene, sa.taxon
        FROM claim cl JOIN series_annotation sa USING (gse)""").fetchall()
    sym2prot = {(t, s.upper()): sid for t, s, sid in g.con.execute(
        "SELECT taxon, symbol, string_id FROM gene_protein WHERE string_id IS NOT NULL")}
    for compare_id, gse, cid, gene, taxon in claims:
        c = g.contrast.get(cid)
        direct = g.con.execute(
            "SELECT estimate, p_value, fdr, rank_p FROM result WHERE contrast_id = ? AND upper(gene) = upper(?)",
            (cid, gene)).fetchone()
        how = "symbol"
        if direct is None:
            sid = sym2prot.get((taxon, gene.upper()))
            hit = g.res[cid].get(sid) if sid else None
            if hit:
                direct = (hit[0], hit[1], hit[2], None)
                how = f"via STRING alias ({hit[3]})"
        if direct is None:
            status, est, p, fdr, rank = "not_tested", None, None, None, None
        else:
            est, p, fdr, rank = direct
            status = ("supported" if fdr is not None and fdr < HIT_FDR else
                      "borderline" if fdr is not None and fdr < 0.25 else "not_supported")
        rows.append((compare_id, cid, gene, status, how if direct else "", est, p, fdr, rank,
                     c["df"] if c else None, c["n_hits"] if c else None,
                     c["controls"] if c else None,
                     round(c["hit_fraction"], 3) if c and c["hit_fraction"] is not None else None))
    write_tsv(out / "claim_audit.tsv",
              ["compare_id", "contrast_id", "gene", "status", "matched", "estimate", "p_value",
               "fdr", "rank", "residual_df", "contrast_hits_fdr10", "control_guides",
               "contrast_hit_fraction"], rows)
    by_status = Counter(r[3] for r in rows)
    by_df = defaultdict(Counter)
    for r in rows:
        if r[3] != "not_tested":
            bucket = "df0" if r[9] == 0 else "df1" if r[9] == 1 else "df2+"
            by_df[bucket][r[3]] += 1
    null_screens = sum(1 for r in rows if r[3] == "not_supported" and r[10] == 0)
    flooded = sum(1 for r in rows if r[3] == "supported" and r[12] is not None and r[12] > 0.10)
    return {"claims": len(rows), "status": dict(by_status),
            "supported_in_contrasts_calling_over_10pct": flooded,
            "status_by_residual_df": {k: dict(v) for k, v in by_df.items()},
            "not_supported_in_contrasts_with_zero_hits": null_screens,
            "claims_without_direction": len(rows)}


def essential_reference(g, ceg_path=None):
    """Fitness prior: Hart CEGv2 core essentials plus proteins depleted in
    fitness/time-course contrasts of >= 3 independent BARCS papers. Mouse gets
    the human set through identical upper-cased STRING preferred names (a
    crude orthology; Mouse has no fitness contrasts of its own here)."""
    papers = defaultdict(lambda: defaultdict(set))  # taxon -> protein -> pmids
    tested = defaultdict(lambda: defaultdict(set))
    for c in g.primaries(exclude=()):
        if c["selection"] != "fitness_time" or c["modality"] not in ("KO", "CRISPRi", "KO+CRISPRi"):
            continue
        for sid, (est, p, fdr, _) in g.res[c["cid"]].items():
            tested[c["taxon"]][sid].add(c["pmid"])
            if fdr is not None and fdr < HIT_FDR and est < 0:
                papers[c["taxon"]][sid].add(c["pmid"])
    ess = defaultdict(set)
    for t, d in papers.items():
        ess[t] = {s for s, pm in d.items() if len(pm) >= ESSENTIAL_MIN_PAPERS}
    internal = len(ess[9606])
    ceg = 0
    if ceg_path and Path(ceg_path).exists():
        with open(ceg_path) as fh:
            next(fh)
            symbols = [line.split("\t")[0] for line in fh if line.strip()]
        lookup = {}
        for sym, sid in g.con.execute(
                "SELECT symbol, string_id FROM gene_protein WHERE taxon = 9606 AND string_id IS NOT NULL"):
            lookup[sym.upper()] = sid
        for sid, name in g.name.items():
            if sid.startswith("9606."):
                lookup.setdefault(name.upper(), sid)
        found = {lookup[x.upper()] for x in symbols if x.upper() in lookup}
        ceg = len(found)
        ess[9606] |= found
    human_names = {g.name[s].upper() for s in ess[9606]}
    ess[10090] |= {sid for sid, name in g.name.items()
                   if sid.startswith("10090.") and name.upper() in human_names}
    n_papers = {t: len({p for s in d.values() for p in s}) for t, d in tested.items()}
    n_papers["sources"] = {"internal_9606": internal, "cegv2_mapped": ceg}
    return dict(ess), n_papers


def fitness_confound(g, ess, out):
    """Do hits of non-fitness contrasts over-represent essential genes?"""
    rows = []
    for c in g.primaries(exclude=("fitness_time",)):
        e = ess.get(c["taxon"], set())
        if not e:
            continue
        uni = set(g.res[c["cid"]])
        hits = set(g.hits(c["cid"]))
        if len(hits) < 5:
            continue
        a = len(hits & e)
        b = len(hits - e)
        cc = len((uni - hits) & e)
        d = len((uni - hits) - e)
        if a + cc == 0:
            continue
        odds, p = fisher_exact([[a, b], [cc, d]], alternative="greater")
        rows.append([c["cid"], c["selection"], c["modality"], len(uni), len(hits), a,
                     round(a / len(hits), 3), round((a + cc) / len(uni), 3),
                     round(odds, 2) if odds != float("inf") else "inf", p])
    q = bh([r[-1] for r in rows])
    for r, qq in zip(rows, q):
        r.append(qq)
    rows.sort(key=lambda r: r[-1])
    write_tsv(out / "fitness_confound.tsv",
              ["contrast_id", "selection", "modality", "universe", "hits", "essential_hits",
               "essential_share_hits", "essential_share_universe", "odds_ratio", "p", "q"], rows)
    flagged = [r for r in rows if r[-1] < 0.05 and r[6] >= 0.25]
    return {"contrasts_tested": len(rows),
            "flagged_q05_and_25pct_hits_essential": len(flagged),
            "flagged_examples": [r[0] for r in flagged[:15]]}


def fitness_correlation(g, out):
    """Rank correlation of each eligible human contrast with a per-gene fitness
    score: the mean SD-scaled estimate over genome-wide human KO fitness contrasts."""
    fit = defaultdict(list)
    for c in g.primaries(taxon=9606):
        if c["selection"] != "fitness_time" or c["modality"] != "KO" or (c["genes"] or 0) < 15000:
            continue
        sd = statistics.pstdev(v[0] for v in g.res[c["cid"]].values())
        for s, v in g.res[c["cid"]].items():
            fit[s].append(v[0] / sd)
    score = {s: sum(v) / len(v) for s, v in fit.items() if len(v) >= 2}
    rows = []
    for c in g.primaries(taxon=9606, exclude=("fitness_time",), eligible=True):
        pairs = [(v[0], score[s]) for s, v in g.res[c["cid"]].items() if s in score]
        if len(pairs) < 500:
            continue
        rho = spearmanr([a for a, _ in pairs], [b for _, b in pairs]).statistic
        rows.append([c["cid"], c["selection"], len(pairs), round(rho, 3)])
    rows.sort(key=lambda r: -abs(r[3]))
    write_tsv(out / "fitness_correlation.tsv", ["contrast_id", "selection", "genes", "spearman_rho"], rows)
    return {"contrasts": len(rows), "abs_rho_over_0.1": int(sum(abs(r[3]) > 0.1 for r in rows)),
            "abs_rho_over_0.2": int(sum(abs(r[3]) > 0.2 for r in rows)),
            "median_abs_rho": round(statistics.median(abs(r[3]) for r in rows), 3) if rows else None,
            "top": rows[:5]}


def recurrence(g, ess, out):
    """Hit recurrence across independent papers, with tested denominators."""
    summary = {}
    rows = []
    for taxon in (9606, 10090):
        tested = defaultdict(set)
        hit = defaultdict(set)
        classes = defaultdict(set)
        signs = defaultdict(list)
        paper_uni, paper_hits = defaultdict(set), defaultdict(set)
        for c in g.primaries(taxon=taxon, exclude=("fitness_time",), eligible=True):
            h = g.hits(c["cid"])
            paper_uni[c["pmid"]] |= set(g.res[c["cid"]])
            paper_hits[c["pmid"]] |= set(h)
            for sid in g.res[c["cid"]]:
                tested[sid].add(c["pmid"])
            for sid, v in h.items():
                hit[sid].add(c["pmid"])
                classes[sid].add(c["selection"])
                signs[sid].append(1 if v[0] > 0 else -1)
        rate = {p: len(paper_hits[p]) / len(paper_uni[p]) for p in paper_uni}
        start = len(rows)
        for sid, pm in hit.items():
            if len(pm) < 3:
                continue
            nt = len(tested[sid])
            lam = sum(rate[p] for p in tested[sid])
            rows.append([taxon, g.name.get(sid, sid), sid, nt, len(pm), round(lam, 2),
                         poisson.sf(len(pm) - 1, lam),
                         len(classes[sid]), ",".join(sorted(classes[sid])),
                         sum(1 for s in signs[sid] if s > 0), sum(1 for s in signs[sid] if s < 0),
                         int(sid in ess.get(taxon, set()))])
        # BH over every protein tested in >= 1 paper, not just the >= 3-paper rows
        m = len(tested)
        block = rows[start:]
        order = sorted(range(len(block)), key=lambda i: block[i][6])
        prev = 1.0
        qs = [1.0] * len(block)
        for rank in range(len(block), 0, -1):
            i = order[rank - 1]
            prev = min(prev, block[i][6] * m / rank)
            qs[i] = prev
        for r, q in zip(block, qs):
            r.insert(7, q)
        n_papers = len({c["pmid"] for c in g.primaries(taxon=taxon, exclude=("fitness_time",),
                                                       eligible=True)})
        summary[taxon] = {"papers": n_papers,
                          "proteins_hit_in_3plus_papers": sum(1 for r in rows if r[0] == taxon),
                          "beyond_paper_hit_rates_q05": sum(1 for r in rows if r[0] == taxon and r[7] < 0.05)}
    rows.sort(key=lambda r: r[6])
    write_tsv(out / "recurrence.tsv",
              ["taxon", "gene", "string_id", "papers_tested", "papers_hit", "papers_expected",
               "p_poisson", "q", "n_selection_classes", "selection_classes", "contrasts_up",
               "contrasts_down", "fitness_prior"], rows)
    return summary, rows


def convergence(g, ess, frequent, out):
    """Pairs of contrasts from different papers whose hit sets overlap beyond chance.

    The universe is the intersection of the two tested sets. Internal essentials
    and frequent hitters are removed first so that shared fitness biology does
    not masquerade as shared phenotype biology.
    """
    rows = []
    for taxon in (9606, 10090):
        drop = ess.get(taxon, set()) | frequent.get(taxon, set())
        cs = g.primaries(taxon=taxon, exclude=("fitness_time",), eligible=True)
        hits = {c["cid"]: set(g.hits(c["cid"])) - drop for c in cs}
        uni = {c["cid"]: set(g.res[c["cid"]]) - drop for c in cs}
        for c1, c2 in combinations(cs, 2):
            if c1["pmid"] == c2["pmid"]:
                continue
            u = uni[c1["cid"]] & uni[c2["cid"]]
            if len(u) < 200:
                continue
            a = hits[c1["cid"]] & u
            b = hits[c2["cid"]] & u
            if len(a) < 3 or len(b) < 3:
                continue
            k = a & b
            if len(k) < 2:
                continue
            p = hypergeom.sf(len(k) - 1, len(u), len(a), len(b))
            concord = sum(1 for s in k if (g.res[c1["cid"]][s][0] > 0) == (g.res[c2["cid"]][s][0] > 0))
            rows.append([taxon, c1["cid"], c1["selection"], c2["cid"], c2["selection"], len(u),
                         len(a), len(b), len(k), round(len(k) / (len(a) * len(b) / len(u)), 2),
                         concord, p, ";".join(sorted(g.name.get(s, s) for s in k)[:40])])
    q = bh([r[11] for r in rows])
    for r, qq in zip(rows, q):
        r.insert(12, qq)
    rows.sort(key=lambda r: r[11])
    write_tsv(out / "convergence.tsv",
              ["taxon", "contrast_a", "selection_a", "contrast_b", "selection_b", "shared_universe",
               "hits_a", "hits_b", "shared_hits", "fold_enrichment", "same_sign", "p", "q",
               "shared_genes"], rows)
    sig = [r for r in rows if r[12] < 0.05]
    return {"pairs_tested": len(rows), "pairs_q05": len(sig),
            "cross_selection_class_pairs_q05": sum(1 for r in sig if r[2] != r[4])}


def coherence(g, ess, out, seed=7):
    """Are a contrast's hits more connected in STRING (physical >= 700) than
    random sets drawn from its own tested universe, matched on degree?"""
    rng = random.Random(seed)
    rows, modules = [], []
    for c in g.primaries():
        if c["taxon"] not in (9606, 10090):
            continue
        uni = list(g.res[c["cid"]])
        hits = sorted(g.hits(c["cid"]).items(), key=lambda kv: kv[1][1])[:300]
        hs = [s for s, _ in hits]
        if len(hs) < 5:
            continue
        deg = {s: len(g.adj_phys.get(s, ())) for s in uni}
        bins = defaultdict(list)
        for s in uni:
            bins[min(deg[s].bit_length(), 10)].append(s)

        def edges(nodes):
            ns = set(nodes)
            return sum(1 for s in ns for t in g.adj_phys.get(s, ()) if t in ns) // 2

        def test(nodes):
            obs = edges(nodes)
            null = []
            for _ in range(PERMUTATIONS):
                draw = set()
                for s in nodes:
                    draw.add(rng.choice(bins[min(deg[s].bit_length(), 10)]))
                null.append(edges(draw))
            mu = sum(null) / len(null)
            sd = (sum((x - mu) ** 2 for x in null) / len(null)) ** 0.5 or 1.0
            return obs, mu, (obs - mu) / sd, (1 + sum(1 for x in null if x >= obs)) / (1 + len(null))

        obs, mu, z, p = test(hs)
        ne = [s for s in hs if s not in ess.get(c["taxon"], set())]
        z_ne = round(test(ne)[2], 2) if len(ne) >= 5 and c["selection"] != "fitness_time" else None
        rows.append([c["cid"], c["selection"], c["modality"], int(c["eligible"]), len(hs), obs,
                     round(mu, 1), round(z, 2), z_ne, p])
        # connected components among hits
        hset, seen = set(hs), set()
        for s in hs:
            if s in seen:
                continue
            comp, stack = set(), [s]
            while stack:
                x = stack.pop()
                if x in comp:
                    continue
                comp.add(x)
                stack.extend(t for t in g.adj_phys.get(x, ()) if t in hset and t not in comp)
            seen |= comp
            if len(comp) >= 3:
                modules.append((c["cid"], comp))
    q = bh([r[-1] for r in rows])
    for r, qq in zip(rows, q):
        r.append(qq)
    rows.sort(key=lambda r: -r[7])
    write_tsv(out / "network_coherence.tsv",
              ["contrast_id", "selection", "modality", "eligible", "hits_tested", "edges_observed",
               "edges_expected", "z", "z_without_internal_essentials", "p_perm", "q"], rows)
    return rows, modules


def unreported(g, modules, ess, frequent, out):
    """Strong BARCS hits the paper did not name, and how they connect to what it did name."""
    named = defaultdict(set)
    for cid, gene, taxon in g.con.execute(
            "SELECT cl.contrast_id, cl.gene, sa.taxon FROM claim cl JOIN series_annotation sa USING (gse)"):
        named[cid].add(gene.upper())
    sym2prot = defaultdict(set)
    for t, s, sid in g.con.execute(
            "SELECT taxon, symbol, string_id FROM gene_protein WHERE string_id IS NOT NULL"):
        sym2prot[(t, s.upper())].add(sid)
    module_of = {}
    for cid, comp in modules:
        for s in comp:
            module_of[(cid, s)] = comp
    rows = []
    per_contrast = Counter()
    for cid in named:
        c = g.contrast.get(cid)
        if not c:
            continue
        named_prot = set()
        for gname in named[cid]:
            named_prot |= sym2prot.get((c["taxon"], gname), set())
        strict = sorted(g.hits(cid, STRICT_FDR).items(), key=lambda kv: kv[1][1])
        for rank, (sid, (est, p, fdr, elem)) in enumerate(strict, 1):
            if sid in named_prot or elem.upper() in named[cid]:
                continue
            per_contrast[cid] += 1
            phys = [(g.name.get(t, t), v[0], v[1], v[2]) for t, v in g.adj_phys.get(sid, {}).items()
                    if t in named_prot]
            func = [(g.name.get(t, t), v) for t, v in g.adj_func.get(sid, {}).items()
                    if t in named_prot and t not in {x for x in g.adj_phys.get(sid, {})}]
            comp = module_of.get((cid, sid))
            is_ess = sid in ess.get(c["taxon"], set()) and c["selection"] != "fitness_time"
            is_freq = sid in frequent.get(c["taxon"], set())
            evidenced = any(e or d for _, _, e, d in phys) or bool(func)
            priority = int(c["eligible"] and rank <= 25 and not is_ess and not is_freq
                           and (evidenced or (comp is not None and len(comp) >= 3)))
            rows.append([cid, c["selection"], int(c["eligible"]), elem, g.name.get(sid, sid), rank,
                         int(is_ess), int(is_freq), priority, est, p, fdr,
                         ";".join(f"{n}({s},exp{e},db{d})" for n, s, e, d in phys),
                         ";".join(f"{n}({s})" for n, s in func),
                         len(comp) if comp else 0,
                         ";".join(sorted(g.name.get(x, x) for x in comp))[:300] if comp else ""])
    write_tsv(out / "unreported_hits.tsv",
              ["contrast_id", "selection", "contrast_eligible", "element", "gene",
               "rank_among_strict_hits", "internal_essential", "frequent_hitter", "priority",
               "estimate", "p_value", "fdr", "physical_links_to_named(score,exp,db)",
               "functional900_links_to_named", "hit_module_size", "hit_module_members"], rows)
    pri = [r for r in rows if r[8]]
    write_tsv(out / "priority_unreported.tsv",
              ["contrast_id", "selection", "contrast_eligible", "element", "gene",
               "rank_among_strict_hits", "internal_essential", "frequent_hitter", "priority",
               "estimate", "p_value", "fdr", "physical_links_to_named(score,exp,db)",
               "functional900_links_to_named", "hit_module_size", "hit_module_members"], pri)
    elig = [r for r in rows if r[2]]
    return {"contrasts_with_named_genes": len(named),
            "unreported_strict_hits": len(rows),
            "unreported_strict_hits_in_eligible_contrasts": len(elig),
            "unreported_top10_in_eligible_contrasts": sum(1 for r in elig if r[5] <= 10),
            "priority_leads": len(pri),
            "priority_contrasts": len({r[0] for r in pri})}


def data_gaps(g, out):
    con = g.con
    rows = []
    for c in g.contrast.values():
        flags = []
        if c["df"] == 0:
            flags.append("no_residual_df")
        elif c["df"] == 1:
            flags.append("one_residual_df")
        if not c["controls"]:
            flags.append("no_control_guides")
        if c["control_p05"] is not None and c["control_p05"] > 0.075:
            flags.append("controls_inflated")
        if c["top1"] is not None and c["top1"] > 0.25:
            flags.append("composition_skew")
        if c["n_hits"] == 0:
            flags.append("no_hits_fdr10")
        if c["hit_fraction"] and c["hit_fraction"] > 0.10:
            flags.append("calls_over_10pct")
        if not g.res.get(c["cid"]):
            flags.append("no_protein_mapping")
        rows.append([c["cid"], c["taxon"], c["modality"], c["selection"], c["df"], c["controls"],
                     c["n_hits"], len(g.res.get(c["cid"], {})), c["genes"], ",".join(flags)])
    write_tsv(out / "contrast_flags.tsv",
              ["contrast_id", "taxon", "modality", "selection", "residual_df", "control_guides",
               "hits_fdr10", "proteins_mapped", "elements_tested", "flags"], rows)
    flag_counts = Counter(f for r in rows for f in r[-1].split(",") if f)
    elem = dict(con.execute("SELECT element_type, count(*) FROM element GROUP BY 1"))
    unmapped = con.execute("""SELECT count(*) FROM gene_protein WHERE string_id IS NULL
                              AND symbol NOT LIKE 'ENSG%'""").fetchone()[0]
    published = con.execute("SELECT count(*) FROM comparison WHERE published IS NOT NULL").fetchone()[0]
    no_string = [r[0] for r in con.execute(
        "SELECT organism FROM series_annotation WHERE taxon NOT IN (SELECT DISTINCT taxon FROM string_protein) GROUP BY 1")]
    return {"contrasts": len(rows), "flags": dict(flag_counts), "element_types": elem,
            "unmapped_symbols_excluding_ensembl_lncRNA": unmapped,
            "comparisons_with_paper_full_table_not_in_graph": published,
            "organisms_without_string_join": no_string}


def run(db, outdir):
    out = Path(outdir)
    out.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(db)
    g = Graph(con)
    summary = {"inventory": {
        t: con.execute(f"SELECT count(*) FROM {t}").fetchone()[0]
        for t in ("publication", "series", "contrast", "result", "claim", "string_physical",
                  "string_functional", "string_regulatory")}}
    summary["inventory"]["hits_fdr10"] = con.execute(
        "SELECT count(*) FROM result WHERE fdr < 0.1").fetchone()[0]
    flooded = [c for c in g.contrast.values() if c["hit_fraction"] and c["hit_fraction"] > 0.10]
    summary["hit_load"] = {
        "contrasts_calling_over_10pct": len(flooded),
        "their_share_of_all_hits": round(sum(c["n_hits"] for c in flooded)
                                         / max(1, sum(c["n_hits"] or 0 for c in g.contrast.values())), 3),
        "eligible_contrasts": sum(1 for c in g.contrast.values() if c["eligible"])}
    summary["claims"] = claim_audit(g, out)
    ess, ess_papers = essential_reference(g, Path(db).parent / "reference" / "CEGv2.txt")
    summary["essential_reference"] = {t: {"proteins": len(s), "fitness_papers": ess_papers.get(t)}
                                      for t, s in ess.items()}
    summary["essential_reference"]["sources"] = ess_papers["sources"]
    summary["fitness_confound"] = fitness_confound(g, ess, out)
    summary["fitness_correlation"] = fitness_correlation(g, out)
    rec_summary, rec = recurrence(g, ess, out)
    summary["recurrence"] = rec_summary
    frequent = defaultdict(set)
    for r in rec:
        if r[7] < 0.05 and r[8] >= 3:
            frequent[r[0]].add(r[2])
    # Mouse has too few eligible papers to call its own; borrow human by name.
    human_names = {g.name[x].upper() for x in frequent[9606]}
    frequent[10090] |= {sid for sid, name in g.name.items()
                        if sid.startswith("10090.") and name.upper() in human_names}
    summary["frequent_hitters"] = {t: len(s) for t, s in frequent.items()}
    summary["convergence"] = convergence(g, ess, frequent, out)
    coh, modules = coherence(g, ess, out)
    summary["coherence"] = {"contrasts_tested": len(coh),
                            "q05": sum(1 for r in coh if r[-1] < 0.05),
                            "eligible_nonfitness_z_without_essentials_above_3":
                                sum(1 for r in coh if r[3] and r[8] is not None and r[8] > 3),
                            "eligible_nonfitness_tested": sum(1 for r in coh if r[3] and r[8] is not None),
                            "modules_3plus": len(modules)}
    summary["unreported"] = unreported(g, modules, ess, frequent, out)
    summary["data_gaps"] = data_gaps(g, out)
    (out / "summary.json").write_text(json.dumps(summary, indent=2, default=str))
    return summary


if __name__ == "__main__":
    print(json.dumps(run(sys.argv[1], sys.argv[2]), indent=2, default=str))
