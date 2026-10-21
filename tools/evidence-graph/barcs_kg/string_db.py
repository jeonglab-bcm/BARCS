"""Join tested elements to STRING v12.5 proteins and load the three networks.

    uv run python -m barcs_kg.string_db build/barcs_kg.sqlite build/string_v12.5

Expects the per-organism bulk files from
https://stringdb-downloads.org/download/<file>.v12.5/<taxon>.<file>.v12.5.txt.gz
(protein.info, protein.aliases, protein.physical.links.detailed,
protein.links.detailed, protein.regulatory.links.detailed,
protein.regulatory.events). Scores are STRING confidences (0-1000), not effects.

Undirected networks are stored once per pair (protein_a < protein_b).
Regulatory links are directed (protein_a regulates protein_b) and keep their
positive/negative channels; regulatory events keep the mechanism columns.
"""

import gzip
import re
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path

VERSION = "12.5"
PHYSICAL_MIN = 400      # STRING "medium" confidence
FUNCTIONAL_MIN = 700    # "high"; the functional network is dense below this
REGULATORY_MIN = 400
SYMBOL_SOURCES = re.compile(
    r"symbol|GN_Name|HGNC|MGI|RGD|VGNC|EntrezGene|Ensembl_gene|BioMart_HUGO|external_synonym")


def opener(path):
    return gzip.open(path, "rt", encoding="utf-8")


def load_proteins(con, folder, taxon):
    rows = []
    with opener(folder / f"{taxon}.protein.info.v{VERSION}.txt.gz") as fh:
        next(fh)
        for line in fh:
            sid, name, size, annot = line.rstrip("\n").split("\t", 3)
            rows.append((sid, taxon, name, int(size), annot[:300]))
    con.executemany("INSERT OR REPLACE INTO string_protein VALUES (?,?,?,?,?)", rows)
    by_name = defaultdict(set)
    for sid, _, name, _, _ in rows:
        by_name[name].add(sid)
    return by_name


def load_aliases(folder, taxon, wanted):
    """alias -> set of STRING ids, only for aliases we need, symbol-like sources."""
    exact, folded = defaultdict(set), defaultdict(set)
    wanted_fold = {w.upper() for w in wanted}
    with opener(folder / f"{taxon}.protein.aliases.v{VERSION}.txt.gz") as fh:
        next(fh)
        for line in fh:
            sid, alias, source = line.rstrip("\n").split("\t")
            if not SYMBOL_SOURCES.search(source):
                continue
            if alias in wanted:
                exact[alias].add(sid)
            if alias.upper() in wanted_fold:
                folded[alias.upper()].add(sid)
    return exact, folded


def map_symbols(symbols, by_name, exact, folded):
    by_name_fold = defaultdict(set)
    for name, sids in by_name.items():
        by_name_fold[name.upper()] |= sids
    out = []
    for s in symbols:
        if len(by_name.get(s, ())) == 1:
            out.append((s, next(iter(by_name[s])), "preferred_name", 1))
        elif len(by_name_fold.get(s.upper(), ())) == 1:
            out.append((s, next(iter(by_name_fold[s.upper()])), "preferred_name_ci", 1))
        elif len(exact.get(s, ())) == 1:
            out.append((s, next(iter(exact[s])), "alias", 1))
        elif len(exact.get(s, ())) > 1:
            out.append((s, None, "ambiguous_alias", len(exact[s])))
        elif len(folded.get(s.upper(), ())) == 1:
            out.append((s, next(iter(folded[s.upper()])), "alias_ci", 1))
        elif len(folded.get(s.upper(), ())) > 1:
            out.append((s, None, "ambiguous_alias", len(folded[s.upper()])))
        else:
            out.append((s, None, "unmapped", 0))
    return out


def load_links(con, path, table, score_col, min_score, directed, ncols):
    if not path.exists():
        return 0
    batch, n = [], 0
    with opener(path) as fh:
        next(fh)
        for line in fh:
            f = line.split()
            if int(f[score_col]) < min_score:
                continue
            if not directed and f[0] > f[1]:
                continue
            batch.append(tuple(f[:2]) + tuple(int(x) for x in f[2:2 + ncols]))
            if len(batch) >= 200_000:
                con.executemany(f"INSERT INTO {table} VALUES ({','.join('?' * (2 + ncols))})", batch)
                n += len(batch)
                batch = []
    con.executemany(f"INSERT INTO {table} VALUES ({','.join('?' * (2 + ncols))})", batch)
    return n + len(batch)


def run(db, folder):
    folder = Path(folder)
    con = sqlite3.connect(db)
    con.executescript("""
    DROP TABLE IF EXISTS string_protein; DROP TABLE IF EXISTS gene_protein;
    DROP TABLE IF EXISTS string_physical; DROP TABLE IF EXISTS string_functional;
    DROP TABLE IF EXISTS string_regulatory; DROP TABLE IF EXISTS string_regulatory_event;
    CREATE TABLE string_protein (
      string_id TEXT PRIMARY KEY, taxon INTEGER, preferred_name TEXT,
      protein_size INTEGER, annotation TEXT);
    CREATE TABLE gene_protein (
      taxon INTEGER, symbol TEXT, string_id TEXT, match_type TEXT, n_candidates INTEGER,
      PRIMARY KEY (taxon, symbol));
    CREATE TABLE string_physical (
      protein_a TEXT, protein_b TEXT, experimental INTEGER, database INTEGER,
      textmining INTEGER, combined_score INTEGER);
    CREATE TABLE string_functional (
      protein_a TEXT, protein_b TEXT, neighborhood INTEGER, fusion INTEGER,
      cooccurence INTEGER, coexpression INTEGER, experimental INTEGER,
      database INTEGER, textmining INTEGER, combined_score INTEGER);
    CREATE TABLE string_regulatory (
      protein_a TEXT, protein_b TEXT, experimental INTEGER, database INTEGER,
      textmining INTEGER, positive INTEGER, negative INTEGER, combined_score INTEGER);
    CREATE TABLE string_regulatory_event (
      protein_a TEXT, protein_b TEXT, positive_regulation INTEGER,
      negative_regulation INTEGER, gene_expression INTEGER, degradation INTEGER,
      ptm INTEGER, phosphorylation INTEGER, dephosphorylation INTEGER,
      small_molecule_conjugation INTEGER, small_molecule_removal INTEGER,
      small_protein_conjugation INTEGER, small_protein_removal INTEGER);
    """)
    con.execute("INSERT OR REPLACE INTO source VALUES ('string_version', ?)", (VERSION,))
    con.execute("INSERT OR REPLACE INTO source VALUES ('string_thresholds', ?)",
                (f"physical>={PHYSICAL_MIN}; functional>={FUNCTIONAL_MIN}; regulatory>={REGULATORY_MIN}",))

    taxa = [t for (t,) in con.execute(
        "SELECT DISTINCT taxon FROM series_annotation WHERE taxon IS NOT NULL")]
    for taxon in taxa:
        if not (folder / f"{taxon}.protein.info.v{VERSION}.txt.gz").exists():
            print(f"taxon {taxon}: no STRING files in {folder}, skipped")
            continue
        symbols = {s for (s,) in con.execute("""
            SELECT DISTINCT eg.symbol FROM element_gene eg
            JOIN series_annotation sa USING (gse) WHERE sa.taxon = ?""", (taxon,))}
        by_name = load_proteins(con, folder, taxon)
        exact, folded = load_aliases(folder, taxon, symbols)
        mapped = map_symbols(sorted(symbols), by_name, exact, folded)
        con.executemany("INSERT INTO gene_protein VALUES (?,?,?,?,?)",
                        [(taxon,) + m for m in mapped])
        n_ok = sum(1 for m in mapped if m[1])
        counts = {
            "physical": load_links(con, folder / f"{taxon}.protein.physical.links.detailed.v{VERSION}.txt.gz",
                                   "string_physical", 5, PHYSICAL_MIN, False, 4),
            "functional": load_links(con, folder / f"{taxon}.protein.links.detailed.v{VERSION}.txt.gz",
                                     "string_functional", 9, FUNCTIONAL_MIN, False, 8),
            "regulatory": load_links(con, folder / f"{taxon}.protein.regulatory.links.detailed.v{VERSION}.txt.gz",
                                     "string_regulatory", 7, REGULATORY_MIN, True, 6),
        }
        ev = folder / f"{taxon}.protein.regulatory.events.v{VERSION}.txt.gz"
        if ev.exists():
            with opener(ev) as fh:
                next(fh)
                con.executemany("INSERT INTO string_regulatory_event VALUES (" + ",".join("?" * 13) + ")",
                                (tuple(f[:2]) + tuple(int(x) for x in f[2:13])
                                 for f in (line.rstrip("\n").split("\t") for line in fh)))
        print(f"taxon {taxon}: {n_ok}/{len(symbols)} symbols mapped; edges {counts}")
    con.executescript("""
    CREATE INDEX phys_a ON string_physical(protein_a); CREATE INDEX phys_b ON string_physical(protein_b);
    CREATE INDEX func_a ON string_functional(protein_a); CREATE INDEX func_b ON string_functional(protein_b);
    CREATE INDEX reg_a ON string_regulatory(protein_a); CREATE INDEX reg_b ON string_regulatory(protein_b);
    CREATE INDEX gp_sid ON gene_protein(string_id);
    """)
    con.commit()
    return con


if __name__ == "__main__":
    run(sys.argv[1], sys.argv[2])
