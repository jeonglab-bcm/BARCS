"""Export the BARCS findings as a Biolink Model knowledge graph (KGX TSV).

    uv run python -m barcs_kg.export_biolink build/barcs_kg.sqlite build/string_v12.5 \
        build/reference/biolink-model-4.4.6.yaml build/biolink

The schema is the Biolink Model (https://biolink.github.io/biolink-model/), the
data model of the NCATS Translator and Monarch knowledge graphs, so the output
merges with them (KGX tools, Neo4j loaders, Translator ingests). Every category,
predicate, qualifier value and required edge slot is checked against the pinned
biolink-model.yaml before writing; violations stop the export.

Nodes
  biolink:Gene                NCBIGene (human) or ENSEMBL (mouse, rat, cow) from
                              STRING aliases; BARCS.GENE:<taxon>-<symbol> if unmapped
  biolink:PhenotypicFeature   BARCS.SCREEN_PHENOTYPE:<GSE>.<contrast>  relative guide
                              abundance in the contrast's two conditions (every screen)
                              BARCS.PHENOTYPE:<readout>  the curated readout (80 screens)
  biolink:Study               BARCS.SCREEN:<GSE>.<contrast>, xref GEO:<GSE>
  biolink:Publication         PMID
  biolink:OrganismTaxon       NCBITaxon

Edges (all biolink:GeneToPhenotypicFeatureAssociation unless noted)
  screen   gene contributes_to SCREEN_PHENOTYPE   every FDR < HIT_FDR call;
           subject_form_or_variant_qualifier = loss/gain_of_function_variant_form
           (KO, CRISPRi / CRISPRa), object_direction_qualifier = increased if the
           estimate is positive (guides more abundant in the first condition)
  readout  gene contributes_to PHENOTYPE          the same calls on curated screens,
           direction mapped through curation/readout_direction.tsv
  claim    gene associated_with <phenotype>       genes the paper names; knowledge
           assertion from the publication, no direction

Only primary contrasts are exported (sensitivity reruns of a contrast are left out),
and within a contrast each gene keeps its best-p element. STRING is used only to
map gene symbols to identifiers; its interaction networks are not exported.
"""
import csv
import hashlib
import json
import re
import sqlite3
import sys
from collections import defaultdict
from pathlib import Path
from urllib.parse import quote

from barcs_kg.analyses import HIT_FDR, SENSITIVITY
from barcs_kg.string_db import VERSION, opener

BIOLINK_VERSION = "4.4.6"
INFORES_BARCS = "infores:barcs"      # local; not in the Translator infores registry
# CURIE prefixes the Biolink context lacks; the BARCS ones are namespaces, not pages
PREFIXES = {
    "BARCS.GENE": "https://jeonglab-bcm.github.io/BARCS/kg/gene/",
    "BARCS.SCREEN": "https://jeonglab-bcm.github.io/BARCS/kg/screen/",
    "BARCS.SCREEN_PHENOTYPE": "https://jeonglab-bcm.github.io/BARCS/kg/screen_phenotype/",
    "BARCS.PHENOTYPE": "https://jeonglab-bcm.github.io/BARCS/kg/phenotype/",
    "BARCS.EDGE": "https://jeonglab-bcm.github.io/BARCS/kg/edge/",
    "STRING": "https://string-db.org/network/",
    "GEO": "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=",
}
FORM = {"KO": "loss_of_function_variant_form", "CRISPRi": "loss_of_function_variant_form",
        "KO+CRISPRi": "loss_of_function_variant_form", "CRISPRa": "gain_of_function_variant_form"}
FLIP = {"increased": "decreased", "decreased": "increased"}

NODE_COLS = ["id", "category", "name", "description", "symbol", "in_taxon", "xref",
             "synonym", "creation_date", "publication_type", "provided_by"]
EDGE_COLS = ["id", "subject", "predicate", "object", "category",
             "subject_form_or_variant_qualifier", "object_direction_qualifier", "knowledge_level", "agent_type",
             "primary_knowledge_source", "publications", "has_supporting_studies",
             "original_subject", "effect_size", "p_value", "adjusted_p_value",
             "barcs_layer"]
# enum-valued edge slots checked against the model
ENUM_SLOTS = {"subject_form_or_variant_qualifier": "ChemicalOrGeneOrGeneProductFormOrVariantEnum",
              "object_direction_qualifier": "DirectionQualifierEnum",
              "knowledge_level": "KnowledgeLevelEnum", "agent_type": "AgentTypeEnum"}


def local(cid):
    """Contrast id as a CURIE local part (KGX rejects ":" and "/" there)."""
    return cid.replace(":", ".")


def slug(s):
    return re.sub(r"[^a-z0-9]+", "_", (s or "").lower()).strip("_") or "na"


def camel(name):
    return "biolink:" + "".join(w[:1].upper() + w[1:] for w in name.split())


def snake(name):
    return "biolink:" + name.replace(" ", "_")


def gene_xrefs(folder, taxa, wanted):
    """STRING id -> {'NCBIGene': [...], 'ENSEMBL': [...], 'HGNC': [...]} for wanted ids."""
    out = defaultdict(lambda: defaultdict(list))
    for taxon in taxa:
        path = folder / f"{taxon}.protein.aliases.v{VERSION}.txt.gz"
        if not path.exists():
            continue
        with opener(path) as fh:
            next(fh)
            for line in fh:
                sid, alias, source = line.rstrip("\n").split("\t")
                if sid not in wanted:
                    continue
                if source == "Ensembl_HGNC_entrez_id":
                    out[sid]["NCBIGene"].append(alias)
                elif source == "Ensembl_gene":
                    out[sid]["ENSEMBL"].append(alias)
                elif source == "Ensembl_HGNC_hgnc_id":
                    out[sid]["HGNC"].append(alias.removeprefix("HGNC:"))
    return out


class Genes:
    """(taxon, symbol) -> one Biolink gene node; symbols on one STRING protein merge."""

    def __init__(self, con, folder):
        self.protein = {(t, s): p for t, s, p in con.execute(
            "SELECT taxon, symbol, string_id FROM gene_protein WHERE string_id IS NOT NULL")}
        self.pname = dict(con.execute("SELECT string_id, preferred_name FROM string_protein"))
        self.pannot = dict(con.execute("SELECT string_id, annotation FROM string_protein"))
        self.folder = Path(folder)
        self.nodes = {}  # id -> node dict
        self.used = {}   # (taxon, symbol) -> id

    def resolve_ids(self):
        sids = {p for p in self.protein.values()}
        taxa = {t for t, _ in self.protein}
        self.xref = gene_xrefs(self.folder, taxa, sids)

    def id(self, taxon, symbol):
        key = (taxon, symbol)
        if key in self.used:
            return self.used[key]
        sid = self.protein.get(key)
        if sid:
            x = self.xref.get(sid, {})
            ncbi, ens = sorted(x.get("NCBIGene", []), key=int), sorted(x.get("ENSEMBL", []))
            gid = f"NCBIGene:{ncbi[0]}" if ncbi else f"ENSEMBL:{ens[0]}" if ens \
                else f"STRING:{sid}"
            name = self.pname.get(sid) or symbol
            xrefs = [f"HGNC:{h}" for h in sorted(set(x.get("HGNC", [])))] + \
                    [f"ENSEMBL:{e}" for e in ens if gid != f"ENSEMBL:{e}"] + [f"STRING:{sid}"]
            desc = self.pannot.get(sid) or ""
        else:
            gid = f"BARCS.GENE:{taxon}-{quote(symbol, safe='')}"
            name, xrefs, desc = symbol, [], ""
        node = self.nodes.setdefault(gid, {
            "id": gid, "category": "biolink:Gene", "name": name, "symbol": name,
            "description": desc[:300], "in_taxon": f"NCBITaxon:{taxon}",
            "xref": xrefs, "synonym": set(), "provided_by": INFORES_BARCS})
        if symbol != name:
            node["synonym"].add(symbol)
        self.used[key] = gid
        return gid


def edge_id(*parts):
    return "BARCS.EDGE:" + hashlib.sha1("|".join(map(str, parts)).encode()).hexdigest()[:16]


def load_directions(path):
    out = {}
    if Path(path).exists():
        with open(path) as fh:
            rows = csv.DictReader((l for l in fh if not l.startswith("#")), delimiter="\t")
            for r in rows:
                if r["positive_estimate_direction"] in FLIP:
                    out[r["contrast_id"]] = r["positive_estimate_direction"]
    return out


def build(con, string_dir, directions):
    genes = Genes(con, string_dir)
    genes.resolve_ids()
    nodes, edges = {}, []

    def node(nid, category, name, **kw):
        nodes.setdefault(nid, {"id": nid, "category": category, "name": name,
                               "provided_by": INFORES_BARCS, **kw})

    pubs = {r[0]: r for r in con.execute(
        "SELECT pmid, doi, pmcid, title, journal, published_date FROM publication")}
    contrasts = {}
    for row in con.execute("""
            SELECT c.contrast_id, c.gse, s.pmid, sa.taxon, a.modality, a.readout,
                   c.orientation, c.name, c.factor, c.treatment_level, c.reference_level,
                   s.model_text
            FROM contrast c JOIN series s USING (gse) JOIN series_annotation sa USING (gse)
            JOIN contrast_annotation a USING (contrast_id) WHERE c.has_results = 1"""):
        d = dict(zip(("cid", "gse", "pmid", "taxon", "modality", "readout", "orientation",
                      "name", "factor", "treatment", "reference", "model"), row))
        if not SENSITIVITY.search(d["name"]):
            contrasts[d["cid"]] = d
    labels = {}
    lp = Path(__file__).resolve().parent.parent / "curation" / "screen_labels.tsv"
    if lp.exists():
        with open(lp) as fh:
            labels = {r["contrast_id"]: r["label"] for r in csv.DictReader(fh, delimiter="\t")}

    def screen(c):
        """Study + screen phenotype (+ readout phenotype) nodes for a contrast."""
        cid, sid = c["cid"], f"BARCS.SCREEN:{local(c['cid'])}"
        if sid not in nodes:
            node(sid, "biolink:Study", labels.get(cid) or cid,
                 description="; ".join(x for x in (c["model"], c["orientation"]) if x),
                 xref=[f"GEO:{c['gse']}"])
            if c["factor"] and c["treatment"] and c["reference"]:
                what = f"{c['factor']}={c['treatment']} vs {c['factor']}={c['reference']}"
            else:
                what = c["name"]
            node(f"BARCS.SCREEN_PHENOTYPE:{local(cid)}", "biolink:PhenotypicFeature",
                 f"relative guide abundance, {what} ({c['gse']})",
                 description=c["orientation"] or "")
            if c["readout"]:
                node(f"BARCS.PHENOTYPE:{slug(c['readout'])}", "biolink:PhenotypicFeature",
                     c["readout"], description="curated screen readout (unreviewed)")
            p = c["pmid"]
            if p and p in pubs:
                _, doi, pmc, title, journal, date = pubs[p]
                node(f"PMID:{p}", "biolink:Publication", title or p,
                     description=journal or "", creation_date=date or "",
                     publication_type=["journal article"],
                     xref=[x for x in (f"doi:{doi}" if doi else "",
                                       f"PMC:{pmc.removeprefix('PMC')}" if pmc else "") if x])
        return sid

    def pheno_edge(layer, gid, pred, obj, c, direction=None, kl="statistical_association",
                   at="data_analysis_pipeline", **stats):
        e = {"subject": gid, "predicate": pred, "object": obj,
             "category": "biolink:GeneToPhenotypicFeatureAssociation",
             "subject_form_or_variant_qualifier": FORM.get(c["modality"], ""),
             "object_direction_qualifier": direction or "",
             "knowledge_level": kl, "agent_type": at,
             "primary_knowledge_source": INFORES_BARCS,
             "publications": [f"PMID:{c['pmid']}"] if c["pmid"] else [],
             "has_supporting_studies": [f"BARCS.SCREEN:{local(c['cid'])}"],
             "barcs_layer": layer, **stats}
        e["id"] = edge_id(layer, gid, pred, obj, c["cid"], direction)
        edges.append(e)

    # --- screen calls: best-p element per gene per contrast, FDR < HIT_FDR ---
    best = {}
    for cid, elem, sym, est, p, fdr in con.execute("""
            SELECT r.contrast_id, r.gene, eg.symbol, r.estimate, r.p_value, r.fdr
            FROM result r JOIN contrast c USING (contrast_id)
            JOIN element_gene eg ON eg.gse = c.gse AND eg.element_id = r.gene
                                 AND eg.relation IN ('is', 'promoter_of')
            WHERE r.fdr < ? AND r.estimate IS NOT NULL AND r.estimate != 0
            ORDER BY r.contrast_id, r.p_value""", (HIT_FDR,)):
        if cid in contrasts and (cid, sym) not in best:
            best[(cid, sym)] = (elem, est, p, fdr)
    hit_genes = set()
    for (cid, sym), (elem, est, p, fdr) in best.items():
        c = contrasts[cid]
        gid = genes.id(c["taxon"], sym)
        hit_genes.add(gid)
        screen(c)
        stats = {"original_subject": elem, "effect_size": round(est, 4),
                 "p_value": f"{p:.3g}", "adjusted_p_value": f"{fdr:.3g}"}
        up = "increased" if est > 0 else "decreased"
        pheno_edge("screen", gid, "biolink:contributes_to",
                   f"BARCS.SCREEN_PHENOTYPE:{local(cid)}", c, up, **stats)
        if c["readout"] and cid in directions:
            d = directions[cid] if est > 0 else FLIP[directions[cid]]
            pheno_edge("readout", gid, "biolink:contributes_to",
                       f"BARCS.PHENOTYPE:{slug(c['readout'])}", c, d, **stats)

    # --- paper claims: genes the paper names for the contrast ---
    for cid, sym in con.execute("SELECT DISTINCT contrast_id, gene FROM claim"):
        c = contrasts.get(cid)
        if not c or not sym:
            continue
        gid = genes.id(c["taxon"], sym)
        screen(c)
        obj = f"BARCS.PHENOTYPE:{slug(c['readout'])}" if c["readout"] \
            else f"BARCS.SCREEN_PHENOTYPE:{local(cid)}"
        pheno_edge("claim", gid, "biolink:associated_with", obj, c,
                   kl="knowledge_assertion", at="manual_agent")

    nodes.update(genes.nodes)
    for taxon in {n["in_taxon"] for n in genes.nodes.values()}:
        node(taxon, "biolink:OrganismTaxon", taxon)
    for t, org in con.execute("SELECT DISTINCT taxon, organism FROM series_annotation"):
        if f"NCBITaxon:{t}" in nodes:
            nodes[f"NCBITaxon:{t}"]["name"] = org
    # drop duplicate edge ids (a gene named twice in one contrast's claims)
    edges = list({e["id"]: e for e in edges}.values())
    return nodes, edges


def validate(nodes, edges, model_path):
    """Check categories, predicates, qualifiers and required slots against Biolink."""
    import yaml
    m = yaml.safe_load(open(model_path))
    if str(m.get("version")) != BIOLINK_VERSION:
        raise SystemExit(f"expected Biolink {BIOLINK_VERSION}, got {m.get('version')}")
    classes = {camel(n): n for n in m["classes"]}
    slots = {snake(n): n for n in m["slots"]}
    enums = m["enums"]
    errors, warnings = [], defaultdict(int)

    def ancestors(cls):
        out = []
        while cls:
            out.append(cls)
            cls = (m["classes"].get(cls) or {}).get("is_a")
        return out

    for n in nodes.values():
        cls = classes.get(n["category"])
        if not cls:
            errors.append(f"node category {n['category']} not a Biolink class")
            continue
        prefixes = next((m["classes"][c].get("id_prefixes") for c in ancestors(cls)
                         if m["classes"][c].get("id_prefixes")), None)
        if prefixes and n["id"].split(":")[0] not in prefixes:
            warnings[f"{n['category']} id prefix {n['id'].split(':')[0]} not in id_prefixes"] += 1
    node_ids = set(nodes)
    checked = set()
    for e in edges:
        for end in ("subject", "object"):
            if e[end] not in node_ids:
                errors.append(f"edge {e['id']} {end} {e[end]} has no node")
        for req in ("knowledge_level", "agent_type", "primary_knowledge_source"):
            if not e.get(req):
                errors.append(f"edge {e['id']} lacks required {req}")
        sig = (e["category"], e["predicate"], e.get("qualified_predicate"),
               *(e.get(s) for s in ENUM_SLOTS))
        if sig in checked:
            continue
        checked.add(sig)
        cls = classes.get(e["category"])
        if not cls:
            errors.append(f"edge category {e['category']} not a Biolink class")
            continue
        for p in (e["predicate"], e.get("qualified_predicate")):
            if p and (p not in slots or not (m["slots"][slots[p]] or {}).get(
                    "annotations", {}).get("canonical_predicate")):
                errors.append(f"{p} is not a canonical Biolink predicate")
        usage = m["classes"][cls].get("slot_usage") or {}
        allowed = (usage.get("predicate") or {}).get("range")
        if allowed in enums and e["predicate"] not in enums[allowed]["permissible_values"]:
            errors.append(f"{e['predicate']} not allowed on {e['category']} ({allowed})")
        for col, enum in ENUM_SLOTS.items():
            v = e.get(col)
            if v and v not in enums[enum]["permissible_values"]:
                errors.append(f"{col}={v} not in {enum}")
            if v and col.endswith("qualifier"):
                own = set(m["classes"][cls].get("slots") or [])
                for mixin in m["classes"][cls].get("mixins") or []:
                    own |= set(m["classes"][mixin].get("slots") or [])
                if col.replace("_", " ") not in own:
                    errors.append(f"{col} is not a slot of {e['category']}")
    return {"biolink_version": m["version"], "errors": errors[:50], "n_errors": len(errors),
            "warnings": dict(warnings)}


def write(nodes, edges, out):
    def cell(v):
        if isinstance(v, (list, set, tuple)):
            return "|".join(sorted(v))
        return "" if v is None else str(v).replace("|", "/")  # "|" separates KGX list values

    for name, cols, rows in (("nodes.tsv", NODE_COLS, sorted(nodes.values(), key=lambda n: n["id"])),
                             ("edges.tsv", EDGE_COLS, edges)):
        with open(out / name, "w", newline="") as fh:
            w = csv.writer(fh, delimiter="\t", lineterminator="\n", quoting=csv.QUOTE_NONE,
                           escapechar="\\")
            w.writerow(cols)
            for r in rows:
                w.writerow([cell(r.get(c)).replace("\t", " ").replace("\n", " ") for c in cols])


def run(db, string_dir, model_path, outdir):
    out = Path(outdir)
    out.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(db)
    cur = Path(__file__).resolve().parent.parent / "curation" / "readout_direction.tsv"
    nodes, edges = build(con, string_dir, load_directions(cur))
    report = validate(nodes, edges, model_path)
    if report["n_errors"]:
        print(json.dumps(report, indent=2))
        raise SystemExit("Biolink validation failed; nothing written")
    write(nodes, edges, out)
    (out / "prefixes.json").write_text(json.dumps(PREFIXES, indent=2))
    def count(key, rows):
        c = defaultdict(int)
        for r in rows:
            c[r.get(key)] += 1
        return dict(sorted(c.items()))

    stats = {
        "format": "KGX TSV", "biolink_version": report["biolink_version"],
        "nodes": len(nodes), "edges": len(edges),
        "node_categories": count("category", nodes.values()),
        "edge_predicates": count("predicate", edges),
        "edge_layers": count("barcs_layer", edges),
        "gene_id_prefixes": count("prefix", [{"prefix": n["id"].split(":")[0]}
                                             for n in nodes.values() if n["category"] == "biolink:Gene"]),
        "hit_fdr": HIT_FDR,
        "readout_screens_with_direction": len({e["has_supporting_studies"][0] for e in edges
                                               if e.get("barcs_layer") == "readout"}),
        "validation": report,
    }
    (out / "stats.json").write_text(json.dumps(stats, indent=2))
    print(json.dumps(stats, indent=2))
    return stats


if __name__ == "__main__":
    run(*sys.argv[1:5])
