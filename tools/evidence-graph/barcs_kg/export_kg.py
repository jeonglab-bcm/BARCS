"""Export the BARCS findings as a typed knowledge graph for link prediction.

Writes, under <outdir>/:
  nodes.tsv              id, type, label, attrs(json)
  triples.tsv           head, relation, tail            (the whole graph)
  train.tsv/valid.tsv/test.tsv                          time-based split
  stats.json            counts

Node types:  gene, screen, condition, paper
Relations:
  <modality>_enriched / <modality>_depleted   gene  -> screen   (a called hit; sign
      = guides more/less abundant in the contrast's positive level; FDR < HIT_FDR)
  produces_phenotype / opposes_phenotype       gene  -> condition (curated 80 screens
      only, sign harmonised to the paper's phenotype of interest)
  interacts_with                               gene  -> gene     (STRING physical >= 700)
  measures                                     screen-> condition
  reported_in                                  screen-> paper

The split holds out the perturbation edges of the most recently published papers:
test = latest ~20% of papers by date, valid = next ~10%, train = the rest plus every
background edge (interactions, measures, reported_in). This mirrors "train on the
past, predict edges added later".
"""
import json
import re
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

from barcs_kg.analyses import HIT_FDR, PHYS_HIGH

TEST_FRAC, VALID_FRAC = 0.20, 0.10


def slug(s):
    return re.sub(r"[^a-z0-9]+", "_", (s or "").lower()).strip("_") or "na"


def run(db, outdir):
    out = Path(outdir)
    out.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(db)

    taxon = dict(con.execute("SELECT gse, taxon FROM series_annotation"))
    cgse = dict(con.execute("SELECT contrast_id, gse FROM contrast"))
    pmid = dict(con.execute("SELECT gse, pmid FROM series"))
    pdate = dict(con.execute(
        "SELECT pmid, published_date FROM publication WHERE published_date != ''"))
    ann = {r[0]: r[1:] for r in con.execute(
        """SELECT contrast_id, modality, readout, interest
           FROM contrast_annotation""")}

    def gene_id(sym, gse):
        return f"gene:{sym}|{taxon.get(gse, 0)}"

    nodes = {}  # id -> (type, label, attrs)

    def add(nid, ntype, label, **attrs):
        if nid not in nodes:
            nodes[nid] = (ntype, label, attrs)

    triples = []       # (head, relation, tail, pmid_or_None)
    gene_syms = set()  # (symbol, gse) seen, to filter STRING later

    # --- perturbation edges: gene -> screen, and curated gene -> condition ---
    for cid, sym, est, fdr in con.execute(
            "SELECT contrast_id, gene, estimate, fdr FROM result WHERE fdr < ?",
            (HIT_FDR,)):
        if est is None:
            continue
        gse = cgse.get(cid)
        gid = gene_id(sym, gse)
        sid = f"screen:{cid}"
        add(gid, "gene", sym, taxon=taxon.get(gse, 0))
        add(sid, "screen", cid)
        gene_syms.add((sym, gse))
        mod = slug((ann.get(cid) or [None])[0] or "unknown")
        direction = "enriched" if est > 0 else "depleted"
        p = pmid.get(gse)
        triples.append((gid, f"{mod}_{direction}", sid, p))
        # curated condition layer: harmonise sign to the phenotype of interest
        if cid in ann and ann[cid][1] and ann[cid][2] in ("+", "-"):
            _, readout, interest = ann[cid]
            cond = f"condition:{slug(readout)}"
            add(cond, "condition", readout)
            sign = "+" if est > 0 else "-"
            rel = "produces_phenotype" if sign == interest else "opposes_phenotype"
            triples.append((gid, rel, cond, p))

    # --- screen -> condition, screen -> paper ---
    for cid, (mod, readout, interest) in ann.items():
        sid = f"screen:{cid}"
        if sid not in nodes:
            continue
        if readout:
            cond = f"condition:{slug(readout)}"
            add(cond, "condition", readout)
            triples.append((sid, "measures", cond, None))
        p = pmid.get(cgse.get(cid))
        if p:
            add(f"paper:{p}", "paper", p, date=pdate.get(p))
            triples.append((sid, "reported_in", f"paper:{p}", None))

    # --- gene -> gene physical interactions (STRING >= PHYS_HIGH) ---
    # map STRING ids to the gene symbols we actually have, per taxon
    sym_by_sid = defaultdict(list)
    for tax, sym, sid in con.execute(
            "SELECT taxon, symbol, string_id FROM gene_protein"):
        sym_by_sid[sid].append((tax, sym))
    kept_genes = {(s, taxon.get(g, 0)) for (s, g) in gene_syms}  # (symbol, taxon)
    n_int = 0
    seen_pairs = set()
    for a, b, score in con.execute(
            "SELECT protein_a, protein_b, combined_score FROM string_physical WHERE combined_score >= ?",
            (PHYS_HIGH,)):
        for ta, sa in sym_by_sid.get(a, ()):
            for tb, sb in sym_by_sid.get(b, ()):
                if ta != tb:
                    continue
                if (sa, ta) not in kept_genes or (sb, tb) not in kept_genes:
                    continue
                ga, gb = f"gene:{sa}|{ta}", f"gene:{sb}|{tb}"
                key = tuple(sorted((ga, gb)))
                if key in seen_pairs or ga == gb:
                    continue
                seen_pairs.add(key)
                triples.append((ga, "interacts_with", gb, None))
                n_int += 1

    # --- time split on the perturbation edges by paper date ---
    dated = sorted({p: pdate[p] for p in pdate}.items(), key=lambda kv: kv[1])
    papers_by_date = [p for p, _ in dated]
    n = len(papers_by_date)
    test_papers = set(papers_by_date[int(n * (1 - TEST_FRAC)):])
    valid_papers = set(papers_by_date[int(n * (1 - TEST_FRAC - VALID_FRAC)):
                                      int(n * (1 - TEST_FRAC))])
    PERTURB = {"produces_phenotype", "opposes_phenotype"}
    split = {"train": [], "valid": [], "test": []}
    for h, r, t, p in triples:
        is_perturb = r.endswith(("_enriched", "_depleted")) or r in PERTURB
        if is_perturb and p in test_papers:
            split["test"].append((h, r, t))
        elif is_perturb and p in valid_papers:
            split["valid"].append((h, r, t))
        else:
            split["train"].append((h, r, t))

    # --- write ---
    with open(out / "nodes.tsv", "w") as fh:
        fh.write("id\ttype\tlabel\tattrs\n")
        for nid, (ntype, label, attrs) in sorted(nodes.items()):
            fh.write(f"{nid}\t{ntype}\t{label}\t{json.dumps(attrs, separators=(',', ':'))}\n")
    with open(out / "triples.tsv", "w") as fh:
        fh.write("head\trelation\ttail\n")
        for h, r, t, _ in triples:
            fh.write(f"{h}\t{r}\t{t}\n")
    for name, rows in split.items():
        with open(out / f"{name}.tsv", "w") as fh:
            for h, r, t in rows:
                fh.write(f"{h}\t{r}\t{t}\n")

    rel_counts = defaultdict(int)
    for _, r, _, _ in triples:
        rel_counts[r] += 1
    type_counts = defaultdict(int)
    for _, (ntype, _, _) in nodes.items():
        type_counts[ntype] += 1
    stats = {
        "nodes": len(nodes), "node_types": dict(sorted(type_counts.items())),
        "triples": len(triples), "relations": dict(sorted(rel_counts.items())),
        "interactions": n_int,
        "split": {k: len(v) for k, v in split.items()},
        "papers": {"total": n, "valid": len(valid_papers), "test": len(test_papers)},
        "test_cutoff": pdate[papers_by_date[int(n * (1 - TEST_FRAC))]] if n else None,
        "hit_fdr": HIT_FDR, "string_physical_min": PHYS_HIGH,
    }
    (out / "stats.json").write_text(json.dumps(stats, indent=2))
    print(json.dumps(stats, indent=2))
    return stats


if __name__ == "__main__":
    run(sys.argv[1], sys.argv[2])
