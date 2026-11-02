#!/bin/sh
# Rebuild the evidence graph, the gap reports and the explorer page from this
# repository's reanalyses/.
#   tools/evidence-graph/build.sh      (downloads STRING v12.5 and CEGv2 on first run)
set -e
cd "$(dirname "$0")"
BARCS="${BARCS:-../..}"
if [ ! -f build/string_v12.5/9606.protein.info.v12.5.txt.gz ]; then
  mkdir -p build/string_v12.5
  for t in 9606 10090 10116 9913; do
    for f in protein.info protein.aliases protein.physical.links.detailed protein.links.detailed \
             protein.regulatory.links.detailed protein.regulatory.events; do
      echo "https://stringdb-downloads.org/download/$f.v12.5/$t.$f.v12.5.txt.gz"
    done
  done | (cd build/string_v12.5 && xargs -P 6 -n 1 curl -s -f -O --retry 3)
fi
[ -f build/string_v12.5/9606.protein.enrichment.terms.v12.5.txt.gz ] || curl -s -f -o build/string_v12.5/9606.protein.enrichment.terms.v12.5.txt.gz \
  https://stringdb-downloads.org/download/protein.enrichment.terms.v12.5/9606.protein.enrichment.terms.v12.5.txt.gz
mkdir -p build/reference
[ -f build/reference/CEGv2.txt ] || curl -s -f -o build/reference/CEGv2.txt https://raw.githubusercontent.com/hart-lab/bagel/master/CEGv2.txt
[ -f build/reference/biolink-model-4.4.6.yaml ] || curl -s -f -o build/reference/biolink-model-4.4.6.yaml \
  https://raw.githubusercontent.com/biolink/biolink-model/v4.4.6/biolink-model.yaml
uv run python -m barcs_kg.ingest "$BARCS" build/barcs_kg.sqlite
uv run python -m barcs_kg.annotate build/barcs_kg.sqlite
uv run python -m barcs_kg.string_db build/barcs_kg.sqlite build/string_v12.5
uv run python -m barcs_kg.analyses build/barcs_kg.sqlite reports > /dev/null
uv run python -m barcs_kg.export_biolink build/barcs_kg.sqlite build/string_v12.5 \
  build/reference/biolink-model-4.4.6.yaml build/biolink > /dev/null

uv run python -m barcs_kg.unified build build/barcs_kg.sqlite reports build/unified_graph.json
[ -d viz/node_modules ] || (cd viz && npm install --no-audit --no-fund --silent)
node viz/layout.mjs build/unified_graph.json build/unified_layout.json
uv run python -m barcs_kg.unified graphml build/unified_graph.json build/unified_layout.json build/unified_graph.graphml
uv run python -m barcs_kg.pathways build/barcs_kg.sqlite reports build/string_v12.5 viz/pathways.json > /dev/null
uv run python -m barcs_kg.export_viz build/barcs_kg.sqlite reports viz
echo "graph: build/barcs_kg.sqlite   biolink KG: build/biolink/   reports: reports/   explorer: viz/explorer.html"
