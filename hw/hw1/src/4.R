### HW: ###
# Assume that the correlation functions in the previous point correspond to one
# dimensional Gaussian processes. Simulate one 100-points realization of the
# process corresponding to each of the plotted functions.

source("cov_fn.R")
source("gp_sim.R")

### MAIN ###
num_cov_fn <- length(cov_fn)

### phi for which corr is 0.05 at distance 1 and variance=1, nu=1 ###
phi <- lapply(cov_fn, function(x) find_phi(x, r=.05, d=1, nu=1)$root)
phi$wave <- 2E-3 # .33
phi$rational_quad <- .12# .229
wierd <- c("wave", "rational_quad")

### covariance fn for this hw ###
my_cov_fn <- lapply(as.list(1:num_cov_fn), function(i) {
  function(x) cov_fn[[i]](d=x, phi=phi[[i]], sig2=1, nu=1) 
})
names(my_cov_fn) <-  names(phi)

### length of GP vector ###
n <- 100
x <- seq(0,1,len=n)

### PLOTS ###
gp <- sapply(my_cov_fn, function(cf) gp_sim(x, cov_fn=cf,eps=1E-10))
plot.ts(gp, xlab='index');


