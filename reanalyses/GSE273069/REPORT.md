# GSE273069 reanalysis with BARCS 0.2.1

**Paper.** "Reporter CRISPR screens decipher cis-regulatory and trans-regulatory principles at the Xist locus", *Nature Structural & Molecular Biology* (2025), PMID 41053217 (PMC12700789). This is the reporter companion to GSE273070.

**Screen.** CRISPRi of transcription-factor promoters (1,263 guides, 142 promoters, 100 non-targeting) in mouse ES cells. The cells carry a GFP reporter driven by RE57M, a promoter-proximal Xist regulatory element, and were sorted into GFP-high and GFP-low bins in three replicates.

**Design.** `~ replicate + bin`, GFP-low vs GFP-high, 6 libraries, 2 residual df. Each replicate was sorted from one culture.

**Calibration.** 15% of non-targeting guides reached p < 0.05 before calibration, so the test was calibrated to them (5% after).

## Results

| | Value |
|---|---|
| Promoters at FDR 0.10 | 95 |
| Pou5f1_p1 | #3, enriched in GFP-low, FDR 4 × 10⁻⁶³ |
| Zic3_p1 | #5, enriched in GFP-low, FDR 7 × 10⁻³⁸ |
| Top 2 | FIREWACh and RE57: guides against the reporter construct itself (positive controls) |

## Where BARCS agrees and differs

- **Agrees.** The two activators the paper names for promoter-proximal elements rank directly behind the reporter's own controls.
- **Calibration.** The raw model was too optimistic on this sort screen. After calibration, 95 of 142 promoters still pass FDR 0.10. That is a large share, but the library is focused on transcription factors chosen as candidates.

## Limits

- One of the 11 reporter lines was reanalyzed.
- The deposited header repeats RE61 and omits RE85; neither is used here.
