# this file contains subfunctions to be sourced into the main analysis for Ex009

myGenePlot <- function(lc = lcpm, genes = "CAGL0B02475g", sp = sample) {
  # this function takes in the read count matrix (normalized and transformed) and a gene ID
  # and plots the values stratified by genotype and timepoint
  dat <- rbind( lc[genes,sp$Sample] )   # extract the subset of genes used for plotting
  rownames(dat) <- genes
  dt <- data.table(sp[,.(Sample, Genotype, Timepoint)], t(dat))
  dtm <- melt(dt, id = 1:3, variable.name = "GeneID")
  p <- ggplot( dtm, aes( x = Timepoint, y = value, color = Genotype ) )
  print( 
    p + geom_point() + geom_smooth(method = "loess", aes(x = as.numeric(Timepoint), y = value, color = Genotype)) + ylab("log2 count per million") + facet_wrap( ~ GeneID ) + theme(axis.text.x = element_text(angle = 90, size = rel(0.5)))
  )
}
