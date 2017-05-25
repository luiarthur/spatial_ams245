#set.seed(1)
library(fields)
library(rcommon)
source("../GP_R/gp.R", chdir=TRUE)

phi_true <- .8
tau2_true <- .2
sig2_true <- 2
kappa_true <- 0.5

n <- 100
k <- 2
s <- matrix(rnorm(2 * n), ncol=2)
X <- cbind(1, s[,1], matrix(rnorm(n*k), n, k))
D <- as.matrix(dist(s))
int_true <- 10
b <- c(int_true, 3, 1:k)
V <- matern(D, phi_true, kappa_true)
y <- mvrnorm(X %*% b, diag(n) * tau2_true + sig2_true * V)
quilt.plot(s[,1], s[,2], y)

system.time(
  burn <- gp(y, X, s, B=1000, burn=3000, print_every=100)
)

cov_burn <- cov(burn[,c('gam2', 'phi','z')])

plotPosts(burn[, 1:ncol(X)])
plotPosts(burn[, c('phi','tau2','sig2', 'z')])
nrow(unique(burn)) / nrow(burn)
table(burn[,'nu']) / nrow(burn)

### True samples
cnames <- paste0(c('phi=','tau2=','sig2=','z='), 
                 c(phi_true,tau2_true,sig2_true,
                   ceiling(kappa_true)))
system.time(
  out <- gp(y, X, s, step=cov_burn*10, 
            B=1000, burn=3000, print_every=100)
)
plotPosts(out[, 1:ncol(X)],
          cn=paste(colnames(out[,1:ncol(X)]), b))
plotPosts(out[, c('phi','tau2','sig2', 'z')], cnames=cnames)
nrow(unique(out)) / nrow(out)
table(out[,'nu']) / nrow(out)


### Predict
#pred <- gp.predict(y, X, s, X, s, out)
#pred.mean <- apply(pred, 1, mean)
#pred.ci <- apply(pred, 1, quantile, c(.025,.975))
#plot(y,pred.mean, ylim=range(pred.ci), xlim=range(pred.ci))
#add.errbar(t(pred.ci), x=y, col=rgb(0,0,0,.3))
#abline(0,1,lty=2,col='grey')
