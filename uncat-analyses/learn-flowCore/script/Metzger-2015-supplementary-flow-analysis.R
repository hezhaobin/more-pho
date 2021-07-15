###################################################
###Flow data analysis for Metzger and Yuan et al###
###################################################
#Step 1: Removal of artifacts, dead cells, and doublets
#Step 2: Gating of cells to obtain a homogeneous population
#Step 3: Assign individual well data to strain
#Step 4: Correct systematic differences in expression and noise

##############
###Packages###
##############
library(flowCore)
library(flowClust)
library(flowViz)
library(plotrix)

#####################################
###Steps 1 and 2: Cleaning of Data###
#####################################
#Grab names of plates
PLATES <- list.dirs(".")
PLATES <- PLATES[grep("R",PLATES)]

#I indexes sampling of wells. Each sampling consists of two rows of a 96 well plate
I <- 1:length(PLATES)
#J indexes wells within a sampling 
J <- 1:24

#Set up matrices and vectors for storing data to check cleaning
YFP.MEAN       <- matrix(0, nrow=length(J), ncol=length(I))
YFP.SD         <- matrix(0, nrow=length(J), ncol=length(I))
COUNTS.INITIAL <- matrix(0, nrow=length(J), ncol=length(I))
COUNTS.FINAL   <- matrix(0, nrow=length(J), ncol=length(I))

###Cleaning
for(i in I) {
	#Keep track of how long everything takes
	print(i)
	print(proc.time())
	setwd(PLATES[i])
	WELLS <- list.files(".", pattern="fcs")
	pdf(paste(substring(PLATES[i],3,7), substring(PLATES[i],9,15), "pdf", sep="."))

	###Loop over wells within a sampling###
	for(j in J) {
		proc.time()
		WELL.ORI.DATA <- read.FCS(WELLS[j], transformation=FALSE, alter.names=TRUE)
		#Get number of events recorded prior to cleaning
		COUNTS.INITIAL[j,i] <- nrow(WELL.ORI.DATA)	
		
		###Remove Extreme Outliers with hard gates###
			rect.gate <- rectangleGate(filterId="Noise Removal", "FSC.A"=c(10^4.75,10^7), "FSC.H"=c(10^5.5,10^7), "SSC.A"=c(10^3,10^7), "SSC.H"=c(10^3,10^7), "FL1.A"=c(10^1,10^7), "FL1.H"=c(10^1,10^7), "Width"=c(42,75))
			WELL.CLEAN.DATA.OUTLIER <- Subset(WELL.ORI.DATA, rect.gate)

		####Log10 Transform useful variables###
			#Do this after hard gates so there are no zeros
			log.transform <- logTransform(transformationId="log10-transformation", logbase=10, r=1, d=1)
			WELL.CLEAN.DATA.OUTLIER <- transform(WELL.CLEAN.DATA.OUTLIER, `logFSC.A`=log.transform(`FSC.A`))
			WELL.CLEAN.DATA.OUTLIER <- transform(WELL.CLEAN.DATA.OUTLIER, `logFSC.H`=log.transform(`FSC.H`))
			WELL.CLEAN.DATA.OUTLIER <- transform(WELL.CLEAN.DATA.OUTLIER, `logFL1.A`=log.transform(`FL1.A`))
			WELL.CLEAN.DATA.OUTLIER <- transform(WELL.CLEAN.DATA.OUTLIER, `logFL1.H`=log.transform(`FL1.H`))
			WELL.CLEAN.DATA.OUTLIER <- transform(WELL.CLEAN.DATA.OUTLIER, `logSSC.A`=log.transform(`SSC.A`))
			WELL.CLEAN.DATA.OUTLIER <- transform(WELL.CLEAN.DATA.OUTLIER, `logSSC.H`=log.transform(`SSC.H`))

		###Add FL1^2/FSC^3 phenotype which measures YFP expression controlled for cell size###
			WELL.CLEAN.DATA.OUTLIER.EXPRS <- exprs(WELL.CLEAN.DATA.OUTLIER)
			PHENOTYPE <- (WELL.CLEAN.DATA.OUTLIER.EXPRS[,"logFL1.A"]^2)/(WELL.CLEAN.DATA.OUTLIER.EXPRS[,"logFSC.A"]^3)
			PHENOTYPE <- as.matrix(PHENOTYPE)
			colnames(PHENOTYPE) <- "FL1^2/FSC^3"
			WELL.CLEAN.DATA.OUTLIER <- cbind2(WELL.CLEAN.DATA.OUTLIER, PHENOTYPE)

		###Filter on FSC.A and Width###
			WELL.CLEAN.DATA.WIDTH <- flowClust(WELL.CLEAN.DATA.OUTLIER, varNames=c("logFSC.A","Width"), K=2, B=100, min.count=1000, nu.est=2, nu=4, trans=0, seed=10, z.cutoff=0.7, tol=1e-4)
			CLUSTERS <- 1:2
			GOOD.CLUSTER <- which(getEstimates(WELL.CLEAN.DATA.WIDTH)$locations[,2] == min(getEstimates(WELL.CLEAN.DATA.WIDTH)$locations[,2]))
			BAD.CLUSTER  <- CLUSTERS[which(CLUSTERS != GOOD.CLUSTER)]
			SPLIT.SAMPLE <- split(WELL.CLEAN.DATA.OUTLIER, WELL.CLEAN.DATA.WIDTH, population=list(C1=GOOD.CLUSTER, C2=BAD.CLUSTER))
			WELL.CLEAN.DATA.WIDTH <- SPLIT.SAMPLE$C1

		###Filter to remove doublets###
			WELL.CLEAN.DATA.DOUBLET <- flowClust(WELL.CLEAN.DATA.WIDTH, varNames=c("logFSC.H", "logFSC.A"), K=1, B=50, min.count=1000, nu=4, trans=0, seed=10, level=0.9, tol=1e-4)
			SPLIT.SAMPLE <- split(WELL.CLEAN.DATA.WIDTH, WELL.CLEAN.DATA.DOUBLET, population=list(C1=1))
			WELL.CLEAN.DATA.DOUBLET <- SPLIT.SAMPLE$C1

		###Obtain homogeneous population###
			WELL.CLEAN.DATA <- flowClust(WELL.CLEAN.DATA.DOUBLET, varNames=c("logFSC.A","FL1^2/FSC^3"), K=2, criterion="BIC", B=50, min.count=100, nu.est=0, trans=0, z.cutoff=0.5, seed=10, tol=1e-5, nu=1.5, level= 0.85)
			
			if(abs(getEstimates(WELL.CLEAN.DATA)$locations[1,2] - getEstimates(WELL.CLEAN.DATA)$locations[2,2]) > 0.03) {
				BAD.CLUSTER <- which(getEstimates(WELL.CLEAN.DATA)$locations[1:length(CLUSTERS),2] == min(getEstimates(WELL.CLEAN.DATA)$locations[1:length(CLUSTERS),2]))
				GOOD.CLUSTER <- CLUSTERS[which(CLUSTERS != BAD.CLUSTER)]
				SPLIT.SAMPLE <- split(WELL.CLEAN.DATA.DOUBLET, WELL.CLEAN.DATA, population=list(C1=GOOD.CLUSTER, C2=BAD.CLUSTER))
				WELL.CLEAN.DATA <- SPLIT.SAMPLE$C1
			} else {
				WELL.CLEAN.DATA <- flowClust(WELL.CLEAN.DATA.DOUBLET, varNames=c("logFSC.A","FL1^2/FSC^3"), K=1, criterion="BIC", B=50, min.count=100, nu.est=0, trans=0, z.cutoff=0.5, seed=10, tol=1e-5, nu=1.5, level= 0.85)
				SPLIT.SAMPLE <- split(WELL.CLEAN.DATA.DOUBLET, WELL.CLEAN.DATA)
				WELL.CLEAN.DATA <- SPLIT.SAMPLE[[1]]
			}
	
		###Check Plots to make sure cleaning worked###
		###Note: Mean and median give similar results, but the median is more robust to problems with cleaning and is used instead###
			DATA.DIRTY <- as.data.frame(exprs(WELL.CLEAN.DATA.OUTLIER))
			DATA.CLEAN <- as.data.frame(exprs(WELL.CLEAN.DATA))

			par(mfrow = c(2,2))
			plot(  DATA.DIRTY$Width, DATA.DIRTY$logFSC.A, pch=19, cex=0.4, col="#00000044", xlim=c(20,100), ylim=c(4.5,6.5), xlab="Width", ylab="Log10(FSC.A)", main=paste(WELL.CLEAN.DATA.DOUBLET@description$'#SAMPLE',j))
			points(DATA.CLEAN$Width, DATA.CLEAN$logFSC.A, pch=19, cex=0.4, col="#FF000044")
			abline(v=median(DATA.CLEAN$Width))
			abline(h=median(DATA.CLEAN$logFSC.A))

			plot(  DATA.DIRTY$logFSC.H, DATA.DIRTY$logFSC.A, pch=19, cex=0.4, col="#00000044", xlim=c(5,7), ylim=c(4.5,6.5), xlab="Log10(FSC.H)", ylab="Log10(FSC.A)", main=paste(WELL.CLEAN.DATA.DOUBLET@description$'#SAMPLE',j))
			points(DATA.CLEAN$logFSC.H, DATA.CLEAN$logFSC.A, pch=19, cex=0.4, col="#FF000044")
			abline(v=median(DATA.CLEAN$logFSC.H))
			abline(h=median(DATA.CLEAN$logFSC.A))

			plot(  DATA.DIRTY$logFSC.A^3,DATA.DIRTY$logFL1.A^2, pch=19, cex=0.4, col="#00000044", xlim=c(100,300), ylim=c(0,40), xlab="Log10(FSC.A)^3", ylab="Log10(FL1.A)^2", main=paste(WELL.CLEAN.DATA.DOUBLET@description$'#SAMPLE',j))
			points(DATA.CLEAN$logFSC.A^3,DATA.CLEAN$logFL1.A^2, pch=19, cex=0.4, col="#FF000044")
			abline(v=median(DATA.CLEAN$logFSC.A^3))
			abline(h=median(DATA.CLEAN$logFL1.A^2))

			plot(  DATA.DIRTY$logFSC.A,DATA.DIRTY$logFL1.A^2/DATA.DIRTY$logFSC.A^3, pch = 19, cex = 0.4, col = "#00000044", xlim = c(4.5,6.5), ylim = c(0,0.2), xlab = "Log10(FSC.A)^3", ylab = "Log10(FL1.A)^2/Log10(FSC.A)^3", main = paste(WELL.CLEAN.DATA.DOUBLET@description$'#SAMPLE',j))
			points(DATA.CLEAN$logFSC.A,DATA.CLEAN$logFL1.A^2/DATA.CLEAN$logFSC.A^3, pch = 19, cex = 0.4, col = "#FF000044")
			abline(v=median(DATA.CLEAN$logFSC.A))
			abline(h=median(DATA.CLEAN$'FL1^2/FSC^3'))
		
		###Calculate Median, SD, and final counts for each sample as checks if needed###
			#YFP.MEAN[j,i]     <- median(DATA.CLEAN$'FL1^2/FSC^3')
			#YFP.SD[j,i]       <- sd(DATA.CLEAN$'FL1^2/FSC^3')
			#COUNTS.FINAL[j,i] <- nrow(DATA.CLEAN)

		###Write cleaned data to file###
			setwd("../../../Clean")
			write.table(DATA.CLEAN, paste(substring(PLATES[i],3,7), substring(PLATES[i],9,15), sprintf("%02d", j), "txt",sep ="."), quote = FALSE, row.names = FALSE)
			setwd("../Original")
			setwd(PLATES[i])
	}
	dev.off()
	setwd("../..")
	print(proc.time())
	print(i)
}

###########################################
###Step 3: Assign cleaned data to strain###
###########################################
###Read in cleaned data. Calculate and store median expression, standard deviation, width, and final counts for each strain
WELLS <- list.files(".")
I <- 1:length(WELLS)
YFP.MEAN     <- numeric(length(I))
YFP.SD       <- numeric(length(I))
COUNTS.FINAL <- numeric(length(I))
WIDTH <- numeric(length(I))
for(i in I) {
	FILE <- read.table(WELLS[i],header = TRUE)
	YFP.MEAN[i]     <- median(log10(FILE$FL1.A)^2/log10(FILE$FSC.A)^3)
	YFP.SD[i]       <- sd(log10(FILE$FL1.A)^2/log10(FILE$FSC.A)^3)
	WIDTH[i] 	<- mean(FILE$Width)
	COUNTS.FINAL[i] <- nrow(FILE)
	if(i %% 10 == 0) {
		print(proc.time())
		print(i)
	}
}

DATA <- read.table("Layout.txt", header = TRUE, colClasses=c("factor","factor","factor","factor","factor","factor","factor","integer","factor","factor","factor","integer"))
DATA <- cbind(DATA,COUNTS.FINAL)
DATA <- cbind(DATA,WIDTH)
DATA <- cbind(DATA,YFP.MEAN)
DATA <- cbind(DATA,YFP.SD)
DATA$COLUMN <- as.factor(DATA$COLUMN)
DATA$RUN <- as.factor(DATA$RUN)

#write.table(DATA, "Data.txt" ,sep="\t", quote=FALSE, row.names=FALSE)
#DATA <- read.table("Data.txt", header =TRUE, colClasses = c("factor","factor","factor","factor","factor","factor","factor","integer","factor","factor","factor","integer","integer","numeric","numeric","numeric"))
#DATA$COLUMN <- as.factor(DATA$COLUMN)
#DATA$RUN <- as.factor(DATA$RUN)

#Remove samples with low counts 
DATA <- subset(DATA, DATA$COUNTS.FINAL > 1000)

#####################################################################
###Step 4: Check and correct for systematic expression differences###
#####################################################################
##Corrects mean and sd for differences in growth conditions using 20 unmutated controls per plate
#Pull out control wells
CONTROL <- subset(DATA, STRAIN == "WT.Y1.3")
CONTROL <- droplevels(CONTROL)

#Find best model by AIC for Mean
MODEL.0 <- lm(YFP.MEAN ~ 0 + log10(COUNTS.FINAL) + RUN + DAY * REP + PLATE + ORDER * STACK * DEPTH + BLOCK * ROW * COLUMN + WIDTH, data=CONTROL)
step(MODEL.0)
MODEL.1 <- lm(formula = YFP.MEAN ~ 0 + RUN + BLOCK, data=CONTROL)

#Correct for effects
I <- 1:nrow(DATA)
YFP.MEAN.CORRECT <- numeric(length(I))
RUN.EFFECT <- MODEL.1$coefficients[1:73] - MODEL.1$coefficients[1]
BLOCK.EFFECT <- c(0,MODEL.1$coefficients[74:76])
for(i in I) {
	RUN <- DATA$RUN[i]
	BLOCK <- DATA$BLOCK[i]
	YFP.MEAN.CORRECT[i] <- DATA$YFP.MEAN[i] - RUN.EFFECT[RUN] - BLOCK.EFFECT[BLOCK]
}
DATA$YFP.MEAN.CORRECT <- YFP.MEAN.CORRECT

#Find best model by AIC for SD
MODEL.2 <- lm(YFP.SD ~ 0 + log10(COUNTS.FINAL) + RUN + DAY * REP + PLATE + ORDER * STACK * DEPTH + BLOCK * ROW * COLUMN + WIDTH, data=CONTROL)
step(MODEL.2)
MODEL.3 <- lm(formula = YFP.SD ~ 0 + RUN + BLOCK, data=CONTROL)

#Correct for effects
I <- 1:nrow(DATA)
YFP.SD.CORRECT <- numeric(length(I))
RUN.EFFECT <- MODEL.3$coefficients[1:73] - MODEL.3$coefficients[1]
BLOCK.EFFECT <- c(0,MODEL.3$coefficients[74:76])
for(i in I) {
	RUN <- DATA$RUN[i]
	BLOCK <- DATA$BLOCK[i]
	YFP.SD.CORRECT[i] <- DATA$YFP.SD[i] - RUN.EFFECT[RUN] - BLOCK.EFFECT[BLOCK]
}
DATA$YFP.SD.CORRECT <- YFP.SD.CORRECT

#Pull out control wells
CONTROL <- subset(DATA, STRAIN == "WT.Y1.3")
CONTROL <- droplevels(CONTROL)

#Check for any remaining effects
#pdf("Plate_Mean_Finish.pdf")
par(mfrow = c(1,2))
plot(CONTROL$YFP.MEAN            ~ CONTROL$DAY,       xlab = "DAY", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
plot(CONTROL$YFP.MEAN.CORRECT    ~ CONTROL$DAY,       xlab = "DAY", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN         ~ CONTROL$REP,       xlab = "REPLICATE", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN.CORRECT ~ CONTROL$REP,       xlab = "REPLICATE", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
plot(CONTROL$YFP.MEAN            ~ CONTROL$PLATE,     xlab = "PLATE", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
plot(CONTROL$YFP.MEAN.CORRECT    ~ CONTROL$PLATE,     xlab = "PLATE", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
plot(CONTROL$YFP.MEAN            ~ CONTROL$STACK,     xlab = "STACK", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
plot(CONTROL$YFP.MEAN.CORRECT    ~ CONTROL$STACK,     xlab = "STACK", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN         ~ CONTROL$DEPTH,     xlab = "DEPTH", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN.CORRECT ~ CONTROL$DEPTH,     xlab = "DEPTH", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN         ~ CONTROL$ORDER,     xlab = "ORDER", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN.CORRECT ~ CONTROL$ORDER,     xlab = "ORDER", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN         ~ CONTROL$ROW,       xlab = "ROW", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN.CORRECT ~ CONTROL$ROW,       xlab = "ROW", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN         ~ CONTROL$COLUMN,    xlab = "COLUMN", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN.CORRECT ~ CONTROL$COLUMN,    xlab = "COLUMN", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN         ~ CONTROL$BLOCK,     xlab = "BLOCK", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.MEAN.CORRECT ~ CONTROL$BLOCK,     xlab = "BLOCK", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.15)
plot(CONTROL$YFP.MEAN            ~ CONTROL$COUNTS.FINAL,  xlab = "Counts", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.3, col = "#00000066")
plot(CONTROL$YFP.MEAN.CORRECT    ~ CONTROL$COUNTS.FINAL,  xlab = "Counts", ylab = "YFP.MEAN", ylim = c(0.1275,0.16), pch = 19, cex = 0.3, col = "#00000066")
#dev.off()

#pdf("Plate_SD_Finish.pdf")
par(mfrow = c(1,2))
plot(CONTROL$YFP.SD            ~ CONTROL$DAY,       xlab = "DAY", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
plot(CONTROL$YFP.SD.CORRECT    ~ CONTROL$DAY,       xlab = "DAY", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD         ~ CONTROL$REP,       xlab = "REPLICATE", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD.CORRECT ~ CONTROL$REP,       xlab = "REPLICATE", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
plot(CONTROL$YFP.SD            ~ CONTROL$PLATE,     xlab = "PLATE", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
plot(CONTROL$YFP.SD.CORRECT    ~ CONTROL$PLATE,     xlab = "PLATE", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
plot(CONTROL$YFP.SD            ~ CONTROL$STACK,     xlab = "STACK", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
plot(CONTROL$YFP.SD.CORRECT    ~ CONTROL$STACK,     xlab = "STACK", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD         ~ CONTROL$DEPTH,     xlab = "DEPTH", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD.CORRECT ~ CONTROL$DEPTH,     xlab = "DEPTH", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD         ~ CONTROL$ORDER,     xlab = "ORDER", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD.CORRECT ~ CONTROL$ORDER,     xlab = "ORDER", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD         ~ CONTROL$ROW,       xlab = "ROW", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD.CORRECT ~ CONTROL$ROW,       xlab = "ROW", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD         ~ CONTROL$COLUMN,    xlab = "COLUMN", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD.CORRECT ~ CONTROL$COLUMN,    xlab = "COLUMN", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD         ~ CONTROL$BLOCK,     xlab = "BLOCK", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
boxplot(CONTROL$YFP.SD.CORRECT ~ CONTROL$BLOCK,     xlab = "BLOCK", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15)
plot(CONTROL$YFP.SD            ~ CONTROL$COUNTS.FINAL,  xlab = "Counts", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15, col = "#00000066")
plot(CONTROL$YFP.SD.CORRECT    ~ CONTROL$COUNTS.FINAL,  xlab = "Counts", ylab = "YFP.SD", ylim = c(0.0035,0.0085), pch = 19, cex = 0.15, col = "#00000066")
#dev.off()

#Write Corrected data to file
#write.table(DATA,"DATA.CORRECT.txt", quote=FALSE, row.names=FALSE, sep="\t")
#DATA <- read.table("Data.Correct.txt", header=TRUE)

#Identify problematic strains and drop them
#These are due to poor cleaning, low amounts of data, or strains with inconsitent expression
VARIANCE.MEAN.ESTIMATE <- aggregate(DATA$YFP.MEAN.CORRECT ,by=list(DATA$STRAIN), FUN=sd)
VARIANCE.MEAN.ESTIMATE <- VARIANCE.MEAN.ESTIMATE[order(VARIANCE.MEAN.ESTIMATE$x),]
VARIANCE.SD.ESTIMATE <- aggregate(DATA$YFP.SD.CORRECT ,by=list(DATA$STRAIN), FUN=sd)
VARIANCE.SD.ESTIMATE <- VARIANCE.SD.ESTIMATE[order(VARIANCE.SD.ESTIMATE$x),]

DATA <- subset(DATA, !DATA$STRAIN %in% c("1Q4E5","m131","2Q1G4"))
DATA <- droplevels(DATA)

#Write Corrected data to file
#write.table(DATA,"DATA.CORRECT.txt", quote=FALSE, row.names=FALSE, sep="\t")