# GSE263582 reanalysis with BARCS 0.2.3

**Paper.** Wang et al., "Forward genetic screening in engineered colorectal cancer organoids identifies novel regulators of metastasis", *Proceedings of the National Academy of Sciences* 122 (2025), PMID 41218116, doi:10.1073/pnas.2510910122 (PMC12646219, open access). This series is one of three deposited knockout-screening sub-datasets (GSE263580/581/582).

**Screen.** Engineered APC-KO / TRP53-KO / KRAS-G12D mouse colorectal cancer organoids were transduced with the 60-guide validation pool (17 genes, 15 safe + 15 none controls), implanted orthotopically, and primary tumors and metastatic lesions harvested after 5-6 weeks. This series: **5 primary tumors and 10 metastatic lesions** (liver, lymph node, intestine, peritoneal), raw integer counts, `safe`/`none` non-targeting controls. The paper searched for **metastasis suppressors** whose loss promotes dissemination — guides ENRICHED in metastases vs primary tumors — and validated **Ctnna1** and **Bcl2l13**.

## Caveat for this series (clonal dominance)

Each metastatic lesion is a **clonal outgrowth** seeded by one or a few disseminating cells. The counts confirm this directly: in many lesions the top 1% of guides hold **99-100% of reads**, and median-ratio size factors are capped (single guides hold most of a library). The biological signal the paper uses is **recurrence of the same gene across independent lesions**, not a smooth abundance shift with measurable between-replicate variance. **Lesion-level clonal dominance violates BARCS's replicate-variance model**, so the gene-level FDRs here are not trustworthy and the results are **descriptive only** — depletion is uninterpretable (a guide absent from a clonal lesion is dropout, not selection), and even enrichment is dominated by which clone happened to seed each lesion.

## Results (metastasis vs primary; enrichment = metastasis-promoting knockout)

- Top genes by enrichment: Nupr1, Rad50, Kpna2, Pnpla3, Oas1g.
- Paper's validated suppressors: Bcl2l13 present (rank 6/6 enriched, FDR 0.78); Ctnna1 not in this validation pool.
- With library totals the composition warning fires (top 1% of guides hold ~99-100% of reads in some lesions); with median-ratio totals the size factors are capped, so neither normalization supports calibrated calls.

## Where BARCS agrees and differs

- **Differs / descriptive.** BARCS does not recover Ctnna1 or Bcl2l13 at FDR 0.10. This is expected and is the point of the caveat: the paper identified these genes by their **recurrence across many independent clonal lesions** (and functional validation), a signal that a per-library abundance model with a replicate-variance assumption cannot represent when each lesion is dominated by one clone. The enriched genes BARCS ranks highest reflect whichever guides expanded in individual lesions, not a reproducible selection gradient.
- The reanalysis is therefore reported as a **descriptive** pass confirming that these counts are clonal and cannot be analyzed as a conventional replicate-variance screen, consistent with the paper using recurrence-based rather than variance-based statistics.

## Limits

- Clonal lesions: 99-100% of reads on the top 1% of guides in several libraries; median-ratio totals capped.
- Replicate-variance model does not apply; FDRs are nominal, results descriptive.
- Depletion is uninterpretable (dropout vs selection indistinguishable in a clone).
