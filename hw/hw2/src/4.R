# **4.  Use the K-L representation to approximate the exponential
# correlation for range parameter equal to 1. Plot the approximation
# for several orders and compare to the actual correlation.**
# 
# **5. Repeat for the approximation given on Page 13 of the fifth set
# of slides.**
# 
# **6. Generate 100 realizations of a univariate Gaussian process with
# exponential correlation with range parameter 1. Compare the
# empirically estimated eigenvalues and eigenfunctions to the ones
# given by the K-L and the approximation on Page 12.**

source("../../hw1/src/cov_fn.R")
source("KL.R")
source("eigen.R")
source("../../hw1/src/gp_sim.R")
set.seed(1)

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

gp <- sapply(1:100, function(dummy) gp_sim(d, cov_fn=function(d) cov_fn$pow_exp(d,1,1)))
cor_gp <- cor(t(gp))

h1 <- sapply(d, function(s) KL_exp(0, s, J=J, L=L))
h2 <- cov_fn$pow_exp(d, phi=1, sig2=1)
h3 <- sapply(d, function(s) eigen_approx(s, J=J, L=L))
h4 <- cor_gp[1,]

pdf('../img/kl1.pdf')
# Plot KL approx of exp corr
plot(d, h1,type='b', ylim=range(0,h1,h2), col='blue', bty='n',
     lwd=3, fg='grey', ylab='Correlation', xlab='Distance')

# Plot exp corr
lines(d, h2, type='b', lwd=3, col='red')

# Plot p.13 approx
lines(d, h3, type='b', lwd=3, col='green')

# GP
lines(d, h4, type='b', lwd=3, col='orange')

legend("bottomleft", 
       legend=c('KL Approx.','Exponential Corr.', 
                'p.13 Approx.', 'GP'), 
       text.col=c('blue','red','green','orange'),
       cex=1.5, bty='n')
dev.off()


