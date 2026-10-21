"""Load every BARCS reanalysis record into SQLite.

    uv run python -m barcs_kg.ingest ../.. build/barcs_kg.sqlite

Reads reanalyses/<GSE>/{meta,design*,compare*}.json and
results/<analysis>/{run_info.json,genes.csv.gz}. Every tested gene is kept,
non-hits included, so absence of a call can be told apart from absence of a test.
"""

import csv
import gzip
import json
import re
import sqlite3
import subprocess
import sys
from pathlib import Path

SCHEMA = """
CREATE TABLE source (key TEXT PRIMARY KEY, value TEXT);
CREATE TABLE publication (
  pmid TEXT PRIMARY KEY, doi TEXT, pmcid TEXT, title TEXT, journal TEXT,
  published_date TEXT);
CREATE TABLE series (
  gse TEXT PRIMARY KEY, pmid TEXT REFERENCES publication, model_text TEXT,
  contrast_text TEXT, paper_method TEXT, paper_calls TEXT, barcs_calls TEXT,
  named_hits_text TEXT, verdict TEXT, agreement TEXT, analyzed TEXT,
  count_recovery TEXT);
CREATE TABLE design (
  design_id TEXT PRIMARY KEY, gse TEXT REFERENCES series, file TEXT,
  counts_file TEXT, counts_md5 TEXT, control_gene_pattern TEXT,
  min_total_count INTEGER, n_samples INTEGER, factor_levels TEXT, rationale TEXT);
CREATE TABLE sample (
  design_id TEXT REFERENCES design, col TEXT, gsm TEXT, attrs TEXT);
CREATE TABLE contrast (
  contrast_id TEXT PRIMARY KEY, gse TEXT REFERENCES series,
  design_id TEXT REFERENCES design, name TEXT, formula TEXT, term TEXT,
  totals TEXT, columns TEXT,
  factor TEXT, treatment_level TEXT, reference_level TEXT, orientation TEXT,
  libraries INTEGER, residual_df INTEGER, guides INTEGER, genes INTEGER,
  moderated INTEGER, prior_df REAL, guide_correlation REAL,
  control_guides INTEGER, control_p05_raw REAL, control_p05 REAL,
  control_scale REAL, totals_method TEXT, test TEXT, guides_lr INTEGER,
  top1pct_max REAL, n_fdr10 INTEGER, n_fdr10_up INTEGER, n_fdr10_down INTEGER,
  n_fdr05 INTEGER, n_emp_fdr10 INTEGER, empirical_centre TEXT,
  control_shift REAL, barcs_version TEXT, has_results INTEGER);
CREATE TABLE result (
  contrast_id TEXT REFERENCES contrast, gene TEXT, n_guides INTEGER,
  estimate REAL, p_value REAL, fdr REAL, empirical_p REAL, empirical_fdr REAL,
  rank_p INTEGER);
CREATE TABLE comparison (
  compare_id TEXT PRIMARY KEY, gse TEXT REFERENCES series, file TEXT,
  contrast_id TEXT REFERENCES contrast, direction TEXT, published TEXT,
  top_n TEXT);
CREATE TABLE claim (
  compare_id TEXT REFERENCES comparison, gse TEXT, contrast_id TEXT,
  gene TEXT, source TEXT, claimed_direction TEXT);
"""


def jload(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def num(x):
    if x is None or x == "" or x == "NA":
        return None
    try:
        return float(x)
    except ValueError:
        return None


def orientation(term, columns, samples, factor_levels):
    """Name the levels a positive estimate compares.

    For a factor term such as `conditioniRFP`, a positive estimate means the
    guide's share is higher in `iRFP` libraries than in the reference level
    (the first level of that factor among the analysed libraries). Numeric
    terms read as "per unit increase". Returns (factor, treatment, reference,
    sentence) with None where the design does not determine them.
    """
    used = [s for s in samples if not columns or s["column"] in columns]
    if ":" in term:
        parts = [orientation(t, columns, samples, factor_levels) for t in term.split(":")]
        if all(p[1] and p[2] for p in parts):
            (f1, l1, r1, _), (f2, l2, r2, _) = parts[0], parts[1]
            return (term, None, None,
                    f"estimate > 0: the {f2}={l2} vs {r2} change is larger in "
                    f"{f1}={l1} than in {f1}={r1} (interaction)")
        return term, None, None, None
    for factor, levels in (factor_levels or {}).items():
        if not term.startswith(factor):
            continue
        level = term[len(factor):]
        if level not in levels:
            continue
        present = [lv for lv in levels if any(str(s.get(factor)) == lv for s in used)]
        ref = next((lv for lv in present if lv != level), None)
        if ref is None:
            return factor, level, None, None
        return (factor, level, ref,
                f"estimate > 0: guides more abundant in {factor}={level} than in {factor}={ref}")
    if used and term in used[0] and isinstance(used[0][term], (int, float)):
        return term, None, None, f"estimate > 0: guide abundance rises per unit of {term}"
    return None, None, None, None


def read_genes(path):
    with gzip.open(path, "rt", encoding="utf-8", newline="") as fh:
        rows = list(csv.DictReader(fh))
    rows.sort(key=lambda r: p if (p := num(r["p_value"])) is not None else 2.0)
    for i, r in enumerate(rows, 1):
        yield (r["gene"], int(float(r["n_guides"])) if r.get("n_guides") else None,
               num(r["estimate"]), num(r["p_value"]), num(r["fdr"]),
               num(r.get("empirical_p_value")), num(r.get("empirical_fdr")), i)


def build(repo, db_path):
    repo = Path(repo)
    root = repo / "reanalyses"
    db_path = Path(db_path)
    db_path.parent.mkdir(parents=True, exist_ok=True)
    if db_path.exists():
        db_path.unlink()
    con = sqlite3.connect(db_path)
    con.executescript(SCHEMA)
    # git itself, not .git/HEAD: a full clone keeps branch refs packed
    try:
        commit = subprocess.run(["git", "-C", str(repo), "rev-parse", "HEAD"], capture_output=True,
                                text=True, check=True).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        commit = None
    con.executemany("INSERT INTO source VALUES (?, ?)",
                    [("barcs_repo", str(repo.resolve())), ("barcs_commit", commit)])

    for gse_dir in sorted(p for p in root.iterdir() if p.is_dir() and p.name.startswith("GSE")):
        gse = gse_dir.name
        meta = jload(gse_dir / "meta.json")
        con.execute("INSERT OR IGNORE INTO publication VALUES (?,?,?,?,?,?)",
                    (meta["pmid"], meta.get("doi"), meta.get("pmcid"), meta.get("title"),
                     meta.get("journal"), meta.get("published_date")))
        recovery = meta.get("count_recovery")
        con.execute("INSERT INTO series VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                    (gse, meta["pmid"], meta.get("model"), meta.get("contrast"),
                     meta.get("paper_method"), meta.get("paper_calls"), meta.get("barcs_calls"),
                     meta.get("named_hits"), meta.get("verdict"), meta.get("agreement"),
                     meta.get("analyzed"),
                     json.dumps(recovery) if recovery is not None else None))

        for dfile in sorted(gse_dir.glob("design*.json")):
            d = jload(dfile)
            design_id = f"{gse}/{dfile.stem}"
            samples = d.get("samples", [])
            con.execute("INSERT INTO design VALUES (?,?,?,?,?,?,?,?,?,?)",
                        (design_id, gse, dfile.name, d.get("counts_file"), d.get("counts_md5"),
                         d.get("control_gene_pattern"), d.get("min_total_count"), len(samples),
                         json.dumps(d.get("factor_levels")), d.get("rationale")))
            con.executemany("INSERT INTO sample VALUES (?,?,?,?)",
                            [(design_id, s.get("column"), s.get("gsm"),
                              json.dumps({k: v for k, v in s.items() if k not in ("column", "gsm")}))
                             for s in samples])
            for a in d.get("analyses", []):
                cid = f"{gse}:{a['name']}"
                factor, trt, ref, orient = orientation(a["term"], a.get("columns"),
                                                       samples, d.get("factor_levels"))
                rdir = gse_dir / "results" / a["name"]
                info = jload(rdir / "run_info.json") if (rdir / "run_info.json").exists() else {}
                info = {k: (None if v == "NA" else v) for k, v in info.items()}  # R's NA
                top1 = info.get("top1pct_read_share") or {}
                con.execute(
                    "INSERT INTO contrast VALUES (" + ",".join("?" * 36) + ")",
                    (cid, gse, design_id, a["name"], a["formula"], a["term"],
                     a.get("totals") or d.get("totals"), json.dumps(a.get("columns")),
                     factor, trt, ref, orient,
                     info.get("libraries"), info.get("residual_df"), info.get("guides"),
                     info.get("genes"), int(bool(info.get("moderated"))) if info else None,
                     info.get("prior_df"), info.get("guide_correlation"),
                     info.get("control_guides"), info.get("control_p05_raw"),
                     info.get("control_p05"), info.get("control_scale"),
                     info.get("totals_method"), info.get("test"), info.get("guides_lr"),
                     max(top1.values()) if isinstance(top1, dict) and top1 else None,
                     info.get("genes_fdr_0_10"), info.get("genes_fdr_0_10_up"),
                     info.get("genes_fdr_0_10_down"), info.get("genes_fdr_0_05"),
                     info.get("genes_empirical_fdr_0_10"),
                     json.dumps(info.get("empirical_centre")) if info.get("empirical_centre") is not None else None,
                     info.get("control_shift"), info.get("barcs_version"),
                     int((rdir / "genes.csv.gz").exists())))
                if (rdir / "genes.csv.gz").exists():
                    con.executemany("INSERT INTO result VALUES (?,?,?,?,?,?,?,?,?)",
                                    ((cid,) + row for row in read_genes(rdir / "genes.csv.gz")))

        for cfile in sorted(gse_dir.glob("compare*.json")):
            c = jload(cfile)
            compare_id = f"{gse}/{cfile.stem}"
            m = re.search(r"results/([^/]+)/genes\.csv", c.get("barcs_genes", ""))
            cid = f"{gse}:{m.group(1)}" if m else None
            con.execute("INSERT INTO comparison VALUES (?,?,?,?,?,?,?)",
                        (compare_id, gse, cfile.name, cid, c.get("direction"),
                         json.dumps(c.get("published")) if c.get("published") else None,
                         json.dumps(c.get("top_n"))))
            hits = c.get("named_hits") or []
            if isinstance(hits, str):
                hits = [hits]
            # compare.json lists named genes without the direction the paper
            # claimed, so claimed_direction stays NULL until it is curated.
            con.executemany("INSERT INTO claim VALUES (?,?,?,?,?,?)",
                            [(compare_id, gse, cid, g, "named_hits", None) for g in hits])

    con.executescript("""
    CREATE INDEX result_contrast ON result(contrast_id);
    CREATE INDEX result_gene ON result(gene);
    CREATE INDEX result_contrast_gene ON result(contrast_id, gene COLLATE NOCASE);
    CREATE INDEX claim_gene ON claim(gene);
    CREATE INDEX claim_contrast ON claim(contrast_id);
    """)
    con.commit()
    return con


if __name__ == "__main__":
    con = build(sys.argv[1], sys.argv[2])
    for t in ("publication", "series", "design", "contrast", "result", "comparison", "claim"):
        print(t, con.execute(f"SELECT count(*) FROM {t}").fetchone()[0])
