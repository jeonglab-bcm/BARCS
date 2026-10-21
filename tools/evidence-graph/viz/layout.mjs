// ForceAtlas2 layout of the unified graph, computed once so the map is stable.
//   node viz/layout.mjs build/unified_graph.json build/unified_layout.json
// Frequent hitters and fitness genes are left out of the force layout (they
// would pull unrelated conditions together) and placed at the mean position
// of their neighbours afterwards. Regulatory edges do not shape the layout.
import fs from "node:fs";
import Graph from "graphology";
import forceAtlas2 from "graphology-layout-forceatlas2";

const [input, output] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(input, "utf8"));
const flagged = (n) => n.kind === "gene" && (n.frequent || n.fitness);

let seed = 7;
const rand = () => ((seed = (seed * 1664525 + 1013904223) % 4294967296) / 4294967296);

const g = new Graph({ type: "undirected" });
data.nodes.forEach((n, i) => {
  if (!flagged(n)) g.addNode(i, { x: rand() * 1000, y: rand() * 1000, size: n.kind === "condition" ? 8 : 1 + n.papers });
});
for (const [s, t, type] of data.edges) {
  if (type === "regulates" || !g.hasNode(s) || !g.hasNode(t) || g.hasEdge(s, t)) continue;
  g.addEdge(s, t, { weight: type === "call" ? 1 : 0.5 });
}

// LinLog separates communities; outbound attraction distribution keeps
// conditions with hundreds of calls from collapsing everything around them.
const settings = { ...forceAtlas2.inferSettings(g), barnesHutOptimize: true, linLogMode: true,
  outboundAttractionDistribution: true, strongGravityMode: false, gravity: 1, scalingRatio: 4,
  edgeWeightInfluence: 1, adjustSizes: false };
console.time("forceatlas2");
forceAtlas2.assign(g, { iterations: 900, settings });
console.timeEnd("forceatlas2");

const pos = data.nodes.map((n, i) => (g.hasNode(i) ? [g.getNodeAttribute(i, "x"), g.getNodeAttribute(i, "y")] : null));
const nbrs = data.nodes.map(() => []);
for (const [s, t, type] of data.edges) {
  if (type === "regulates") continue;
  nbrs[s].push(t); nbrs[t].push(s);
}
data.nodes.forEach((n, i) => {
  if (pos[i]) return;
  const placed = nbrs[i].filter((j) => pos[j]);
  const mx = placed.reduce((a, j) => a + pos[j][0], 0) / Math.max(1, placed.length);
  const my = placed.reduce((a, j) => a + pos[j][1], 0) / Math.max(1, placed.length);
  pos[i] = [mx + (rand() - 0.5) * 30, my + (rand() - 0.5) * 30];
});
// A few isolated components fly far out and would shrink the initial view;
// pull anything beyond the 99.5th-percentile radius back onto that circle.
const cx = pos.reduce((a, p) => a + p[0], 0) / pos.length, cy = pos.reduce((a, p) => a + p[1], 0) / pos.length;
const radii = pos.map(([x, y]) => Math.hypot(x - cx, y - cy)).sort((a, b) => a - b);
const rmax = radii[Math.floor(radii.length * 0.995)];
pos.forEach((p, i) => {
  const r = Math.hypot(p[0] - cx, p[1] - cy);
  if (r > rmax) pos[i] = [cx + (p[0] - cx) * rmax / r, cy + (p[1] - cy) * rmax / r];
});
fs.writeFileSync(output,JSON.stringify(pos.map(([x, y]) => [Math.round(x * 10) / 10, Math.round(y * 10) / 10])));
console.log(`placed ${pos.length} nodes (${data.nodes.filter(flagged).length} by neighbour mean)`);
