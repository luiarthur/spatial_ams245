source("../../hw1/src/cov_fn.R")
source("KL.R")
source("eigen.R")

J <- 6
L <- 3

#KL_exp(.0,.0, J=J, L=L)
#
#KL_exp(.0,.1, J=J, L=L)
#KL_exp(.1,.0, J=J, L=L)
#KL_exp(.0,.2, J=J, L=L)
#KL_exp(.0,.1, J=J, L=L)
#KL_exp(.1,.2, J=J, L=L)
#KL_exp(.2,.3, J=J, L=L)
#KL_exp(.3,.4, J=J, L=L)
#KL_exp(.9,1,  J=J, L=L)
#KL_exp(2, 2.1,J=J, L=L)
#KL_exp(2.8,2.9, J=J, L=L)
#cov_fn$pow_exp(.1, phi=1, sig2=1)

d <- seq(0,1,len=10)

source("eigen.R")
eigen_approx(0, J=100, L=1)
eigen_approx(1, J=100, L=1)


h1 <- sapply(d, function(s) KL_exp(0, s, J=J, L=L))
h2 <- cov_fn$pow_exp(d, phi=1, sig2=1)
h3 <- sapply(d, function(s) eigen_approx(s, J=J, L=L))


pdf('../img/kl1.pdf')
# Plot KL approx of exp corr
plot(d, h1,type='b', ylim=range(0,h1,h2), col='blue', bty='n',
     fg='grey', ylab='Correlation', xlab='Distance')

# Plot exp corr
lines(d, h2, type='b', col='red')

# Plot p.13 approx
lines(d, h3, type='b', col='green')

legend("topright", legend=c('KL Approx.','Exponential Corr.'), 
       text.col=c('blue','red'), cex=1.5, bty='n')
dev.off()
