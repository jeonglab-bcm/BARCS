"""Load gene ontology and pathway annotations for STRING proteins.

    uv run python -m barcs_kg.ontology build/barcs_kg.sqlite build/string_v12.5 build/go build/reactome

1. Terms. Reads STRING's per-protein annotation file for each organism in the
   graph, <taxon>.protein.enrichment.terms.v12.5.txt.gz, so the terms share the
   graph's STRING protein ids and need no second identifier mapping. Keeps Gene
   Ontology (biological process, molecular function, cellular component),
   Reactome, WikiPathways and the MSigDB Hallmark sets. STRING v12.5 ships no
   KEGG. Leaves out STRING's own network clusters (derived from the same links
   the graph already holds, so they would explain an edge with itself),
   keywords, domains, localization, tissue, phenotype, disease and GWAS.

   GO and Reactome terms in this file are already propagated to their
   ancestors (GO:0009987 "cellular process" covers 15,275 human proteins), so a
   shared broad term is common and only small terms are informative.

2. Hierarchy (optional third argument, a folder with go-basic.obo; fourth, a
   folder with ReactomePathwaysRelation.txt). Stores every parent link and the
   ancestor closure, so a query can keep the most specific of several shared
   terms and drop their ancestors.

3. GO evidence (the third argument's folder also holds <ORG>-uniprot.gaf.gz).
   STRING's file says nothing about how a protein got a GO term. A term that
   came from a CRISPR screen cannot be used to explain a screen hit, so every
   STRING (protein, GO term) pair is matched to the GO release's annotations,
   propagated over is_a and part_of, and records which evidence supports it.
   `independent` = at least one annotation that is neither high-throughput
   (HTP, HDA, HMP, HGI, HEP) nor electronic (IEA) and does not cite a paper in
   the BARCS corpus. NOT annotations and ND are ignored.

Tables:

  term               (taxon, term_id) -> source, name, n_proteins (annotated
                     proteins in that organism), n_tested (of those, tested in
                     at least one BARCS contrast). Small n_proteins = specific.
  gene_term          string_id -> term_id, every STRING protein (not only tested
                     ones), so a bridging gene b need not have been screened.
  term_parent        term_id -> parent_id with the relation (GO: is_a, part_of,
                     regulates, positively_/negatively_regulates; Reactome:
                     part_of).
  term_ancestor      closure over is_a and part_of (GO) and part_of (Reactome).
  gene_term_evidence for STRING GO pairs that the GO release supports: best
                     evidence class, codes, number of references, corpus PMIDs
                     cited, independent (0/1). A STRING GO pair with no row here
                     has no support in this GO release (release drift).

Limits: the corpus check catches annotations citing the reanalyzed papers, not
screens published elsewhere and curated as IMP. Reactome, WikiPathways and
Hallmark sets carry no evidence codes.
"""

import gzip
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

VERSION = "12.5"
GO_RELEASE = "2026-08-05"
REACTOME_RELEASE = "98"
SOURCES = {
    "Biological Process (Gene Ontology)": "GO:BP",
    "Molecular Function (Gene Ontology)": "GO:MF",
    "Cellular Component (Gene Ontology)": "GO:CC",
    "Reactome Pathways": "Reactome",
    "WikiPathways": "WikiPathways",
    "Hallmark Gene Set (Molecular Signatures DB)": "MSigDB Hallmark",
}
GAF = {9606: "HUMAN", 10090: "MOUSE", 10116: "RAT", 9913: "BOVIN"}
REACTOME_SPECIES = {"HSA": 9606, "MMU": 10090, "RNO": 10116, "BTA": 9913}
PROPAGATE = {"is_a", "part_of"}
EVIDENCE = {}
for _cls, _codes in {
    "experimental": "EXP IDA IPI IMP IGI IEP",
    "curated": "TAS NAS IC",
    "computational": "IBA IBD IKR IRD ISS ISO ISA ISM IGC RCA",
    "high_throughput": "HTP HDA HMP HGI HEP",
    "electronic": "IEA",
}.items():
    for _c in _codes.split():
        EVIDENCE[_c] = _cls
CLASS_ORDER = ["experimental", "curated", "computational", "high_throughput", "electronic"]
NOT_INDEPENDENT = {"high_throughput", "electronic"}


def load_taxon(con, path, taxon, tested):
    members, names = defaultdict(set), {}
    skipped = defaultdict(int)
    with gzip.open(path, "rt", encoding="utf-8") as fh:
        next(fh)
        for line in fh:
            sid, category, term_id, desc = line.rstrip("\n").split("\t")
            source = SOURCES.get(category)
            if source is None:
                skipped[category] += 1
                continue
            members[term_id].add(sid)
            names[term_id] = (source, desc)
    con.executemany("INSERT INTO term VALUES (?,?,?,?,?,?)",
                    [(taxon, t, names[t][0], names[t][1], len(m), len(m & tested))
                     for t, m in members.items()])
    rows = [(sid, t) for t, m in members.items() for sid in m]
    con.executemany("INSERT INTO gene_term VALUES (?,?)", rows)
    by_source = defaultdict(int)
    for t in members:
        by_source[names[t][0]] += 1
    return len(rows), dict(by_source), dict(skipped)


def parse_obo(path):
    """Parent links (child, parent, relation) and alt_id -> primary id."""
    links, alt = [], {}
    term, in_term = None, False
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if line.startswith("["):
                in_term = line == "[Term]"
                term = None
                continue
            if not in_term or ": " not in line:
                continue
            key, value = line.split(": ", 1)
            value = value.split(" ! ")[0].strip()
            if key == "id":
                term = value
            elif key == "alt_id":
                alt[value] = term
            elif key == "is_a":
                links.append((term, value.split()[0], "is_a"))
            elif key == "relationship":
                rel, parent = value.split()[:2]
                links.append((term, parent, rel))
    return links, alt


def parse_reactome(path):
    """Reactome pathway parent links, ids written as STRING writes them (HSA-123)."""
    links = []
    with open(path) as fh:
        for line in fh:
            parent, child = line.split()
            if parent[2:5] in REACTOME_SPECIES:
                links.append((child[2:], parent[2:], "part_of"))
    return links


def closure(links):
    parents = defaultdict(set)
    for child, parent, rel in links:
        if rel in PROPAGATE:
            parents[child].add(parent)
    memo = {}

    def up(t):
        if t not in memo:
            memo[t] = set()  # guards against cycles
            acc = set()
            for p in parents.get(t, ()):
                acc.add(p)
                acc |= up(p)
            memo[t] = acc
        return memo[t]

    for t in list(parents):
        up(t)
    return memo


def load_evidence(con, gaf, alias_path, taxon, alt, ancestors, corpus):
    acc2sid = defaultdict(set)
    with gzip.open(alias_path, "rt", encoding="utf-8") as fh:
        next(fh)
        for line in fh:
            sid, alias, source = line.rstrip("\n").split("\t")
            if source in ("UniProt_AC", "Ensembl_UniProt"):
                acc2sid[alias].add(sid)
    string_go = defaultdict(set)
    for sid, t in con.execute("""
            SELECT gt.string_id, gt.term_id FROM gene_term gt
            JOIN term t ON t.term_id = gt.term_id AND t.taxon = ?
            WHERE t.source LIKE 'GO:%' AND gt.string_id LIKE ?""", (taxon, f"{taxon}.%")):
        string_go[sid].add(t)

    support = defaultdict(set)  # (sid, term) -> {(code, ref)}
    unmapped, used = set(), 0
    with gzip.open(gaf, "rt", encoding="utf-8") as fh:
        for line in fh:
            if line.startswith("!"):
                continue
            f = line.rstrip("\n").split("\t")
            if f[0] != "UniProtKB" or "NOT" in f[3].split("|") or f[6] not in EVIDENCE:
                continue
            sids = acc2sid.get(f[1])
            if not sids:
                unmapped.add(f[1])
                continue
            used += 1
            term = alt.get(f[4], f[4])
            refs = f[5].split("|")
            for sid in sids:
                have = string_go.get(sid)
                if not have:
                    continue
                for t in (term, *ancestors.get(term, ())):
                    if t in have:
                        for r in refs:
                            support[(sid, t)].add((f[6], r))

    rows = []
    for (sid, t), ev in support.items():
        classes = {EVIDENCE[c] for c, _ in ev}
        best = next(c for c in CLASS_ORDER if c in classes)
        corpus_refs = sorted({r for _, r in ev if r in corpus})
        independent = any(EVIDENCE[c] not in NOT_INDEPENDENT and r not in corpus for c, r in ev)
        rows.append((sid, t, best, ",".join(sorted({c for c, _ in ev})),
                     len({r for _, r in ev}), ",".join(corpus_refs), int(independent)))
    con.executemany("INSERT INTO gene_term_evidence VALUES (?,?,?,?,?,?,?)", rows)
    n_pairs = sum(len(v) for v in string_go.values())
    return {"annotations_used": used, "unmapped_accessions": len(unmapped),
            "string_go_pairs": n_pairs, "with_evidence": len(rows),
            "independent": sum(r[-1] for r in rows)}


def run(db, folder, go_dir=None, reactome_dir=None):
    folder = Path(folder)
    con = sqlite3.connect(db)
    con.executescript("""
    DROP TABLE IF EXISTS term; DROP TABLE IF EXISTS gene_term;
    DROP TABLE IF EXISTS term_parent; DROP TABLE IF EXISTS term_ancestor;
    DROP TABLE IF EXISTS gene_term_evidence;
    CREATE TABLE term (
      taxon INTEGER, term_id TEXT, source TEXT, name TEXT,
      n_proteins INTEGER, n_tested INTEGER, PRIMARY KEY (taxon, term_id));
    CREATE TABLE gene_term (string_id TEXT, term_id TEXT);
    CREATE TABLE term_parent (term_id TEXT, parent_id TEXT, relation TEXT);
    CREATE TABLE term_ancestor (term_id TEXT, ancestor_id TEXT);
    CREATE TABLE gene_term_evidence (
      string_id TEXT, term_id TEXT, best_class TEXT, codes TEXT, n_references INTEGER,
      corpus_pmids TEXT, independent INTEGER, PRIMARY KEY (string_id, term_id));
    """)
    con.execute("INSERT OR REPLACE INTO source VALUES ('ontology_sources', ?)",
                (f"STRING v{VERSION} protein.enrichment.terms: " + ", ".join(sorted(set(SOURCES.values()))),))
    taxa = [t for (t,) in con.execute(
        "SELECT DISTINCT taxon FROM series_annotation WHERE taxon IS NOT NULL")]
    for taxon in taxa:
        path = folder / f"{taxon}.protein.enrichment.terms.v{VERSION}.txt.gz"
        if not path.exists():
            print(f"taxon {taxon}: no {path.name}, skipped")
            continue
        tested = {s for (s,) in con.execute("""
            SELECT DISTINCT gp.string_id FROM gene_protein gp
            WHERE gp.taxon = ? AND gp.string_id IS NOT NULL""", (taxon,))}
        n, by_source, skipped = load_taxon(con, path, taxon, tested)
        print(f"taxon {taxon}: {n} annotations; terms {by_source}")
        print(f"  categories left out: {sorted(skipped)}")
    con.executescript("""
    CREATE INDEX gt_sid ON gene_term(string_id);
    CREATE INDEX gt_term ON gene_term(term_id);
    """)

    links, alt = [], {}
    if go_dir and (Path(go_dir) / "go-basic.obo").exists():
        go_links, alt = parse_obo(Path(go_dir) / "go-basic.obo")
        links += go_links
        con.execute("INSERT OR REPLACE INTO source VALUES ('go_release', ?)", (GO_RELEASE,))
    if reactome_dir and (Path(reactome_dir) / "ReactomePathwaysRelation.txt").exists():
        links += parse_reactome(Path(reactome_dir) / "ReactomePathwaysRelation.txt")
        con.execute("INSERT OR REPLACE INTO source VALUES ('reactome_release', ?)", (REACTOME_RELEASE,))
    if links:
        ancestors = closure(links)
        con.executemany("INSERT INTO term_parent VALUES (?,?,?)", links)
        con.executemany("INSERT INTO term_ancestor VALUES (?,?)",
                        [(t, a) for t, anc in ancestors.items() for a in anc])
        con.executescript("""
        CREATE INDEX tp_term ON term_parent(term_id); CREATE INDEX tp_parent ON term_parent(parent_id);
        CREATE INDEX ta_term ON term_ancestor(term_id); CREATE INDEX ta_anc ON term_ancestor(ancestor_id);
        """)
        print(f"hierarchy: {len(links)} parent links, {sum(map(len, ancestors.values()))} ancestor pairs")

        corpus = {f"PMID:{p}" for (p,) in con.execute("SELECT pmid FROM publication") if p}
        for taxon in taxa:
            gaf = Path(go_dir) / f"{GAF.get(taxon, '')}-uniprot.gaf.gz"
            aliases = folder / f"{taxon}.protein.aliases.v{VERSION}.txt.gz"
            if taxon not in GAF or not gaf.exists() or not aliases.exists():
                continue
            print(f"taxon {taxon} GO evidence: "
                  f"{load_evidence(con, gaf, aliases, taxon, alt, ancestors, corpus)}")
        con.execute("CREATE INDEX gte_term ON gene_term_evidence(term_id)")
    con.commit()
    return con


if __name__ == "__main__":
    run(*sys.argv[1:5])
