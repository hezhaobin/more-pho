## ----
## title: "Post_bedtools_analysis"
## input: bedtools coverage results for individual samples
## author: "binhe"
## created: "02/18/2016"
## modified: "04/03/2016", "10/18/2017"
## output: html_document
## ---

# 1. load packages
library(data.table)
library(hexbin)

# 2. load data and annotation
anno <- fread("../data/annotation/C_glabrata_gene_for_mapping_s02-m07-r04.bed")
files <- dir(path="../output/bedtools_cov", pattern="*.cov.txt",full.names=T)
raw <- lapply( files, fread )

# 3. extract information
gene.names <- anno$V4
gene.l <- raw[[1]]$V11
read <- sapply( raw, function(x) x$V9 )
frac <- sapply( raw, function(x) x$V12 )

# 4. Calculate length normalized coverage for each feature
#     first multiple # of reads by the length of reads = 50
#     then divide by gene length
norm.cov <- read * 75 / gene.l

# 5. now plot the actual fraction $frac against the expected $norm.cov
pdf(file = paste("../output/bedtools_fraction_coverage_QC_", format(Sys.time(), "%Y-%m-%d"), ".pdf", sep = ""))
hbin <- hexbin(log(norm.cov+0.0001,10), frac+0.0001, xbins = 40, xlab = "log10 normalized coverage", ylab = "% of gene body covered") 
plot(hbin, colorcut = c(seq(0,0.1,length=10),1))
dev.off()

# 6. output the count matrix
#     get basename "S1" etc.
names <- sapply( strsplit( basename(files), split=".", fixed = TRUE ), "[", 1 )
read <- as.data.table(read)
names(read) <- names
read$gene.names <- gene.names
write.table(as.data.frame(read), file=paste("../output/Ex009_reads_per_transcript_", format(Sys.time(), "%Y-%m-%d"), ".txt", sep = ""), quote=F, row.names=F, sep="\t")
write.table(as.data.frame(frac), file=paste("../output/Ex009_fraction_covered_per_feature_", format(Sys.time(), "%Y-%m-%d"), ".txt", sep = ""), quote=F, row.names=F, sep="\t")
