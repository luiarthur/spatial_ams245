set.seed(1)
library(fields)
library(rcommon)
source("../GP_R/gp.R", chdir=TRUE)

phi_true <- .5
tau2_true <- 3
sig2_true <- 10
kappa_true <- 2.5

n <- 200
k <- 2
s <- matrix(rnorm(2 * n), ncol=2)
X <- cbind(1, s[,1], matrix(rnorm(n*k), n, k))
D <- as.matrix(dist(s))
int_true <- 10
b <- c(int_true, 3, 1:k)
V <- matern(D, phi_true, kappa_true)
mu <- mvrnorm(X %*% b, sig2_true*V)
y <- mu + rnorm(n, 0, sqrt(tau2_true))
quilt.plot(s[,1], s[,2], mu)
quilt.plot(s[,1], s[,2], y)

system.time(
  out <- gp(y, X, s, B=1000, burn=2000, print_every=100)
)

plotPosts(out[, 1:ncol(X)])
plotPosts(out[, c('phi','tau2','sig2', 'z')])
nrow(unique(out)) / nrow(out)
table(out[,'nu']) / nrow(out)


