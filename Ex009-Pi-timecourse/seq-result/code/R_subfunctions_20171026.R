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

myPlotRLE <- function(x,...) {
  # this source code is copied from the EDASeq package (https://github.com/drisso/EDASeq/blob/master/R/methods-SeqExpressionSet.R)
  y <- log(x+1)
  median <- apply(y, 1, median)
  rle <- apply(y, 2, function(x) x - median)
  
  boxplot(rle, ...)
  abline(h=0, lty=2)
  invisible(rle)
}

myBetweenLaneNormalization <- function(x, which=c("median", "upper", "full"), offset=FALSE, round=TRUE) {
  which <- match.arg(which)
  if(which=="full") {
    retval <- normalizeQuantileRank(as.matrix(x), robust=TRUE)
  } else {
    if(which=="upper") {
      sum <- apply(x, 2, quantile, 0.75)
    } else {
      sum <- apply(x, 2, median)
    }
    sum <- sum/mean(sum)
    retval <- scale(x, center=FALSE, scale=sum)
  }
  if(!offset) {
    if(round) {
      retval <- round(retval)
    }
    return(retval)
  } else {
    ret <- log(retval + 0.1) - log(x + 0.1)
    return(ret)
  }
}