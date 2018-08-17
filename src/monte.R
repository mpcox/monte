# monte.R
# code to determine statistical significance of high or low mutation rates
# of specific nucleotide states in a heat-pressure-time experimental setting

# note: this example is coded for C-to-T mutations at GC sites

# author: Jasmin Franke <jf132515@uni-greifswald.de>
# modified: Murray Cox <murray.p.cox@gmail.com>

# date: January 2017

# global variables
iterations <- 10000
main.title <- paste("5% top GC mutation rates - S1\nSimulations =", iterations)
test.side  <- "right-tailed"  # either "left-tailed" or "right-tailed"
span       <- c(2:1060)  # region of Cs included in the analysis

# data files
in.filename <- "example_S1.dat"
out.plot    <- "example_S1.pdf"

# read input data
sample <-read.table(in.filename, skip=2, header=F, sep='\t')
header <- scan(in.filename, nlines=1, what=character())
names(sample) <- header

# collect reference sequence
ref <- sample$Ref

# determine sites with the target nucleotide state within the study region (here, C)
cp1 <- which(ref=='C')
cp1 <- cp1[span]

# pull out the mutation rates of these sites
ct1 <- subset(sample$`C->T`, sample$Ref=='C')
ct1 <- ct1[span]

# determine sites with a GC pattern
GC <- vector()
for(i in 1:length(sample[,1])){
	if(ref[i]=='G' && ref[i+1]=='C')
		GC <- append(GC, which(cp1==i+1))	
}

# local variables
observed.points <- 53
dataset         <- ct1
pattern         <- GC

# establish vector of zeros the length of the observed Cs
sites <- rep(0, length(dataset))

# set flag 1 when pattern of the i-th C is GC
sites[pattern] <- 1

# find positions with the 5% highest C mutation rates
high.pos <- which(dataset >= sort(dataset, decreasing=T)[observed.points])

# establish another vector of zeros the length of the observed Cs
hp.orig <- rep(0, length(dataset))

# set flag 1 when pattern of the i-th C is one of the highest 5%
hp.orig[high.pos] <- 1

# define observed number of sites with GC pattern *and* top 5% mutation
R <- sum(ifelse(hp.orig & sites,1,0))

# run Monte Carlo test
res <- vector()
for(r in 1:iterations){
	
	# shuffle vector of highest 5%
	hp <- sample(hp.orig)
	
	# select if GC and new (shuffled) highest 5%
	z <- ifelse(hp & sites,1,0)
	
	# count instances and report
	res[r] <- sum(z)
}

# calculate probability
if(test.side=="right-tailed"){
	exceed <- which(res >= R)
}else if(test.side=="left-tailed"){
	exceed <- which(res <= R)
}	
p <- length(exceed)/length(res)

# plot Monte Carlo density
pdf(out.plot, height=10, width=15)
barplot(table(res), main=paste(main.title, "R =", R), 
	xlab="Simulated Counts", ylab="Number")
dev.off()

# report probability
if( p == 0 ){
	cat("p <", 1/iterations)
}else{
	cat("p =", p)
}

