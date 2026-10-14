# GSE288238 reanalysis with BARCS 0.2.3

**Paper.** "A genome-wide map of the genetic network in monocytes that regulates type I interferon induction by the cGAS-STING pathway", *Science Signaling* 2026, PMID 42611972 (doi 10.1126/scisignal.adx3808; not open access). Only the abstract and the GEO record could be read; the paper's gene-level statistics are not available, so the comparison rests on the genes the abstract names.

**Screen.** Genome-wide MinLibCas9 knockout (37,686 guides, 2 per gene, 18,754 genes, **no non-targeting guides**) in two THP-1 IFNB1-GFP reporter clones (B6, C3; matched to GEO "IBER Clone 1" and "Clone 2" by GSM order, which GEO does not state), each screened twice, stimulated with cGAMP either unprimed or after IFN-a priming, and sorted into GFP-negative and GFP-high (top 5% when primed) populations. Raw integer counts for all 25 libraries are in `GSE288238_IBER_reads.csv.gz`; column names match the GSM titles. STING (TMEM173) guides are 10-30 times higher in GFP-negative than GFP-high sorts, which confirms the bin labels.

**Design.** For each arm, GFP-negative vs GFP-high, `~ culture + bin` with culture = clone x repeat (each negative sort paired with the high sort from the same culture), 4 vs 4, 3 residual df. Positive regulators of IFNB1 induction are enriched in GFP-negative. Library totals; composition is unselected (top 1% of guides hold 3-8% of reads). Unprimed is the primary analysis (`comparison.md`), primed the second (`comparison_primed.md`).

**No controls.** The library has no non-targeting guides, so the false-positive rate could not be checked or calibrated and there is no control null: the FDR rests on the model alone. The sorted libraries are sparse (1.6-17 M reads on 37.7k guides; 8-22% zero guides in the primed sorts and 39% in B6 unprimed GFP-negative repeat 1), and 286 (unprimed) and 3,658 (primed) guides were tested by likelihood ratio. As a sensitivity check, `design_mtc150.json` raises `min_total_count` from 30 to 150: unprimed 14 genes (same list), primed 121 instead of 150.

## Results
- **Unprimed:** 14 genes at FDR 0.10 (11 enriched in GFP-negative). STING (TMEM173) #1 and TBK1 #2, then EIF4E2, MAP3K7 (TAK1), RNMT, SYNCRIP and **TBL1XR1 #7 (FDR 0.033)**. IRF3 ranks #33 (FDR 0.34). **HDAC3 ranks #164 (FDR 0.69)**: its guides are noisy across cultures (for example 0 vs 53 and 383 vs 150 reads in B6).
- **Primed:** 150 genes at FDR 0.10 (126 enriched in GFP-negative). STING #1; **HDAC3 #114 (FDR 0.092; 0.10 at min_total_count 150)**, TBL1XR1 #187 (FDR 0.18), TBK1 #348 (FDR 0.31). The top of the primed list is dominated by mRNA capping, transcription and ESCRT genes (CMTR1, RNGTT, POLR1A, CDK9, CHMP7, PCBP1), whose guides are present in every GFP-negative sort and absent from all four GFP-high sorts; they are consistent across both guides and all cultures, not single-guide jackpots, but some may reflect cells unable to express any reporter rather than IFN-specific regulation.

## BARCS vs paper
The paper names the NCoR/SMRT components TBL1XR1 and HDAC3 as cooperating positive regulators of IFNB1 induction and finds distinct regulators in the unprimed and primed states. BARCS calls TBL1XR1 in the unprimed screen and HDAC3 (borderline) in the primed screen, each passing FDR 0.10 in one arm only, and recovers STING and TBK1 as the strongest unprimed hits. NCOR1 and NCOR2 do not pass in either arm (best FDR 0.50). Without the paper's tables, overlap beyond the named genes could not be measured.

## Limits
No non-targeting controls: FDR not calibrated. Sparse sorted libraries. Clone-to-GSM mapping by GSM order. Paper text not available, so which arm the paper drew TBL1XR1 and HDAC3 from could not be checked.
