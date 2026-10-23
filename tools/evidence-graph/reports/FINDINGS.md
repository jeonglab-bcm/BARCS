# BARCS evidence graph: what the screens support, and what we are missing

Build of 2026-10-20 from BARCS commit `9ce6f83`, STRING v12.5, Hart CEGv2.
Every number below comes from a TSV in this folder; rerun `tools/evidence-graph/build.sh` to reproduce it.

## 1. The data is much richer than the prototype assumed

The prototype graph held 39 series, 116 genes, 129 curated edges and no STRING
edges. It assumed per-screen gene tables "still require extraction". In fact the
BARCS repo already holds them, with every tested element and not only the hits.

| | Prototype | This build |
|---|---|---|
| Series / papers | 39 | 122 / 109 |
| Contrasts | – | 256 (255 with results) |
| Gene-level results | 129 edges | 2,423,615 (86,609 at FDR < 0.10) |
| Paper-named genes | – | 930 |
| STRING edges | 0 | 0.96 M physical, 1.0 M functional, 0.21 M directed regulatory (4 species) |

Other organisms in the data: human (92 series), mouse (21), *Toxoplasma* (5),
cattle (2), rat (1) and *Bacteroides* (1). Elements other than genes: 21.7k
TSS-specific promoters, 17k miRNAs, 33k lncRNAs, 1.9k regulatory regions, and
gene pairs. 409 gene names in 25 deposited tables are Excel-mangled ("Sep-04"
for SEPTIN4); 377 were recovered.

## 2. Findings the graph can already support

**a. A few contrasts carry most of the hits.** 59 contrasts call more than 10% of
the elements they test, and they hold 68% of all hits. The extreme case is
GSE291338 venetoclax vs DMSO, which calls 74% of 17,964 genes, has no control
guides and has 94% of reads on 1% of guides. Any "shared hits" count that does
not correct for this measures those contrasts and not biology. The cross-screen
analyses below therefore use 144 *eligible* contrasts: ≥1,000 elements tested
and ≤10% called.

**b. Whether a paper's named gene is supported depends on the design more than on the biology.**

| | Supported (FDR < 0.10) | Borderline (< 0.25) | Not supported | Not tested |
|---|---|---|---|---|
| All 930 claims | 585 | 64 | 271 | 10 |
| In contrasts calling > 10% of genes | 217 / 256 (85%) | | | |
| In eligible contrasts | 332 / 565 (59%) | 36 | 192 | 5 |
| 0 residual df | 80 / 178 | 8 | 90 (51%) | |
| ≥ 2 residual df | 431 / 630 | 38 | 161 (26%) | |

84 "not supported" claims sit in contrasts where BARCS calls nothing at all.
Those are a lack of power, not a contradiction. The real disagreements are
the 84 non-supported claims in contrasts with ≥2 residual df, some calls, and
≤10% called (`claim_audit.tsv`). None of the 930 claims records the direction
the paper reported, so sign agreement cannot be checked for any of them.

**c. Fitness leaks into non-fitness contrasts.** In 45 of 137 sort, drug,
co-culture and in vivo contrasts, ≥25% of hits are fitness genes (CEGv2 ∪
genes depleted in ≥3 BARCS fitness papers), well above their share of the
library (`fitness_confound.tsv`). Examples: Vγ9Vδ2 killing (GSE192828, 43% vs
7%), OT-I restimulation (GSE251758, 40% vs 6%), MRTX849+TNO155 (GSE240110,
37% vs 7%). Across the whole library, 26 of 99 eligible human contrasts
rank-correlate with a per-gene fitness score at |ρ| > 0.1 (`fitness_correlation.tsv`). MRTX849 vs DMSO is
the strongest at +0.32. Two coherent "modules" are made only of essential
genes: GSE264535 GFP-low has z = 55, which falls to −0.1 once fitness genes
are removed.

**d. Some genes are hit across many unrelated screens.** 266 human proteins are
called in more papers than each paper's own hit rate predicts (Poisson,
q < 0.05, in ≥3 assay classes; `recurrence.tsv`). The top of the list is
SAGA (TADA1 in 13/47 papers vs 0.9 expected, TADA2B, TAF5L, TAF6L, SUPT20H),
SWI/SNF (ARID1A, SMARCB1, BPTF), the Mediator kinase module (MED12, CCNC),
STAG2, AHR, PTEN, MYC and TFAP4. *Interpretation (hypothesis):* most of these
act as screen-generic modifiers, of reporter or transgene expression or of
growth, rather than as regulators of each phenotype. A claim that "X regulates
phenotype Y" needs that context. The tools attach it as a flag.

**e. Independent screens converge where they should.** Two CD25 screens from
different papers (GSE171674, GSE242880) share 70 hits (p = 4e-55). Two mouse
tumour/T-cell co-culture screens converge on B2m, Ifngr1/2, Jak1/2, Tap1/2 and
Tapbp. Taken at scale, though, 434 of 989 cross-paper pairs are "significant"
even after fitness genes and frequent hitters are removed. The hypergeometric
null is too permissive, so treat `convergence.tsv` as a ranking, not as a test.

**f. Hits form STRING modules beyond essential complexes.** 103 of 156 contrasts
have hits more physically connected (STRING ≥700) than degree-matched random
sets from their own library. 49 of 100 eligible non-fitness contrasts stay at
z > 3 with fitness genes removed (`network_coherence.tsv`).

**g. There are strong hits the papers did not name.** 14,512 strict hits
(FDR < 0.05) in eligible contrasts are not in the paper's named list, and 562
of them rank in their contrast's top 10. Keeping only leads that rank in the
top 25, are neither fitness genes nor frequent hitters, and either link to a
named gene by STRING with experimental or database evidence or sit in a hit
module leaves **316 leads in 63 contrasts** (`priority_unreported.tsv`).
Examples:

- Atf7ip (rank 1) with Setdb1 in H3K9me3 establishment (GSE212152)
- Cbx1 with Ehmt2/Suv39h1 in the same screen
- SLX4 with MSH2 under FdU (GSE282260)
- H2-D1 and Jak2 with B2m/Jak1 in T-cell co-culture (GSE267517)
- SOCS1 under GSI (GSE221576)
- ESR1 with CREBBP under cytotoxic T cells (GSE316985)
- ARF1 in both PTAR1 genetic-interaction screens (GSE298081/2)

Caveat: "named" means the short `named_hits` list in `compare.json`. Several
of these leads, Atf7ip for one, are probably discussed in the paper's text,
so "unreported" means "not in our claim list" and not "novel".

## 3. What we are missing

Ordered by how much each item would unlock.

1. **Readout semantics for each contrast (0 of 256 curated).** Without "what
   does more guide abundance in this arm mean for the phenotype", no sign-aware
   statement is possible, such as "loss of X increases resistance". The design
   already gives the orientation; the meaning has to be curated.
   `interpret_perturbation_effect` abstains until it is.
   Template: `curation/contrast_readout.template.tsv`.
2. **Claim direction and the paper's full tables.** 0 of 930 claims carry a
   direction. 116 comparison specs already point to the paper's full
   gene-level table, built by each record's `prepare.R`. Importing those would
   turn the claim layer from 930 names into genome-wide concordance and expose
   paper hits that BARCS misses.
3. **A context prior for each gene.** Frequent hitters (2d) and fitness (2c)
   should become a per-gene, per-assay-class propensity estimated from all
   122 reanalyses, a "CRISPR CRAPome". That would also replace the
   hypergeometric null in 2e. The fitness prior also needs a continuous
   per-gene fitness covariate, not a binary essential list. DepMap was not
   reachable from this machine, so CEGv2 stands in.
4. **Library identity and guide-level results.** The repo archives gene tables
   only, without guide counts or standard errors. Shared hits cannot be told
   apart from shared guides (two Brie or Brunello screens), and the "show the
   raw counts" check that AGENT.md asks for cannot be run from the graph.
5. **Power as data.** 65 contrasts have 0 residual df, 24 have 1, 42 have no
   control guides, 53 have composition skew, and 33 call nothing
   (`contrast_flags.tsv`). Tools report these, but "tested and not called" is
   still a single bucket rather than a power estimate.
6. **Identity beyond protein-coding genes and beyond two species.** miRNA,
   lncRNA, regulatory-region and peak elements have no node to join (RNAcentral
   or ENCODE cCREs would supply one). *Toxoplasma* GT1 IDs do not map to
   STRING, which has only the VEG strain. Mouse joins human by identical
   symbol, which is crude; HCOP or eggNOG orthology would be better. About 17%
   of human symbols do not map, mostly non-coding genes and controls.
7. **Hand-checked annotations.** Organism, modality and selection class come
   from rules plus 13 manual overrides, spot-checked but not curated.

## Strongest reason this may be wrong

Sections 2c, 2d and 2g rest on two choices: rule-based selection classes and
the FDR < 0.10 hit threshold, in a corpus where call rates vary 1000-fold
between contrasts. A rank-based hit definition, such as the top 1% per
contrast, could reorder the frequent-hitter and lead lists. The direction of
the findings (load imbalance, fitness leakage, generic modifiers) is robust to
that; the specific gene lists are not.
