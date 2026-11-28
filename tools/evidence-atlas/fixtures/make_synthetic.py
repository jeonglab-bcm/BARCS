"""Regenerate fixtures/synthetic/ deterministically. Every gene, study and publication is fictional.

    python3 fixtures/make_synthetic.py [OUT_DIR]      (from tools/evidence-atlas; default fixtures/synthetic)

Each scenario the tests rely on is named in SCENARIOS below. Records that must never
be exported carry the token WITHHELD-SENTINEL in their text so tests can scan outputs.
"""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from atlas import model as M  # noqa: E402
from atlas.review import make_entry  # noqa: E402

OUT = ROOT / "fixtures" / "synthetic"
GENE_STATUS = {"DEMO2": "unmapped", "DEMO3B": "synonym", "DEMO9": "ambiguous"}
H = lambda s: M.sha256_bytes(s.encode())  # noqa: E731  fictional artifact hashes
I = M.opaque_id  # noqa: E741

ALL_OK = {c: "confirmed" for c in M.CHECKS}
OBS_OK = dict(ALL_OK, scope="not_applicable")


def src(seed, n):
    return {"id": I("src", seed), "kind": "publication", "identifier_scheme": "fixture",
            "identifier": f"fixture:{seed}", "citation": f"Example Author et al. Fictional Journal of Cell Biology (2026) {n}",
            "url": f"https://example.org/fixture/{seed}", "accessed": "2026-11-20"}


def main(out=OUT):
    out = Path(out)
    sources = [src("pub-a", 1), src("pub-b", 2), src("pub-c", 3), src("pub-d", 4), src("pub-e", 5)]
    datasets = [{"id": I("ds", f"ds-{k}"), "accession": f"FIXTURE-DS-{k.upper()}", "version": "1" if k != "b" else None,
                 "described_by": I("src", f"pub-{k}")} for k in "abcde"]

    def study(k, title, scope):
        return {"id": I("st", f"st-{k}"), "dataset_id": I("ds", f"ds-{k}"), "title": title, "scope_category": scope,
                "archive_ref": f"fixture:archive/study-{k}", "archive_sha256": H(f"archive-{k}"),
                "validation_status": "not_validated", "organism": "Fictional model organism"}

    studies = [
        study("a", "Synthetic study A: fictional reporter screen of cilium length in a model cell line", "cell_biology"),
        study("b", "Synthetic study B: fictional screen of somite segmentation timing in a model embryo", "developmental_biology"),
        study("c", "Synthetic study C: placeholder classified out of scope WITHHELD-SENTINEL", "security_sensitive"),
        study("d", "Synthetic study D: unreviewed placeholder WITHHELD-SENTINEL", "cell_biology"),
        study("e", "Synthetic study E: scope uncertain placeholder WITHHELD-SENTINEL", "uncertain"),
    ]
    analyses = [{"id": I("an", f"an-{k}"), "study_id": I("st", f"st-{k}"), "label": f"fictional_contrast_{k}",
                 "method": "BARCS bb_screen + bb_gene_stouffer", "method_version": "0.2.3",
                 "fdr_threshold": 0.10 if k != "b" else None,
                 "artifact_ref": f"fixture:archive/study-{k}/genes.csv.gz", "artifact_sha256": H(f"artifact-{k}")}
                for k in "abcde"]

    def obs(seed, k, gene, wording, est, p, fdr, n, direction, limits="Single fictional cell line; one time point."):
        return {"id": I("ob", seed), "analysis_id": I("an", f"an-{k}"), **gid(gene),
                "source_wording": wording, "estimate": est,
                "estimate_meaning": "higher guide abundance in the reporter-low bin" if est is not None else None,
                "p_value": p, "fdr": fdr, "n_elements": n, "direction": direction, "limitations": limits}

    def gid(gene):
        """Fictional ids (HGNC:99xxxx is not a real range used here for real genes)."""
        status = GENE_STATUS.get(gene, "mapped")
        num = {"DEMO3B": "03"}.get(gene, gene[4:].zfill(2))
        return {"gene_symbol": gene, "gene_id": f"HGNC:9900{num}" if status in ("mapped", "synonym") else None,
                "gene_id_status": status}

    observations = [
        obs("o1", "a", "DEMO1", "DEMO1 guides enriched in the reporter-low bin.", 1.42, 0.0002, 0.012, 4, "enriched"),
        obs("o2", "b", "DEMO1", "DEMO1 guides depleted at the late time point.", -0.88, 0.003, 0.041, 4, "depleted",
            "Fictional embryo model; FDR threshold not recorded in the archive."),
        obs("o3", "a", "DEMO2", "DEMO2 tested; summary statistics not archived.", None, None, None, None, None, None),
        obs("o4", "a", "DEMO3", "DEMO3 guides show no change beyond the archived threshold.", 0.11, 0.41, 0.62, 4, "enriched"),
        obs("o5", "a", "DEMO4", "DEMO4 knockout abolishes cilia.", -1.05, 0.0009, 0.033, 4, "depleted"),
        obs("o6", "a", "DEMO5", "WITHHELD-SENTINEL unreviewed observation.", 0.5, 0.01, 0.08, 4, "enriched"),
        obs("o7", "a", "DEMO5", "WITHHELD-SENTINEL statistics check uncertain.", 0.6, 0.01, 0.07, 4, "enriched"),
        obs("o8", "a", "DEMO5", "WITHHELD-SENTINEL reviewers disagree.", 0.7, 0.01, 0.06, 4, "enriched"),
        obs("o9", "c", "DEMO6", "WITHHELD-SENTINEL observation in out-of-scope study.", 2.0, 1e-6, 1e-4, 4, "enriched"),
        obs("o10", "d", "DEMO7", "WITHHELD-SENTINEL observation in unreviewed study.", 2.0, 1e-6, 1e-4, 4, "enriched"),
        obs("o11", "e", "DEMO8", "WITHHELD-SENTINEL observation in scope-uncertain study.", 2.0, 1e-6, 1e-4, 4, "enriched"),
        obs("o12", "a", "DEMO10", "WITHHELD-SENTINEL rejected observation.", 0.9, 0.02, 0.09, 4, "enriched"),
        obs("o13", "a", "DEMO3B", "DEMO3B (previous symbol) guides unchanged in a second guide set.",
            0.05, 0.7, 0.81, 3, "depleted"),
    ]

    def claim(seed, k, gene, text, loc):
        return {"id": I("cl", seed), "source_id": I("src", f"pub-{k}"), "study_id": I("st", f"st-{k}"),
                **gid(gene), "source_wording": text, "source_location": loc}

    claims = [
        claim("c1", "a", "DEMO1", "We propose that DEMO1 restrains cilium elongation.", "Abstract"),
        claim("c2", "b", "DEMO1", "DEMO1 appears dispensable for segmentation timing.", "Results, Figure 3"),
        claim("c3", "a", "DEMO3", "WITHHELD-SENTINEL unreviewed claim about DEMO3.", "Discussion"),
        claim("c4", "b", "DEMO9", "DEMO9 is a candidate regulator of somite boundaries.", "Abstract"),
    ]

    def annot(seed, gene, term, label, origin):
        return {"id": I("at", seed), **gid(gene), "vocabulary": "Fixture Ontology",
                "vocabulary_version": "2026-01", "term_id": term, "term_label": label,
                "attribution": "Fictional vocabulary for tests", "origin": origin}

    annotations = [
        annot("a1", "DEMO1", "FX:0000101", "cilium organization (fictional term)", "curated"),
        annot("a2", "DEMO1", "FX:0000999", "WITHHELD-SENTINEL model-generated term", "model_generated"),
        annot("a3", "DEMO6", "FX:0000202", "WITHHELD-SENTINEL term for a gene outside the collection", "curated"),
    ]

    def assess(seed, k, agreement, text):
        return {"id": I("as", seed), "study_id": I("st", f"st-{k}"), "agreement": agreement,
                "verdict_wording": text, "assessed_by": "BARCS reanalysis (fictional)",
                "archive_ref": f"fixture:archive/study-{k}/meta.json", "archive_sha256": H(f"meta-{k}")}

    assessments = [
        assess("s1", "a", "partial", "Two of three fictional named hits pass FDR 0.10 in the reanalysis."),
        assess("s2", "b", None, "Agreement not recorded for this fictional study."),
        assess("s3", "c", "agree", "WITHHELD-SENTINEL assessment of out-of-scope study."),
        assess("s4", "a", "differ", "WITHHELD-SENTINEL unreviewed second assessment."),
    ]

    collection = {
        "schema_version": M.SCHEMA_VERSION,
        "collection": {"id": "synthetic-demo", "title": "Synthetic demonstration collection", "synthetic": True},
        "sources": sources, "datasets": datasets, "studies": studies, "analyses": analyses,
        "observations": observations, "claims": claims, "annotations": annotations,
        "assessments": assessments,
    }

    reviews = []
    revs = {}

    def rv(target, reviewer, decision, rationale, checks, ts, wording=None, scope=None):
        rtype = M.TYPES and next(t for t, (_, p) in M.TYPES.items() if target.startswith(p + "_"))
        revs[target] = revs.get(target, 0) + 1
        prev = reviews[-1]["entry_hash"] if reviews else M.GENESIS_HASH
        reviews.append(make_entry(prev, revs[target], rtype, target, reviewer, decision, rationale, checks,
                                  wording, scope, ts))

    T = "2026-11-2{}T1{}:00:00Z".format
    # Studies
    rv(I("st", "st-a"), "reviewer-a", "approve", "Fictional study within cell biology scope.", ALL_OK, T(1, 0), scope="in_scope")
    rv(I("st", "st-b"), "reviewer-a", "approve", "Fictional study within developmental biology scope.", ALL_OK, T(1, 0), scope="in_scope")
    rv(I("st", "st-c"), "reviewer-a", "reject", "Placeholder classified out of scope.", ALL_OK, T(1, 0), scope="out_of_scope")
    rv(I("st", "st-e"), "reviewer-a", "uncertain", "Scope cannot be determined from the record.",
       dict(ALL_OK, scope="uncertain"), T(1, 0), scope="uncertain")
    # Observations
    rv(I("ob", "o1"), "reviewer-a", "approve", "Matches archived table.", OBS_OK, T(2, 0))
    rv(I("ob", "o1"), "reviewer-b", "approve", "Independent check matches.", OBS_OK, T(2, 1))
    rv(I("ob", "o2"), "reviewer-a", "approve", "Matches archived table; threshold absent in archive.", OBS_OK, T(2, 0))
    rv(I("ob", "o3"), "reviewer-a", "approve", "Statistics genuinely absent from archive; shown as unknown.", OBS_OK, T(2, 0))
    rv(I("ob", "o4"), "reviewer-a", "approve", "Matches archived table.", OBS_OK, T(2, 0))
    rv(I("ob", "o5"), "reviewer-a", "needs_changes", "Source wording overstates a screen result as a phenotype.",
       dict(OBS_OK, wording="uncertain"), T(2, 0))
    rv(I("ob", "o5"), "reviewer-a", "approve", "Wording corrected to what was measured.",
       dict(OBS_OK, wording="corrected"), T(2, 2),
       wording="DEMO4 guides depleted in the reporter-low bin (FDR 0.033, as archived).")
    rv(I("ob", "o7"), "reviewer-a", "approve", "Approved, but statistic representation not checked.",
       dict(OBS_OK, statistical_representation="uncertain"), T(2, 0))
    rv(I("ob", "o8"), "reviewer-a", "approve", "Looks right.", OBS_OK, T(2, 0))
    rv(I("ob", "o8"), "reviewer-b", "reject", "Gene identifier ambiguous in source table.",
       dict(OBS_OK, source_identity="uncertain"), T(2, 1))
    rv(I("ob", "o9"), "reviewer-a", "approve", "Record itself transcribed correctly.", OBS_OK, T(2, 0))
    rv(I("ob", "o10"), "reviewer-a", "approve", "Record itself transcribed correctly.", OBS_OK, T(2, 0))
    rv(I("ob", "o11"), "reviewer-a", "approve", "Record itself transcribed correctly.", OBS_OK, T(2, 0))
    rv(I("ob", "o12"), "reviewer-a", "reject", "Does not match the archived table.", OBS_OK, T(2, 0))
    # Claims
    rv(I("cl", "c1"), "reviewer-a", "approve", "Quote and location verified.", OBS_OK, T(3, 0))
    rv(I("cl", "c2"), "reviewer-a", "approve", "Quote and location verified.", OBS_OK, T(3, 0))
    rv(I("cl", "c4"), "reviewer-a", "approve", "Quote and location verified.", OBS_OK, T(3, 0))
    rv(I("ob", "o13"), "reviewer-a", "approve", "Previous symbol confirmed against the fictional reference.", OBS_OK, T(2, 3))
    rv(I("as", "s1"), "reviewer-b", "approve", "Matches archived meta.json.", OBS_OK, T(3, 1))
    rv(I("as", "s2"), "reviewer-b", "approve", "Agreement absent in archive; shown as unknown.", OBS_OK, T(3, 1))
    rv(I("as", "s3"), "reviewer-b", "approve", "Transcribed correctly.", OBS_OK, T(3, 1))
    # Annotations
    rv(I("at", "a1"), "reviewer-a", "approve", "Term and version verified.", OBS_OK, T(4, 0))
    rv(I("at", "a3"), "reviewer-a", "approve", "Term verified.", OBS_OK, T(4, 0))

    out.mkdir(parents=True, exist_ok=True)
    (out / "collection.json").write_text(json.dumps(collection, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    (out / "reviews.jsonl").write_text("".join(M.canonical_json(r) + "\n" for r in reviews), encoding="utf-8")
    M.write_head(out, reviews)
    print(f"wrote {out}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else OUT)
