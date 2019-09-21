---
title: Analyze CgPho4 DNA preference at flanking nucleotides
input: binding peak coordinates for CgPho4 in Sc and Cg genomes
output: DNA sequence under the peaks => nucleotide frequencies at flanking sites
author: Bin He
created: 16 mai 2017
---

# Background

bHLH TFs recognize beyond the core CACGTG motif -- it’s the flanking nucleotides that distinguish between different TFs of this family.  In S. cerevisiae, the sequence preference of Pho4 vs Cbf1, another bHLH factor, have been studied in depth both in vitro (Maerkl & Quake 2007) as well as in vivo (Zhou & O’Shea 2011) 

* Maerkl & Quake (2007) found that Pho4 prefers CC / GG as N~-5~N~-4~, that is, CCCACGTGGG or GGCACGTGCC. By contrast, Cbf1 strongly prefers GT at N~-5~N~-4~ 
* Zhou & O’Shea (2011) found that in their ChIP data for both Pho4 and Cbf1, the latter competes most effectively with the former at T-CACGTG sites, consistent with the in vitro results, which suggest Cbf1 preferring T at N~-4~

# Question

What flanking nucleotides does CgPho4 prefer vs. ScPho4?

# Approach

For all in vivo mapped binding sites for ScPho4 (74) and CgPho4 (115) in S. cerevisiae as well as for CgPho4 (100) in C. glabrata, extract the sequence motif including the 2 flanking nucleotides on both 5’ and 3’.

* Input: coordinates of all the ChIP-binding locations
* Output: Sequence under the peak containing binding motif Identify the sequence motif in the extracted sequences and study the frequencies
at their flanking nucleotides.
* Use patser or an equivalent pattern matching algorithm to identify the closest match to the consensus “CACGTG”. Include 2 bp flanking nucleotide on each side. 
* Count up the frequency at flanking nucleotides

# Notes

## Correct Xu 2011 coordinates -- liftover to sac03

_Problem_

Xu used Sac01 (2003) for mapping his ChIP-seq reads, while my results were based on Sac03. This means when I visualize his 2011 data in MV, the coordinates are off for some of the chromosomes.

_Materials and Methods_

- Downloaded data for Xu's 2011 paper are in Harvard folder/NGS-seq in LSS. I made links to them in a new working folder on LSS so that I can do the liftOver using Argon
- Downloaded the liftOver tool and the Sac01->Sac03 liftOver chain file.
-
## Extract sequences matching the motif underlying ChIP peaks

**17 mai 2017**

* I filtered the binding site list in Figure 4-source data 1, removing the two instances where ScPho4 binds while CgPho4 doesn't. I then wrote that list to a text file located in the input directory under the analysis folder. This file is imported into MochiView and using the "motif" under "Export" function, I was able to get an output containing one instance of motif match per row, and a total of 135 roles.

	e.g.

	SEQ\_NAME	START	END	STRAND	SCORE	SEQUENCE
	chr1	68821	68826	+	3.483	acatcCACGTGgaaag

## Calculate frequencies in R

**18 mai 2017**

* I used R, MochiView and some help from shell / LibreOffice to count the nucleotide frequencies at flanking sites (-8~-4 and 4~8). I used the CgPho4 bound only, both ScPho4 and CgPho4 bound, all motif (per Xu's mmc2), motif bound by Cbf1 as categories. As one would expect, there is no strong preference for any of the four nucleotides in all CACGTG motifs genome wide. However, there is a strong preference for T at -4 position at the Cbf1 bound sites. By contrast, ScPho4 bound sites has a very low probability to have a T at the -4 position, confirming what Xu has observed. Strangely, there appears to be assymetry, because +4 position shows much weaker preference (for A, if it were to be symmetric). Most importantly, _CgPho4 bound only sites show similarly low probability of having a T at -4 position, suggesting that CgPho4 is no better at competing with Cbf1 than ScPho4 does_

* Next I want to more carefully plot the flanking nucleotide frequencies, maybe using the plot that Sebastian has used in his 2007 paper.
