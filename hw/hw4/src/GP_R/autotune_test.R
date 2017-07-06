library(rcommon)
source("mcmc.R")

N <- 2000
mu_true <- -2
s2_true <- 5
y <- rnorm(N, 3, sqrt(s2_true))
#hist(y)

update <- function(p,cs=list(mu=1000, s2=1000)) {
  # Update mu
  ll_mu <- function(mu) sum(dnorm(y, mu, sqrt(p$s2), log=TRUE))
  lp_mu <- function(mu) dnorm(mu, 0, 10, log=TRUE)
  mu <- mh(p$mu, ll_mu, lp_mu, cs$mu)

  # Update s2
  ll_log_s2 <- function(log_s2) sum(dnorm(y, mu, sqrt(exp(log_s2)), log=TRUE))
  lp_log_s2 <- function(log_s2) lp_log_invgamma(log_s2, 2, 1)
  s2 <- exp(mh(log(p$s2), ll_log_s2, lp_log_s2, cs$s2))
  
  list(mu=mu, s2=s2)
}

init <- list(mu=0, s2=1)

adapt <- function(samps) {
  mu <- sapply(samps, function(p) p$mu)
  s2 <- log(sapply(samps, function(p) p$s2))
  lapply(list(mu=mu, s2=s2), autotune2, 2.4)
}

out <- gibbs_auto(init, update, B=2000, burn=10000, adapt=adapt, print_every=1000)

mu_post <- sapply(out, function(o) o$mu)
s2_post <- sapply(out, function(o) o$s2)

#plotPost(mu_post); abline(v=mu_true, lwd=2, col='orange')
#plotPost(s2_post); abline(v=s2_true, lwd=2, col='orange')

plotPosts(cbind(mu_post, s2_post))
