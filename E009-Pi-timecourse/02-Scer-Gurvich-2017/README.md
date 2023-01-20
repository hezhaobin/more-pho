## Goal

Reanalyzing Gurvich et al 2017 (PMID: 29236696) data to compare with our unpublished RNAseq time course for _C. glabrata_ under phosphate starvation

## Data

In this paper, the authors performed a large number of RNA-seq experiments that involve multitudes of genotypes and at different time points. What we are interested in is the lab "wild type" (no additional mutation with the possible exception of the _PHO84pr-GFP_ reporter) profiled under phosphate starvation in the first couple of hours. Note that they didn't include biological replicates in any of their experiments. However, they did two sets of time course experiments for some of the genotypes/conditions, including the wild type strain with a PHO84 promoted YFP reporter.

> **Experiment 1**
>
> - Coarse time course at 0, 1, 2, 3.5, 5, 6.5, 8, 9.5, 24.67 hrs
>
> - Cells assayed under several [Pi]: 0 mM, 0.06 mM, 0.2 mM, 0.5 mM
>
> **Experiment 2**
> - Fine time course at 0, 0.25, 0.5, 0.75, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.5, 12, 24.67 hrs
>
> - Cells assayed under 0.06 mM, 0.2 mM [Pi]
>

For comparison with the _C. glabrata_ dataset, we need the no Pi time course. However, the no Pi data is only available in the coarse time course, with no possibility for a replicate. To complement it, we will also include the 0.06 mM low Pi time course, which is available in both the coarse and fine time course experiments, offering a possibility of a replicate.

## Read-to-count

### Select experiments

See [analysis notes](../analysis/20230110-select-experiment.html)

### Download from SRA

Using the 

GATCGGAAGAGCGGTTCAGCAGGAATGCCGAG
