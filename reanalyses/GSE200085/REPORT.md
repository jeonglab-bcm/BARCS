# GSE200085 — In vivo genome-wide knockout screen of SC-islet grafts under allogeneic rejection

**Paper.** Sintov E et al., Whole-genome CRISPR screening identifies genetic
manipulations to reduce immune rejection of stem cell-derived islets.
*Stem Cell Reports* 2022 (PMID 36055241, doi 10.1016/j.stemcr.2022.08.002).

**Screen.** hESC-derived SC-islets transduced with Brunello (Cas9 in the same
vector) were grafted under the kidney capsule of NSG-MHC-null mice; six mice
then received allogeneic human PBMCs (hPi grafts), six did not. Grafts were
recovered 10 weeks later. Knockouts that let cells escape rejection should be
enriched in hPi grafts. The paper fit a negative-binomial mixed model per gene
(log counts ~ KO x PBMC with random effects for mouse and guide, likelihood
ratio test against the non-targeting guides), filtered genes by scRNA-seq
expression, and reports 11,689 genes in Data S1 (150 enriched and 253 depleted
at FDR 0.10). Named hits: CXCL10 (top gene, validated as a knockout line), B2M,
HLA-A, TAP1/2, STAT1, JAK1/2; PTPRA depleted.

**Input.** GEO lists one sample (GSM6008413); its RAW tar holds the PoolQ
table with one column per graft. prepare.R downloads the tar, takes the
condition-level counts (barcodes already summed) and labels guides from
another GEO deposit of the same Brunello library (GSE226447, joined on
sequence; all 77,441 matched). Ms #79 (hPi) is left out: 42,430 reads, 78%
zeros, correlation at most 0.22 with every other library (a failed library);
the pre-transplant, NTC and plasmid libraries are also not used.

**Design.** `~ condition`, hPi (Ms 65/67/68/72/76) vs control grafts (Ms
64/69/70/73/74/78), 9 residual df. The paper modelled counts relative to the
non-targeting guides and rejection removes cells from hPi grafts, so totals
are taken from the non-targeting controls (`totals: control`). Each mouse is
its own library and mice are not paired across arms. Composition is near
normal after NT normalization (NT guides hold 2.3-2.8% of reads in every
library); guide correlation 0; controls well calibrated (5.8% at p < 0.05).

**Results.** 1 gene at FDR 0.10 (PPP6C, depleted), 0 against the control null.
BARCS does not reproduce the paper's enriched immune-evasion hits: CXCL10 ranks
1,181 (estimate +0.43, p 0.19), STAT1 51 (p 0.01 but FDR 0.57), and B2M,
HLA-A, TAP1/2, JAK1/2 are all unranked. The raw NT-normalized counts show why:
for CXCL10 only two of four guides rise in some hPi mice (one guide 106-6081 in
controls, 204-5560 in hPi) while the others are flat, and B2M/HLA-A/TAP guides
swing between 0 and a few hundred reads across the six mice of each arm with no
consistent hPi shift. With that mouse-to-mouse spread and 9 residual df,
BARCS's per-guide negative-binomial test calls almost nothing.

**Agreement.** Despite the empty hit list, the gene scores agree in rank:
Spearman 0.89 with the paper's signed score across 11,225 shared genes, and
84.8% direction agreement. The difference is the significance model: the paper
pools variance in a mixed model with random guide and mouse effects and an
scRNA-seq expression filter, which gives it power to call CXCL10 and the
antigen-presentation genes; BARCS tests each guide independently and treats the
large between-mouse variance as noise, so the same genes rank near the top of
the list but miss FDR.

**Limits.** In vivo screen with high between-animal variation and incomplete
rejection (residual cells remain), one PoolQ table per condition, and strong
dropout (many guides at or near zero in individual grafts). The screen is
interpretable at the ranked-list level but BARCS's gene calls are essentially
empty; the paper's own calls depend on a bespoke mixed model and a separate
expression filter that BARCS does not apply.
