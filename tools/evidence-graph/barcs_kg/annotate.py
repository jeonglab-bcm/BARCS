"""Rule-based standardization of series, contrasts and tested elements.

    uv run python -m barcs_kg.annotate build/barcs_kg.sqlite

Every inferred field carries the rule that produced it (`*_basis`), so a
curator can see why a value was assigned and overrule it. Nothing here reads
biology into a contrast: the readout and what a positive estimate means for
gene function stay NULL until curated (see `contrast_annotation.readout`).
"""

import csv
import re
import sqlite3
import sys
from pathlib import Path

TAXA = {9606: "Homo sapiens", 10090: "Mus musculus", 10116: "Rattus norvegicus",
        9913: "Bos taurus", 5811: "Toxoplasma gondii", 226186: "Bacteroides thetaiotaomicron"}

# Series whose symbol case contradicts the organism stated in the record.
ORGANISM_OVERRIDES = {
    "GSE290153": (9606, "eHAP-iCas9 is a human HAP1 derivative; library symbols are title case"),
    "GSE215926": (9606, "SEM is a human B-ALL line; elements are hg peaks"),
    "GSE318501": (9606, "A375 is a human melanoma line; elements are miRNAs"),
}

# Contrasts the rules below get wrong, checked by hand against meta.json.
CONTRAST_OVERRIDES = {
    "GSE245526:d15_untreated_vs_input": {"modality": "KO"},          # HIV-CRISPR, Cas9 nuclease
    "GSE284239:gw_tng348_vs_dmso": {"modality": "KO"},               # genome-wide KO arm
    "GSE243882:MCF7_3D_vs_2D": {"selection_class": "culture_condition"},
    "GSE251758:intense_vs_pre": {"selection_class": "treatment"},    # in vitro restimulation
    "GSE251758:acute_vs_pre": {"selection_class": "treatment"},
    "GSE251758:chronic_vs_resting": {"selection_class": "treatment"},
    "GSE260469:IgG_vs_cell": {"selection_class": "in_vivo"},
    "GSE268533:sgCD274_vs_sgControl": {"selection_class": "genetic_interaction"},
    "GSE240894:jlat106_combo": {"selection_class": "infection"},     # viral RNA vs gDNA sort
    "GSE240894:jlat5a8_combo": {"selection_class": "infection"},
}

# Libraries whose elements are guide pairs or multi-gene arrays.
PAIR_SEPARATORS = {"GSE211073": "_", "GSE290153": "_", "GSE278336": "-"}

MODALITY_RULES = [  # (where, pattern, modality); first match wins
    ("name", r"crispra|_act_|^cal[ab]_", "CRISPRa"),
    ("name", r"crispri|dcas9krab", "CRISPRi"),
    ("name", r"(^|_)ko(_|$)|crisprn|_cas9_", "KO"),
    ("text", r"crisprgenee", "KO+CRISPRi"),
    ("text", r"crispra|activation library|\bsam\b|vp64|vpr\b|calabrese", "CRISPRa"),
    ("text", r"crispri|dcas9-krab|dcas12a|krab", "CRISPRi"),
    ("text", r"knockout|\bko\b|brunello|gecko|tkov3|\bbrie\b|\beko\b|cas9|crispr-star|grna library|sublibrary", "KO"),
]

SELECTION_RULES = [  # (where, pattern, class); first match wins
    ("name", r"interaction|_gi$|_vs_nt$|exo1ko_vs_wt|ptar1|ko_vs_wt|amgr_vs_parental|htert_vs_parental|kpk_specific|htelo_plus_vs_minus|nf2ko_vs_wt", "genetic_interaction"),
    ("name", r"tumou?r|graft|met_vs_primary|lung_tumor|parenchyma|meninges|nude|lineage_vs_hspc|in_vivo|invivo|^wt_vs_ko$|^p4_vs_wt$|bone_marrow|cas9_vs_wt|cas9_vs_nocas9", "in_vivo"),
    ("name", r"t_vs_not|tcell|nk|khyg|killing|coculture|tcells", "immune_coculture"),
    ("name", r"infected|sars2|oc43|hiv|d15_untreated_vs_input", "infection"),
    ("name", r"gfp|high|low|_hi_|_lo|hi_vs|top|bottom|q4_vs_q1|irfp|tompos|gata3_vs_tbet|negative|cd\d+|migrated|noninvading|establishment|maintenance|early_vs|late_vs|myh9|xist|re57m", "sort"),
    ("name", r"dmso|vehicle|_vs_control|vs_untreated|vs_saline|_vs_nt$|_vs_controls|palbo|doxo|oxali|fdu|cisplatin|rsl3|pfos|isx9|mpa_vs|gsi|cb103|samuraciclib|ven_|aza_|ptc596|tfe3_on|bile_vs|dasatinib|mrtx|combo|csf1r|ez|vem_vs|ir_vs|lgr_dasatinib", "treatment"),
    ("name", r"day\d+_vs_day\d+|_vs_day0|_vs_d0|d\d+_vs_d\d+|_vs_t0|vs_t20|final_vs_initial|vs_plasmid|vs_pool|dropout|d\d+_vs_d4|_vs_before|lgr100x|day14_vs|day21_vs|_vs_day1|vs_collection|vs_input|vs_culture|graft_vs_invitro", "fitness_time"),
    ("text", r"facs|sort", "sort"),
]


def first_match(rules, name, text):
    for where, pat, label in rules:
        hay = name if where == "name" else text
        if re.search(pat, hay, re.I):
            return label, f"{where}~/{pat}/"
    return None, None


def element(gene, gse):
    """Classify a tested element ID and name the gene(s) it maps to, if any."""
    if gse in PAIR_SEPARATORS and PAIR_SEPARATORS[gse] in gene:
        parts = [p for p in gene.split(PAIR_SEPARATORS[gse]) if p and p.lower() != "wildtype"]
        return "gene_pair", parts
    if "::" in gene and gene.startswith("chr"):
        return "peak_near_gene", [gene.rsplit(":", 1)[-1]]
    if re.match(r"^(chr)?[0-9XY]+:\d+-\d+$", gene) or gene.startswith("DHS_"):
        return "region", []
    if re.match(r"^(hsa-|mmu-)?mir-", gene, re.I):
        return "miRNA", []
    if re.match(r"^LH\d+$", gene) or re.match(r"^LINC\d+", gene):
        return "lncRNA", []
    if re.match(r"^ENSG\d+$", gene):
        return "ensembl_gene", [gene]
    if gene.startswith("TGGT1_"):
        return "parasite_gene", [gene]
    if gene.startswith("BTnc"):
        return "bacterial_sRNA", []
    # TSS-specific CRISPRi/a elements: Xist_p1, GENE_P1P2, GENE_ENST00000332601.3
    m = re.match(r"^(.+?)_(?:[Pp]\d+(?:[Pp]\d+)*|ENST\d+(?:\.\d+)?)$", gene)
    if m:
        return "promoter", [m.group(1)]
    # Excel turned SEPTIN4 into "Sep-04"/"4-Sep" in some deposited tables.
    # SEPTINn and DELEC1 are recoverable; "n-Mar" can be MARCHFn or MTARCn.
    m = (re.match(r"^(\d+)-(Sep|Mar|Dec)$", gene, re.I)
         or re.match(r"^(Sep|Mar|Dec)-0?(\d+)$", gene, re.I))
    if m:
        a, b = m.groups()
        n, month = (a, b) if a.isdigit() else (b, a)
        n, month = int(n), month.lower()
        if month == "sep":
            return "excel_recovered", [f"SEPTIN{n}"]
        if month == "dec" and n == 1:
            return "excel_recovered", ["DELEC1"]
        if month == "mar" and n > 2:
            return "excel_recovered", [f"MARCHF{n}"]
        return "excel_mangled", []
    if "/" in gene:  # one guide set shared by paralogs, e.g. PRB2/PRB1
        return "multi_gene_target", gene.split("/")
    return "gene", [gene]


def run(db):
    con = sqlite3.connect(db)
    con.executescript("""
    DROP TABLE IF EXISTS series_annotation; DROP TABLE IF EXISTS contrast_annotation;
    DROP TABLE IF EXISTS element; DROP TABLE IF EXISTS element_gene;
    CREATE TABLE series_annotation (
      gse TEXT PRIMARY KEY, taxon INTEGER, organism TEXT, organism_basis TEXT);
    CREATE TABLE contrast_annotation (
      contrast_id TEXT PRIMARY KEY, modality TEXT, modality_basis TEXT,
      selection_class TEXT, selection_basis TEXT, library_scope TEXT,
      readout TEXT, positive_estimate_means TEXT, negative_estimate_means TEXT,
      interest TEXT, curated_by TEXT);
    CREATE TABLE element (
      gse TEXT, element_id TEXT, element_type TEXT, PRIMARY KEY (gse, element_id));
    CREATE TABLE element_gene (
      gse TEXT, element_id TEXT, symbol TEXT, relation TEXT);
    """)

    con.execute("DROP TABLE IF EXISTS series_element")
    con.execute("""CREATE TABLE series_element AS
                   SELECT DISTINCT c.gse, r.gene FROM result r JOIN contrast c USING (contrast_id)""")
    con.execute("CREATE INDEX series_element_gse ON series_element(gse)")
    series = con.execute("SELECT gse, model_text, contrast_text FROM series").fetchall()
    for gse, model, ctext in series:
        text = f"{model} {ctext}"
        case = con.execute("""
            SELECT avg(gene GLOB '[A-Z]*' AND gene GLOB '*[a-z]*' AND gene NOT GLOB '*[A-Z][A-Z]*'),
                   avg(gene NOT GLOB '*[a-z]*')
            FROM series_element WHERE gse = ?""", (gse,)).fetchone()
        title, upper = (case[0] or 0), (case[1] or 0)
        if gse in ORGANISM_OVERRIDES:
            taxon, basis = ORGANISM_OVERRIDES[gse]
        elif re.search(r"toxoplasma", text, re.I):
            taxon, basis = 5811, "text: Toxoplasma"
        elif re.search(r"bacteroides", text, re.I):
            taxon, basis = 226186, "text: Bacteroides"
        elif re.search(r"bovine", text, re.I):
            taxon, basis = 9913, "text: bovine"
        elif re.search(r"\brat\b", text, re.I):
            taxon, basis = 10116, "text: rat"
        elif title > 0.5:
            taxon, basis = 10090, f"symbol case: {title:.0%} title-case"
        elif upper > 0.5:
            taxon, basis = 9606, f"symbol case: {upper:.0%} upper-case"
        else:
            taxon, basis = None, "undetermined"
        con.execute("INSERT INTO series_annotation VALUES (?,?,?,?)",
                    (gse, taxon, TAXA[taxon] if taxon else None, basis))

    rows = con.execute("""
        SELECT c.contrast_id, c.gse, c.name, s.model_text, s.contrast_text, d.rationale, c.genes
        FROM contrast c JOIN series s USING (gse) JOIN design d USING (design_id)""").fetchall()
    for cid, gse, name, model, ctext, rationale, genes in rows:
        text = f"{model} {ctext} {rationale}"
        modality, mbasis = first_match(MODALITY_RULES, name, text)
        selection, sbasis = first_match(SELECTION_RULES, name, text)
        fix = CONTRAST_OVERRIDES.get(cid, {})
        if "modality" in fix:
            modality, mbasis = fix["modality"], "manual override"
        if "selection_class" in fix:
            selection, sbasis = fix["selection_class"], "manual override"
        scope = ("genome_wide" if (genes or 0) >= 15000
                 else "focused" if genes else None)
        con.execute("""INSERT INTO contrast_annotation (contrast_id, modality, modality_basis,
                       selection_class, selection_basis, library_scope) VALUES (?,?,?,?,?,?)""",
                    (cid, modality, mbasis, selection, sbasis, scope))

    elements = con.execute(
        "SELECT gse, gene FROM series_element UNION SELECT gse, gene FROM claim").fetchall()
    for gse, gene in elements:
        etype, symbols = element(gene, gse)
        con.execute("INSERT OR IGNORE INTO element VALUES (?,?,?)", (gse, gene, etype))
        rel = {"gene": "is", "promoter": "promoter_of", "peak_near_gene": "near",
               "gene_pair": "pair_member", "multi_gene_target": "shared_target", "excel_recovered": "is", "ensembl_gene": "is", "parasite_gene": "is"}.get(etype)
        con.executemany("INSERT INTO element_gene VALUES (?,?,?,?)",
                        [(gse, gene, s, rel) for s in symbols])
    con.execute("CREATE INDEX element_gene_idx ON element_gene(gse, element_id)")
    apply_curation(con, Path(db).resolve().parent.parent / "curation")
    con.commit()
    return con


def apply_curation(con, folder):
    """Merge hand-curated readout semantics and claim directions, when present.

    curation/contrast_readout.tsv: contrast_id, readout, positive_estimate_means,
      negative_estimate_means, interest (+, -, both: the side holding the paper's phenotype), curated_by
    curation/claim_direction.tsv:  compare_id, gene, claimed_direction, source
    Blank cells are ignored, so a partly filled template is safe to load.
    """
    readout = folder / "contrast_readout.tsv"
    if readout.exists():
        with open(readout, newline="") as fh:
            for r in csv.DictReader(fh, delimiter="\t"):
                if r.get("readout") and r.get("positive_estimate_means"):
                    con.execute("""UPDATE contrast_annotation SET readout = ?, positive_estimate_means = ?,
                                   negative_estimate_means = ?, interest = ?, curated_by = ?
                                   WHERE contrast_id = ?""",
                                (r["readout"], r["positive_estimate_means"],
                                 r.get("negative_estimate_means") or None, r.get("interest") or None,
                                 r.get("curated_by") or "unknown", r["contrast_id"]))
    claims = folder / "claim_direction.tsv"
    if claims.exists():
        with open(claims, newline="") as fh:
            for r in csv.DictReader(fh, delimiter="\t"):
                if r.get("claimed_direction"):
                    con.execute("UPDATE claim SET claimed_direction = ? WHERE compare_id = ? AND gene = ?",
                                (r["claimed_direction"], r["compare_id"], r["gene"]))


def write_templates(con, folder):
    """Blank curation sheets with everything the graph already knows filled in."""
    folder.mkdir(exist_ok=True)
    with open(folder / "contrast_readout.template.tsv", "w", newline="") as fh:
        w = csv.writer(fh, delimiter="\t", lineterminator="\n")
        w.writerow(["contrast_id", "paper_title", "model", "contrast_text", "orientation", "modality",
                    "selection_class", "readout", "positive_estimate_means", "negative_estimate_means",
                    "interest", "curated_by"])
        w.writerows(con.execute("""
            SELECT c.contrast_id, p.title, s.model_text, s.contrast_text, c.orientation, a.modality,
                   a.selection_class, '', '', '', '', ''
            FROM contrast c JOIN contrast_annotation a USING (contrast_id) JOIN series s USING (gse)
            JOIN publication p ON p.pmid = s.pmid ORDER BY c.contrast_id"""))
    with open(folder / "claim_direction.template.tsv", "w", newline="") as fh:
        w = csv.writer(fh, delimiter="\t", lineterminator="\n")
        w.writerow(["compare_id", "gene", "paper_calls_text", "barcs_estimate", "claimed_direction",
                    "source"])
        w.writerows(con.execute("""
            SELECT cl.compare_id, cl.gene, s.paper_calls,
                   (SELECT estimate FROM result r WHERE r.contrast_id = cl.contrast_id
                    AND upper(r.gene) = upper(cl.gene)), '', ''
            FROM claim cl JOIN series s USING (gse) ORDER BY cl.compare_id, cl.gene"""))


if __name__ == "__main__":
    con = run(sys.argv[1])
    write_templates(con, Path(sys.argv[1]).resolve().parent.parent / "curation")
    for q in ("SELECT organism, count(*) FROM series_annotation GROUP BY 1 ORDER BY 2 DESC",
              "SELECT modality, count(*) FROM contrast_annotation GROUP BY 1 ORDER BY 2 DESC",
              "SELECT selection_class, count(*) FROM contrast_annotation GROUP BY 1 ORDER BY 2 DESC",
              "SELECT element_type, count(*) FROM element GROUP BY 1 ORDER BY 2 DESC"):
        print(con.execute(q).fetchall())
