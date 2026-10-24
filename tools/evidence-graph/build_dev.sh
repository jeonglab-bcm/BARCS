#!/bin/sh
# Build the developmental-biology evidence graph: the same pipeline as
# build.sh, restricted to the screens listed in curation/developmental_screens.tsv.
#   tools/evidence-graph/build_dev.sh   (run build.sh once first for the STRING files)
# The pathway map keeps pairs co-hit in 2+ papers without the per-pair test
# (too few papers for it) and reports a shuffled-hit control instead.
# Writes reports/development/ and viz/pathways_dev.json, then re-exports the main
# page, whose "developmental biology screens" filter shows this map.
set -e
cd "$(dirname "$0")"
BARCS="$(cd "${BARCS:-../..}" && pwd)"
[ -f build/string_v12.5/9606.protein.info.v12.5.txt.gz ] || { echo "Run build.sh first (STRING files)."; exit 1; }

# A reanalyses/ tree holding only the developmental records.
root=build/dev_root
rm -rf "$root" && mkdir -p "$root/reanalyses"
tail -n +2 curation/developmental_screens.tsv | cut -f1 | while read -r gse; do
  [ -d "$BARCS/reanalyses/$gse" ] || { echo "missing record: $gse"; exit 1; }
  ln -s "$BARCS/reanalyses/$gse" "$root/reanalyses/$gse"
done
n=$(ls "$root/reanalyses" | wc -l | tr -d ' ')
papers=$(cat "$root"/reanalyses/*/meta.json | grep -o '"pmid": *"[0-9]*"' | sort -u | wc -l | tr -d ' ')

mkdir -p build/dev reports/development
ln -sfn "$(pwd)/build/reference" build/dev/reference
uv run python -m barcs_kg.ingest "$root" build/dev/barcs_kg.sqlite
uv run python -m barcs_kg.annotate build/dev/barcs_kg.sqlite
uv run python -m barcs_kg.string_db build/dev/barcs_kg.sqlite build/string_v12.5
EVIDENCE_MIN_TESTED=0 EVIDENCE_MAX_HIT_FRACTION=1 uv run python -m barcs_kg.analyses build/dev/barcs_kg.sqlite reports/development > /dev/null
EVIDENCE_MIN_TESTED=0 EVIDENCE_MAX_HIT_FRACTION=1 PATHWAYS_PAIR_TEST=off uv run python -m barcs_kg.pathways build/dev/barcs_kg.sqlite reports/development build/string_v12.5 viz/pathways_dev.json > /dev/null
uv run python -m barcs_kg.export_viz build/barcs_kg.sqlite reports viz
echo "developmental pathway map: $n screens, $papers papers -> viz/pathways_dev.json"
