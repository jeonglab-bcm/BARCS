#!/bin/sh
# Build one pathway map per biology area in curation/screen_areas.tsv, each on
# that area's screens alone (its own growth genes, frequent hitters and pair counts).
#   tools/evidence-graph/build_areas.sh   (run build.sh once first)
# Each area takes the first of these settings that gives a map:
#   main   the main build's eligibility and per-pair test (needs 10+ eligible papers)
#   small  focused libraries allowed (no 1,000-gene minimum), still at most 10% called;
#          pairs co-hit in 2+ papers without the per-pair test, with a shuffled-hit control
#   loose  as small, and contrasts calling over 10% allowed (weakest; read the control)
# Writes viz/pathways_<area>.json, then re-exports the main page, whose area
# filter shows these maps.
set -e
cd "$(dirname "$0")"
BARCS="$(cd "${BARCS:-../..}" && pwd)"
[ -f build/barcs_kg.sqlite ] || { echo "Run build.sh first."; exit 1; }
rm -f viz/pathways_*.json

for area in $(grep -v '^#' curation/screen_areas.tsv | tail -n +2 | cut -f2 | sort -u); do
  root=build/areas/$area/root
  rm -rf "build/areas/$area" && mkdir -p "$root/reanalyses" "build/areas/$area/reports"
  grep -v '^#' curation/screen_areas.tsv | awk -F'\t' -v a="$area" '$2 == a {print $1}' | while read -r gse; do
    [ -d "$BARCS/reanalyses/$gse" ] || { echo "missing record: $gse"; exit 1; }
    ln -s "$BARCS/reanalyses/$gse" "$root/reanalyses/$gse"
  done

  db=build/areas/$area/barcs_kg.sqlite reports=build/areas/$area/reports
  ln -sfn "$(pwd)/build/reference" "build/areas/$area/reference"
  uv run python -m barcs_kg.ingest "$root" "$db" > /dev/null
  uv run python -m barcs_kg.annotate "$db" > /dev/null
  uv run python -m barcs_kg.string_db "$db" build/string_v12.5 > /dev/null
  for pass in main small loose; do
    case $pass in
      main)  set -- ;;
      small) set -- EVIDENCE_MIN_TESTED=0 PATHWAYS_PAIR_TEST=off ;;
      loose) set -- EVIDENCE_MIN_TESTED=0 EVIDENCE_MAX_HIT_FRACTION=1 PATHWAYS_PAIR_TEST=off ;;
    esac
    env "$@" uv run python -m barcs_kg.analyses "$db" "$reports" > /dev/null
    env "$@" uv run python -m barcs_kg.pathways "$db" "$reports" build/string_v12.5 "viz/pathways_$area.json" > /dev/null
    read -r eligible modules <<EOT
$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d['params']['papers'], len(d['modules']))" "viz/pathways_$area.json")
EOT
    case $pass in main) [ "$eligible" -ge 10 ] && break ;; *) [ "$modules" -gt 0 ] && break ;; esac
  done
  echo "$area: $(ls "$root/reanalyses" | wc -l | tr -d ' ') series, $eligible papers in the map, $modules modules ($pass)"
done
uv run python -m barcs_kg.export_viz build/barcs_kg.sqlite reports viz
