# BARCS reanalyses

Published pooled CRISPR screens reanalyzed with BARCS from public counts, and how each result compares with what the paper reported.

## Language

### Screens and records

**Candidate series**:
A GEO series found by the PubMed search that looks like a pooled CRISPR screen and has not been triaged yet.
_Avoid_: hit, result, pending screen

**Reanalysis record**:
One published screen reanalyzed with BARCS and archived under `reanalyses/<GSE>/`, reproducible from public data.
_Avoid_: run, result, reanalysis (for the folder)

**Excluded series**:
A candidate series checked and not reanalyzed, with a one-sentence reason.
_Avoid_: skipped, rejected

**Search window**:
The span of publication dates the PubMed search covered; a window is fully triaged when every candidate series in it is a reanalysis record or an excluded series.
_Avoid_: batch, period

### Comparison with the paper

**Main comparison**:
The contrast the paper's headline conclusion rests on (for example drug versus vehicle, or end point versus T0), which the reanalysis must reproduce first.
_Avoid_: main contrast, primary analysis

**Named hits**:
The genes the paper itself puts forward as its screen's findings, in the title, abstract, or validation experiments.
_Avoid_: top genes, published hits, main hits

**Agreement**:
How a reanalysis record's BARCS calls compare with the paper: `agree` (the named hits pass FDR 0.10 in BARCS), `partial` (some do), or `differ` (none do, or BARCS contradicts them).
_Avoid_: concordance, verdict (the verdict is the one-sentence explanation)

**Verdict**:
The one-sentence statement of where BARCS and the paper agree and differ for a reanalysis record.
_Avoid_: summary, conclusion

**Disagreement reason**:
The coded explanation of why a `partial` or `differ` record parts from the paper.
_Avoid_: failure reason, cause

### Review

**Validation**:
A person's audit of a reanalysis record's inputs: that it reproduces the main comparison, that its named hits are the paper's, that it compares against the paper's own results table, and that its agreement follows from the rule. Validation corrects inputs and reruns; it never overrides the rule by judgment.
_Avoid_: manual check, curation, review
