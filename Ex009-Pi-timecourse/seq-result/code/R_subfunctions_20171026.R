# this file contains subfunctions to be sourced into the main analysis for Ex009

myGenePlot(dat, gene, sp = sample){
  # this function takes in the read count matrix (normalized and transformed) and a gene ID
  # and plots the values stratified by genotype and timepoint
  sub <- dat[gene,]   # extract the subset of genes used for plotting
  s <- colnames(dat)  # make sure the sample information of the matrix is matched to the sample sheet 
  df <- data.frame(sp[s,.()])
}