### HW: ###
# Assume that the correlation functions in the previous point correspond to one
# dimensional Gaussian processes. Simulate one 100-points realization of the
# process corresponding to each of the plotted functions.

source("cov_fn.R")
source("gp_sim.R")
set.seed(1)

### MAIN ###
num_cov_fn <- length(cov_fn)

### phi for which corr is 0.05 at distance 1 and variance=1, nu=1 ###
phi <- lapply(cov_fn, function(x) find_phi(x, r=.05, d=1, nu=1)$root)
phi$wave <- .01 # .33
#phi$wave <- .33

### covariance fn for this hw ###
my_cov_fn <- lapply(as.list(1:num_cov_fn), function(i) {
  function(x) cov_fn[[i]](d=x, phi=phi[[i]], sig2=1, nu=1) 
})
names(my_cov_fn) <-  names(phi)

### length of GP vector ###
n <- 100
#x <- seq(0,1,len=n)
x <- seq(-2,2,len=n)

### PLOTS ###

gp <- sapply(my_cov_fn, function(cf) gp_sim(x, cov_fn=cf, eps=1E-6))

# FIXME
#source("gp_sim.R")
#w <- gp_sim(x, cov_fn=my_cov_fn$wave, eps=1E-6)


pdf('../img/gp.pdf')
par(mfrow=c(3,2), mar=mar.ts, oma=oma.ts)
for (i in 1:length(phi)) {
  plot(x,gp[,i],xaxt=ifelse(i %in% c(4,5), 's', 'n'), type='l', 
       ylab=colnames(gp)[i], ylim=c(-3,3))
  abline(h=0, lty=2, col='grey')
}
par(mfrow=c(1,1), mar=mar.default, oma=oma.default)
title(main='Gaussian Processes')
dev.off()
