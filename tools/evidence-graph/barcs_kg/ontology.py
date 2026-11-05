"""Load gene ontology and pathway annotations for STRING proteins.

    uv run python -m barcs_kg.ontology build/barcs_kg.sqlite build/string_v12.5

Reads STRING's per-protein annotation file for each organism in the graph,
<taxon>.protein.enrichment.terms.v12.5.txt.gz, so the terms share the graph's
STRING protein ids and need no second identifier mapping. Keeps Gene Ontology
(biological process, molecular function, cellular component), Reactome,
WikiPathways and the MSigDB Hallmark sets. STRING v12.5 ships no KEGG. Leaves
out STRING's own network clusters (derived from the same links the graph
already holds, so they would explain an edge with itself), keywords, domains,
localization, tissue, phenotype, disease and GWAS categories.

GO terms in this file are already propagated to their ancestors (GO:0009987
"cellular process" covers 15,275 human proteins), so a shared broad term is
common and only small terms are informative; filter on n_proteins.

Tables:

  term       (taxon, term_id) -> source, name, n_proteins (annotated proteins in
             that organism), n_tested (of those, proteins tested in at least one
             BARCS contrast). A small n_proteins means a specific term.
  gene_term  string_id -> term_id, for every STRING protein (not only tested
             ones), so a bridging gene b need not have been screened.

Limits: STRING's file has no GO evidence codes, so annotations inferred from
high-throughput screens (HTP, HMP, HGI) or electronically (IEA) cannot be told
apart here. Claims that a link is new must check those against the GO
annotation files. The term hierarchy (is_a / part_of) is not loaded here; ancestors are
implied by propagation, but which term is a parent of which is not stored.
"""

import gzip
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

VERSION = "12.5"
SOURCES = {
    "Biological Process (Gene Ontology)": "GO:BP",
    "Molecular Function (Gene Ontology)": "GO:MF",
    "Cellular Component (Gene Ontology)": "GO:CC",
    "Reactome Pathways": "Reactome",
    "WikiPathways": "WikiPathways",
    "Hallmark Gene Set (Molecular Signatures DB)": "MSigDB Hallmark",
}


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


def run(db, folder):
    folder = Path(folder)
    con = sqlite3.connect(db)
    con.executescript("""
    DROP TABLE IF EXISTS term; DROP TABLE IF EXISTS gene_term;
    CREATE TABLE term (
      taxon INTEGER, term_id TEXT, source TEXT, name TEXT,
      n_proteins INTEGER, n_tested INTEGER, PRIMARY KEY (taxon, term_id));
    CREATE TABLE gene_term (string_id TEXT, term_id TEXT);
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
    con.commit()
    return con


if __name__ == "__main__":
    run(sys.argv[1], sys.argv[2])
