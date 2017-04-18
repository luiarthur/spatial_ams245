source("mvrnorm.R")

gp_sim <- function(x, mu=0, cov_fn, eps=1E-10) {
  n <- length(x)
  Sig <- cov_fn(as.matrix(dist(x)) + diag(eps,n))
  mvrnorm(mu, Sig)
}
