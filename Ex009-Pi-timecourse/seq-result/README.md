---
title: RNAseq data for Ex009, Pi starvation time course in _C. glabrata_
author: Bin He
date: 10 oct 2017
---

This folder contains raw sequencing data and processed data from the experiment Ex009

# Goal

# Sample
40 samples pooled into 2 pools, using 20 adapter indices for each 

# Notes

## [11 oct 2017] Sequencing completed

- Data available on HTSEQ.princeton.edu

- The HTSEQ website is essentially a front end for a MySQL database. It organizes all the sample information and run results using concepts including _Sample_, _Assay_, _Dataset_ etc. A sample is what users submit to the core. An assay refers to a run on the Illumina machine. Note that for the Rapid Flowcell run on HiSeq 2500, each run has two assays, although it would be the same pooled samples sequenced in both. They result in a "merged" fastq.

## [12 oct 2017] Demultiplex

- To demultiplex, one needs to go to the individual assay page, find the button that says "create custom barcodes", and follow the instructions.

- Pool A is sequenced together with 5 other samples. The i7 adapter, which contains the TruSeq index, conflicts between my sample and those 5 samples. Wang Wei at the core pointed out that my sample and the other person's differ in the i5 index, which is read as Read 3, and can be used to distinguish our samples from each other. My i5 index is TCTTTCCC, while the other party's is GGTTGAGA.

- The HTSEQ server most likely uses [bcl2fastq2](https://support.illumina.com/content/dam/illumina-support/documents/downloads/software/bcl2fastq/bcl2fastq2-v2-18-software-guide-15051736-01.pdf) from illumina to do the demultiplexing. This software has a flag `--barcode-mismatches` that can be set to 0, 1 or 2, with the default being 1. Wei suggested using 2 for both i5 and i7 adapters.

- Some thoughts on the mismatches allowed:

	Calculate hamming distance between TruSeq adapter indices 1-20

	```{r test}
	require(stringdist)
	seq <- c("ATCACG", "CGATGT", "TTAGGC", "TGACCA", "ACAGTG", "GCCAAT", "CAGATC", "ACTTGA", "GATCAG", "TAGCTT", "GGCTAC", "CTTGTA", "AGTCAA", "AGTTCC", "ATGTCA", "CCGTCC", "GTCCGC", "GTGAAA", "GTGGCC", "GTTTCG")
	dist <- stringdistmatrix(seq, seq, method = "hamming")
	print("The distribution of pairwise hamming distance is:")
	print(table(dist))
	print("Note that the 20 zeros are self-distance")
	```
	
	output

	```
	dist
	0   3   4   5   6 
	20  56  98 166  60
	```
	
	It is important to realize that allowing more mismatches won't dramatically inflate the rate of index misassignment, i.e. read index 1 as index 2. This is because any index read that is equal distance away from the supplied set of indices used will be discarded.

	On PoolB, which is only multiplexed with one other sample, I used a more stringent cutoff of 1 mismatch, and the percentage of unmatched reads (due to indices mismatch) is < 1%. Totally fine.