"""Tests for the evidence atlas. Run from tools/evidence-atlas:  python3 -m unittest discover -s tests"""

import copy
import json
import os
import re
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from atlas import build as B, eligibility as E, genes as G, model as M, review as R  # noqa: E402
from atlas.validate import errors, validate  # noqa: E402

FIXTURES = ROOT / "fixtures" / "synthetic"
I = M.opaque_id  # noqa: E741


class Tmp(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp(prefix="atlas-test-"))
        self.coll_dir = self.tmp / "coll"
        shutil.copytree(FIXTURES, self.coll_dir)
        self.out = self.tmp / "out"

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def data(self):
        return json.loads((self.coll_dir / "collection.json").read_text())

    def write(self, data):
        (self.coll_dir / "collection.json").write_text(json.dumps(data))

    def codes(self):
        return {p.code for p in errors(validate(M.load(self.coll_dir)))}

    def build(self):
        B.build(self.coll_dir, self.out)
        pub = self.out / "public"
        return (json.loads((pub / "atlas.json").read_text()), (pub / "atlas.json").read_text(),
                (pub / "index.html").read_text())


class TestFixtures(unittest.TestCase):
    def test_fixtures_are_current(self):
        """Committed fixtures equal what make_synthetic.py generates."""
        with tempfile.TemporaryDirectory() as d:
            before = {p.name: p.read_bytes() for p in FIXTURES.iterdir()}
            subprocess.run([sys.executable, str(ROOT / "fixtures" / "make_synthetic.py")], check=True,
                           capture_output=True)
            after = {p.name: p.read_bytes() for p in FIXTURES.iterdir()}
            self.assertEqual(before, after)
            del d

    def test_fixtures_validate_cleanly(self):
        self.assertEqual(errors(validate(M.load(FIXTURES))), [])


class TestSchemaConstraints(Tmp):
    def db(self):
        con = B.create_db(self.tmp / "t.sqlite")
        self.addCleanup(con.close)
        B.load_db(con, M.load(self.coll_dir))
        return con

    def test_foreign_key_enforced(self):
        con = self.db()
        with self.assertRaises(sqlite3.IntegrityError):
            con.execute("INSERT INTO dataset (id, accession, version, described_by) VALUES (?,?,?,?)",
                        ("ds_000000000000", "X", "1", "src_ffffffffffff"))

    def test_unique_identifier_enforced(self):
        con = self.db()
        row = con.execute("SELECT identifier_scheme, identifier FROM source LIMIT 1").fetchone()
        with self.assertRaises(sqlite3.IntegrityError):
            con.execute("INSERT INTO source VALUES (?,?,?,?,?,?,?)",
                        ("src_000000000000", "publication", row[0], row[1], "c", "https://x", "2026-01-01"))

    def test_sources_immutable_and_reviews_append_only(self):
        con = self.db()
        for sql in ("UPDATE source SET citation = 'x'", "UPDATE observation SET fdr = 0.5",
                    "UPDATE review SET decision = 'approve'", "DELETE FROM review"):
            with self.assertRaises(sqlite3.DatabaseError, msg=sql):
                con.execute(sql)

    def test_review_target_must_exist(self):
        con = self.db()
        with self.assertRaises(sqlite3.DatabaseError):
            con.execute("INSERT INTO review VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                        ("rv_000000000000", 999, "observation", "ob_ffffffffffff", 1, "r", "2026-01-01T00:00:00Z",
                         "approve", "x", *["confirmed"] * 5, None, None, "0" * 64, "1" * 64))

    def test_scope_lists_agree_with_schema(self):
        con = self.db()
        permitted = {r[0] for r in con.execute("SELECT name FROM scope_category WHERE permitted = 1")}
        allc = {r[0] for r in con.execute("SELECT name FROM scope_category")}
        self.assertEqual(permitted, set(M.PERMITTED_SCOPE))
        self.assertEqual(allc, set(M.SCOPE_CATEGORIES))

    def test_sql_and_python_eligibility_agree(self):
        con = self.db()
        sql_ids = set()
        for v in ("source", "dataset", "study", "analysis", "observation", "claim", "annotation", "assessment"):
            sql_ids |= {r[0] for r in con.execute(f"SELECT id FROM eligible_{v}")}
        self.assertEqual(sql_ids, E.eligible_ids(M.load(self.coll_dir)))


class TestValidation(Tmp):
    def test_duplicate_id(self):
        d = self.data()
        d["observations"].append(copy.deepcopy(d["observations"][0]))
        self.write(d)
        self.assertIn("duplicate_id", self.codes())

    def test_duplicate_source_identifier(self):
        d = self.data()
        s = copy.deepcopy(d["sources"][0])
        s["id"] = "src_000000000001"
        d["sources"].append(s)
        self.write(d)
        self.assertIn("duplicate_record", self.codes())

    def test_unresolved_reference(self):
        d = self.data()
        d["observations"][0]["analysis_id"] = "an_ffffffffffff"
        self.write(d)
        self.assertIn("unresolved_reference", self.codes())

    def test_invalid_source_identifiers(self):
        for scheme, ident in (("doi", "not-a-doi"), ("pmid", "PMID123"), ("url", "http://x"), ("fixture", "")):
            d = self.data()
            d["sources"][0].update(identifier_scheme=scheme, identifier=ident)
            self.write(d)
            c = self.codes()
            self.assertTrue({"bad_identifier", "empty_value"} & c, (scheme, ident, c))

    def test_missing_source_identifier(self):
        d = self.data()
        del d["sources"][0]["identifier"]
        self.write(d)
        self.assertIn("missing_field", self.codes())

    def test_malformed_record(self):
        d = self.data()
        d["observations"][0]["fdr"] = 1.5
        d["observations"][1]["p_value"] = "0.01"
        d["observations"][2]["surprise"] = 1
        d["studies"][0]["scope_category"] = "anything"
        self.write(d)
        self.assertTrue({"out_of_range", "bad_type", "unknown_field", "bad_enum"} <= self.codes())

    def test_schema_version(self):
        d = self.data()
        d["schema_version"] = 1
        self.write(d)
        self.assertIn("schema_version", self.codes())

    def test_bad_opaque_id(self):
        d = self.data()
        d["claims"][0]["id"] = "claim-1"
        self.write(d)
        self.assertIn("bad_id", self.codes())

    def test_edited_review_history_detected(self):
        p = self.coll_dir / "reviews.jsonl"
        lines = p.read_text().splitlines()
        e = json.loads(lines[4])
        e["decision"] = "reject"
        lines[4] = M.canonical_json(e)
        p.write_text("\n".join(lines) + "\n")
        self.assertIn("bad_entry_hash", self.codes())

    def test_reordered_or_deleted_review_detected(self):
        p = self.coll_dir / "reviews.jsonl"
        lines = p.read_text().splitlines()
        del lines[3]
        p.write_text("\n".join(lines) + "\n")
        self.assertIn("broken_chain", self.codes())

    def test_build_fails_on_invalid(self):
        d = self.data()
        d["observations"][0]["analysis_id"] = "an_ffffffffffff"
        self.write(d)
        with self.assertRaises(B.BuildError):
            B.build(self.coll_dir, self.out)

    def test_every_displayed_record_resolves_to_source(self):
        exp, _, _ = self.build()
        for ob in exp["observations"].values():
            an = exp["analyses"][ob["analysis_id"]]
            st = exp["studies"][an["study_id"]]
            ds = exp["datasets"][st["dataset_id"]]
            self.assertTrue(exp["sources"][ds["described_by"]]["url"].startswith("https://"))
        for cl in exp["claims"].values():
            self.assertIn(cl["source_id"], exp["sources"])


class TestDeterminism(Tmp):
    def test_idempotent_rebuild(self):
        m1, _ = B.build(self.coll_dir, self.out)
        b1 = {n: (self.out / "public" / n).read_bytes() for n in ("atlas.json", "index.html", "MANIFEST.json")}
        m2, _ = B.build(self.coll_dir, self.tmp / "out2")
        b2 = {n: (self.tmp / "out2" / "public" / n).read_bytes() for n in b1}
        self.assertEqual(m1, m2)
        self.assertEqual(b1, b2)

    def test_input_order_does_not_change_output(self):
        B.build(self.coll_dir, self.out)
        a = (self.out / "public" / "atlas.json").read_bytes()
        d = self.data()
        for k in ("observations", "claims", "sources"):
            d[k].reverse()
        self.write(d)
        B.build(self.coll_dir, self.tmp / "out2")
        self.assertEqual(a, (self.tmp / "out2" / "public" / "atlas.json").read_bytes())


class TestReviewWorkflow(Tmp):
    def test_correction_retains_history_and_both_wordings(self):
        exp, _, _ = self.build()
        ob = exp["observations"][I("ob", "o5")]
        self.assertTrue(ob["wording_corrected"])
        self.assertEqual(ob["source_wording"], "DEMO4 knockout abolishes cilia.")
        self.assertIn("DEMO4 guides depleted", ob["display_wording"])
        hist = exp["reviews"][ob["id"]]
        self.assertEqual([h["decision"] for h in hist], ["needs_changes", "approve"])

    def test_append_review_and_queue(self):
        target = I("ob", "o6")
        self.assertIn(target, {r[1] for r in R.queue(M.load(self.coll_dir))})
        R.append(self.coll_dir, target_id=target, reviewer="reviewer-a", decision="approve",
                 rationale="Checked.", checks=dict({c: "confirmed" for c in M.CHECKS}, scope="not_applicable"),
                 timestamp="2026-11-25T10:00:00Z")
        self.assertNotIn(target, {r[1] for r in R.queue(M.load(self.coll_dir))})
        self.assertEqual(errors(validate(M.load(self.coll_dir))), [])

    def test_append_rejects_invalid_review(self):
        before = (self.coll_dir / "reviews.jsonl").read_bytes()
        with self.assertRaises(ValueError):
            R.append(self.coll_dir, target_id=I("ob", "o6"), reviewer="r", decision="approve", rationale="x",
                     checks={c: "corrected" for c in M.CHECKS}, timestamp="2026-11-25T10:00:00Z")
        self.assertEqual(before, (self.coll_dir / "reviews.jsonl").read_bytes())

    def test_later_dissent_withholds_approved_record(self):
        target = I("ob", "o1")
        R.append(self.coll_dir, target_id=target, reviewer="reviewer-c", decision="needs_changes",
                 rationale="Direction label unclear.", checks={c: "uncertain" for c in M.CHECKS},
                 timestamp="2026-11-25T10:00:00Z")
        exp, _, _ = self.build()
        self.assertNotIn(target, exp["observations"])

    def test_model_generated_annotation_not_auto_published(self):
        exp, _, _ = self.build()
        self.assertNotIn(I("at", "a2"), exp["annotations"])


class TestDisplaySemantics(Tmp):
    def test_disagreement_preserved(self):
        exp, _, _ = self.build()
        g = exp["genes"]["HGNC:990001"]
        self.assertEqual(len(g["observations"]), 2)
        self.assertEqual(len(g["claims"]), 2)
        self.assertTrue(g["direction_conflict"])
        dirs = sorted(exp["observations"][i]["direction"] for i in g["observations"])
        self.assertEqual(dirs, ["depleted", "enriched"])

    def test_unknown_values_remain_unknown(self):
        exp, _, _ = self.build()
        ob = exp["observations"][I("ob", "o3")]
        for f in ("estimate", "p_value", "fdr", "n_elements", "direction", "estimate_meaning", "limitations", "gene_id"):
            self.assertIsNone(ob[f], f)
        self.assertIsNone(ob["fdr_below_threshold"])
        # Missing threshold (study B) leaves the comparison unknown, not decided.
        self.assertIsNone(exp["observations"][I("ob", "o2")]["fdr_below_threshold"])
        self.assertIsNone(exp["datasets"][I("ds", "ds-b")]["version"])

    def test_no_causal_language_in_generated_text(self):
        exp, _, html = self.build()
        generated = json.dumps(exp["notices"]) + re.sub(r'<script id="atlas-data".*?</script>', "", html, flags=re.S)
        causal = re.compile(r"\b(causes?|drives?|required for|essential for|regulates?|controls?|mechanism of)\b", re.I)
        hits = [m.group(0) for m in causal.finditer(generated)
                if not re.search(r"(not|does not) (establish )?a causal", generated[max(0, m.start() - 40):m.end()])]
        self.assertEqual(hits, [])
        self.assertIn("does not establish", exp["notices"]["statistics"])
        self.assertIn("not evidence that a biological relationship is absent", exp["notices"]["not_below_threshold"])

    def test_claims_independent_of_statistics(self):
        exp, _, _ = self.build()
        for cl in exp["claims"].values():
            for f in ("estimate", "p_value", "fdr", "fdr_below_threshold"):
                self.assertNotIn(f, cl)


class TestExclusion(Tmp):
    def test_blocked_records_absent_from_every_output(self):
        exp, text, html = self.build()
        coll = M.load(self.coll_dir)
        blocked = set(coll.index()) - E.eligible_ids(coll)
        self.assertTrue(blocked)
        internal = (self.out / "internal" / "withheld.tsv").read_text()
        for rid in blocked:
            self.assertNotIn(rid, text)
            self.assertNotIn(rid, html)
        for out_text in (text, html):
            self.assertNotIn("WITHHELD-SENTINEL", out_text)
        shown_symbols = {s for g in exp["genes"].values() for s in g["symbols"]}
        for gene in ("DEMO5", "DEMO6", "DEMO7", "DEMO8", "DEMO10", "HGNC:990005", "HGNC:990006", "HGNC:990010"):
            self.assertNotIn(gene, exp["genes"])
            self.assertNotIn(gene, shown_symbols)
            self.assertIsNone(re.search(rf"(?<![A-Za-z0-9:]){gene}(?![A-Za-z0-9])", text), gene)
        self.assertIn("unreviewed", internal)

    def test_public_export_contains_only_approved(self):
        exp, _, _ = self.build()
        for key in ("observations", "claims", "annotations", "studies", "assessments"):
            for rid in exp[key]:
                hist = exp["reviews"][rid]
                self.assertEqual(hist[-1]["decision"], "approve", rid)
        for st in exp["studies"].values():
            self.assertIn(st["scope_category"], M.PERMITTED_SCOPE)

    def test_approved_study_with_excluded_category_is_blocked(self):
        """Even an in-scope review cannot publish a study whose category is excluded."""
        d = self.data()
        for st in d["studies"]:
            if st["id"] == I("st", "st-a"):
                st["scope_category"] = "pathogen"
        self.write(d)
        exp, text, _ = self.build()
        self.assertNotIn(I("st", "st-a"), exp["studies"])
        self.assertNotIn(I("ob", "o1"), text)

    def test_verify_export_catches_leak(self):
        con = B.create_db(self.tmp / "t.sqlite")
        self.addCleanup(con.close)
        coll = M.load(self.coll_dir)
        B.load_db(con, coll)
        exp = B.export(con, coll)
        leaked = copy.deepcopy(exp)
        rec = next(r for r in coll.records("observation") if r["id"] == I("ob", "o9"))
        leaked["observations"][rec["id"]] = rec
        with self.assertRaises(B.BuildError):
            B.verify_export(coll, leaked, {"atlas.json": M.canonical_json(leaked)})
        with self.assertRaises(B.BuildError):
            B.verify_export(coll, exp, {"index.html": "<p>" + I("ob", "o6") + "</p>"})

    def test_stale_outputs_removed(self):
        self.build()
        stale = self.out / "public" / "old.json"
        stale.write_text("{}")
        self.build()
        self.assertFalse(stale.exists())


class TestAssessments(Tmp):
    def test_assessments_reviewed_and_separate(self):
        exp, text, _ = self.build()
        self.assertEqual(set(exp["assessments"]), {I("as", "s1"), I("as", "s2")})
        self.assertIsNone(exp["assessments"][I("as", "s2")]["agreement"])
        self.assertNotIn(I("as", "s3"), text)   # out-of-scope study
        self.assertNotIn(I("as", "s4"), text)   # unreviewed
        g = exp["genes"]["HGNC:990001"]
        self.assertEqual(g["assessments"], sorted([I("as", "s1"), I("as", "s2")]))
        for cl in exp["claims"].values():
            self.assertNotIn("agreement", cl)

    def test_assessment_hidden_when_study_contributes_nothing(self):
        d = self.data()
        d["observations"] = [o for o in d["observations"] if o["analysis_id"] != I("an", "an-b")]
        d["claims"] = [c for c in d["claims"] if c["study_id"] != I("st", "st-b")]
        self.write(d)
        p = self.coll_dir / "reviews.jsonl"
        keep = {o["id"] for o in d["observations"]} | {c["id"] for c in d["claims"]}
        kept, prev = [], M.GENESIS_HASH
        for line in p.read_text().splitlines():
            e = json.loads(line)
            if e["target_type"] in ("observation", "claim") and e["target_id"] not in keep:
                continue
            e["prev_hash"] = prev
            e["entry_hash"] = M.review_entry_hash(e)
            e["id"] = "rv_" + e["entry_hash"][:12]
            prev = e["entry_hash"]
            kept.append(M.canonical_json(e))
        p.write_text("\n".join(kept) + "\n")
        exp, _, _ = self.build()
        self.assertNotIn(I("as", "s2"), exp["assessments"])
        self.assertIn(("assessment", I("as", "s2")), {k for k, v in E.record_reasons(M.load(self.coll_dir)).items()
                                                      if "study_not_displayed" in v})


class TestReviewerPseudonyms(Tmp):
    def test_real_names_not_exported(self):
        exp, text, html = self.build()
        for name in ("reviewer-a", "reviewer-b"):
            self.assertNotIn(name, text)
            self.assertNotIn(name, html)
        names = {r["reviewer"] for h in exp["reviews"].values() for r in h}
        self.assertEqual(names, {"Reviewer 1", "Reviewer 2"})


class TestGeneIdentity(Tmp):
    def test_grouping_by_stable_id(self):
        exp, _, _ = self.build()
        g = exp["genes"]["HGNC:990003"]
        self.assertEqual(g["symbols"], ["DEMO3", "DEMO3B"])
        self.assertEqual(g["gene_id_statuses"], ["mapped", "synonym"])
        self.assertIn("symbol:DEMO2", exp["genes"])
        self.assertIsNone(exp["genes"]["symbol:DEMO2"]["gene_id"])
        self.assertEqual(exp["genes"]["symbol:DEMO9"]["gene_id_statuses"], ["ambiguous"])

    def test_gene_id_validation(self):
        d = self.data()
        d["observations"][0]["gene_id"] = "ENSG000001"
        d["observations"][1]["gene_id_status"] = "unmapped"
        self.write(d)
        self.assertTrue({"bad_gene_id", "gene_id_status"} <= self.codes())

    def test_reference_mapping(self):
        ref = self.tmp / "hgnc.tsv"
        ref.write_text("hgnc_id\tsymbol\tprev_symbol\talias_symbol\n"
                       "HGNC:1\tAAA1\tOLD1\tX1\n"
                       "HGNC:2\tBBB2\t\t\"X1|Y2\"\n"
                       "HGNC:3\tCCC3\tAAA1\t\n")
        r = G.GeneReference(ref, "hgnc", "fixture-2026-11")
        self.assertEqual(r.map("AAA1"), G.Mapping("HGNC:1", "mapped", ("HGNC:1",)))
        self.assertEqual(r.map("OLD1").status, "synonym")
        self.assertEqual(r.map("Y2").gene_id, "HGNC:2")
        self.assertEqual(r.map("X1"), G.Mapping(None, "ambiguous", ("HGNC:1", "HGNC:2")))
        self.assertEqual(r.map("aaa1").status, "unmapped")   # case-sensitive
        self.assertEqual(r.map("ZZZ").status, "unmapped")
        self.assertEqual(r.manifest_entry()["sha256"], M.sha256_file(ref))

    def test_reference_missing_columns_fail(self):
        ref = self.tmp / "bad.tsv"
        ref.write_text("id\tsymbol\nHGNC:1\tAAA1\n")
        with self.assertRaises(ValueError):
            G.GeneReference(ref, "hgnc", "x")


class TestIsolation(unittest.TestCase):
    def test_existing_barcs_files_unchanged(self):
        """Changes on this branch stay inside tools/evidence-atlas/."""
        repo = ROOT.parent.parent
        if os.environ.get("ATLAS_CHECK_ISOLATION") != "1":
            self.skipTest("set ATLAS_CHECK_ISOLATION=1 to check (CI does)")
        base = subprocess.run(["git", "-C", str(repo), "merge-base", "HEAD", "origin/main"],
                              capture_output=True, text=True)
        if base.returncode != 0:
            self.skipTest("origin/main not available")
        changed = subprocess.run(["git", "-C", str(repo), "diff", "--name-only", base.stdout.strip()],
                                 capture_output=True, text=True, check=True).stdout.split()
        untracked = subprocess.run(["git", "-C", str(repo), "ls-files", "--others", "--exclude-standard"],
                                   capture_output=True, text=True, check=True).stdout.split()
        allowed_outside = {".github/workflows/evidence-atlas.yaml"}
        outside = [p for p in changed + untracked
                   if not p.startswith("tools/evidence-atlas/") and p not in allowed_outside]
        self.assertEqual(outside, [])


if __name__ == "__main__":
    unittest.main()
