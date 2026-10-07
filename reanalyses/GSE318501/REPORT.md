# GSE318501 reanalysis with BARCS 0.2.1

**Paper.** "Genome-Wide CRISPR Screen Identifies a microRNA Orchestrating Pleiotropic Resistance to Targeted Therapy and T Cell Immunity in Melanoma", *Advanced Science* (2026), PMID 42189126, doi:10.1002/advs.202515158 (PMC13335869). The supplements contain the library only, not results.

**Screen.** A375 cells with a miRNA knockout library (8,093 guides, 2,119 miRNAs, no non-targeting controls). Vemurafenib vs control at day 23, 3 replicates each.

**Design.** `~ treatment`, 6 libraries, 4 residual df, median-ratio totals. Resistance (miR-18a loss) should be enriched under vemurafenib.

## Normalization matters here

The top 1% of guides hold 25–31% of reads in vemurafenib libraries, against 5% in controls.

| Totals | miRNAs at FDR 0.10 | mir-18a |
|---|---|---|
| Library | 1,765 (1,743 depleted) | rank 1,415, effect +0.10 |
| Median-ratio | 446 | **rank 3**, effect +0.51, FDR 2 × 10⁻⁸ |

With library totals, the expansion of resistant clones makes the typical guide look depleted. miR-18a's real enrichment then looks almost neutral. Median-ratio totals re-center on the typical guide.

## Where BARCS agrees and differs

- **Agrees.** miR-18a is the third strongest enriched miRNA, behind miR-6884 and miR-7-3.
- **Uncertain.** The other top hits (miR-6884, miR-10398, miR-3136, miR-25) are not discussed in the abstract, and no gene-level table was published to compare against.

## Limits

- There are no non-targeting controls, so median-ratio over all guides assumes most miRNA knockouts are neutral.
- Replicate pairing between the arms is not documented.
