---
author: Bin He
date: 14 sep 2017
---

## Summary

This is batch 1 of the RNA-seq time-course experiment. In this batch, the goal is to work through the RNA extraction and library prep protocol.

## Sample

S29-36, late time points in the time-course, high OD thus have back up vials

## Results

- RNA extraction worked fine.
- Library prep using Ethanomics TruSeq stranded mRNA 1/3 protocol worked fine.
	- did 12 cycles of pcr and got between 30 and 130 ng/uL in 9 uL volume.
	- Bioanalyzer shows that the fragment size has a peak at around 270 bp.
- Completed all 40 samples using the same protocol
        - the 1/3 protocol doesn't scale up very well. The small volume makes any step involving resuspending magnetic beads very challenging
	- Used 20 adapter indices, split the 40 samples into two pools
- Submit to LSI sequencing core
        - They no longer do separate lanes on a rapid flow cell. Only the combined mode (300M reads output) is supported. Cost is $1590 per run. I need two of them!

## Conclusion

- Use the 1/3 protocol on no more than 16 samples at any time
- Epicentre RNA extraction kit is super. Stick to it. The 100 rxn kit seems to have enough reagent for 200 extractions. The components are very sturdy (most are stored RT, Prot. K is at -20, but the enzyme is very stable to freeze-thaw).
