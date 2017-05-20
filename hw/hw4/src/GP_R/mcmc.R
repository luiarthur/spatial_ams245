### Univariate metropolis with Normal proposal ###
mh <- function(x, log_fc, step_size) {
  cand <- rnorm(1, x, step_size)
  acc <- log_fc(cand) - log_fc(x)
  u <- runif(1)

  out <- ifelse(acc > log(u), cand, x)
  return(out)
}

### Sample from multivariate Normal ###
mvrnorm <- function(m, S) {
  m + t(chol(S)) %*% rnorm(ncol(S))
}

### Multivariate metropolis with Normal proposal ###
mh_mv <- function(x, log_fc, step_size) {
  cand <- mvrnorm(x, step_size)
  acc <- log_fc(cand) - log_fc(x)
  u <- runif(1)

  out <- ifelse(acc > log(u), cand, x)
  return(out)
}

### Gibbs Sampler (generic) ###
gibbs <- function(init, update, B, burn) {
  out[[1]] <- init

  for (i in 2:(B+burn)) {
    out[[i]] <- update(out[[i-1]])
  }

  return(tail(out, B))
}

### Transforming parameters ###
logit <- function(p, a, b) {
  log( (p-a) / (b-p) )
}

inv_logit <- function(x, a, b) {
  (b * exp(x) + a) / (1 + exp(x)) 
}

log_den_logx_2param <- function(log_den) {
  function(logx, a, b) log_den(exp(logx), a, b) + logx
}

log_dgamma <- function(x, a, b) dgamma(x, a, b, log=TRUE)

log_digamma <- function(x, a, b_numer) {
  const <- a * log(b_numer) - lgamma(a)
  -(a + 1) * log(x) - b_numer / x + const
}

lp_log_gamma <- log_den_logx_2param(log_dgamma)
lp_log_igamma <- log_den_logx_2param(log_digamma)

lp_logit_unif <- function(logit_u) {
  logit_u - 2 * log(1 + exp(logit_u))
}
