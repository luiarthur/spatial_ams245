#geoR::matern(1,2,3)
source("mcmc.R")

matern <- function(d, phi, nu) {
  #' @param
  #' d:     distance
  #' phi:   range
  #' nu:    smoothness
  #' @export
  u <- ifelse(d > 0, d / phi, .Machine$double.eps)
  logR <- -((nu-1) * log(2) + lgamma(nu)) + 
          nu * log(u) + log(besselK(u, nu))
  exp(logR)
}

gp <- function(y, X, s, 
               stepSigCov,
               a_tau=2, b_tau=1, 
               a_sig=2, b_sig=1, 
               a_phi=0, b_phi=2, 
               nu_choice=seq(.5, 2, len=4),
               B=2000, burn=1000, print_every=0) {

  n <- nrow(X)
  k <- ncol(X)
  p <- 3
  Xt <- t(X)
  stopifnot(n == length(y) && n == NROW(s))

  D <- as.matrix(dist(s))
  I_n <- diag(n)

  update <- function(state) {
    out <- state

    # update beta
    R <- matern(d=D, phi=out$phi, nu=out$nu)
    V <- out$tau2 * I_n + out$sig2 * R
    Vi <- solve(V)
    XtVi <- Xt %*% Vi
    Sig_hat <- solve(XtVi %*% X) ### Make sure this is right
    beta_hat <- Sig_hat %*% XtVi %*% y
    out$beta <- mvrnorm(beta_hat, Sig_hat)

    # update tau2, sig2, phi
    ll <- function(trans_param) {
      param <- c(exp(trans_param[1]), 
                 exp(trans_param[2]),
                 inv_logit(trans_param[3], a_phi, b_phi))

      R <- matern(d=D, phi=param[3], nu=out$nu)
      V <- param[1] * I_n + param[2] * R
      
      ldmvnorm(y, X %*% out$beta, V)
    }

    lp <- function(trans_param) {
      lp_log_invgamma(trans_param[1], a_tau, b_tau) +
      lp_log_invgamma(trans_param[2], a_sig, b_sig) +
      lp_logit_unif(trans_param[3])
    }

    trans_curr_cov_param <- c(log(out$tau2), log(out$sig2), 
                              logit(out$phi, a_phi, b_phi))

    mh_trans <- mh_mv(trans_curr_cov_param, ll, lp, stepSigCov)
    out$tau2 <- exp(mh_trans[1])
    out$sig2 <- exp(mh_trans[2])
    out$phi <- inv_logit(mh_trans[3], a_phi, b_phi)

    # Update nu
    ll_nu <- function(nu) {
      R <- matern(d=D, phi=out$phi, nu=nu)
      V <- out$tau2 * I_n + out$sig2 * R
      ldmvnorm(y, X %*% out$beta, V)
    }

    log_prob <- sapply(nu_choice, ll_nu)
    prob <- exp(log_prob - max(log_prob))
    out$nu <- sample(nu_choice, 1, prob=prob)

    out
  }

  init <- list(beta=double(k),
               tau2=b_tau, sig2=b_sig, 
               phi= (a_phi + b_phi) / 2,
               nu= sample(nu_choice, 1))
               #nu = (a_nu + b_nu) / 2)

  gibbs_out <- gibbs(init, update, B, burn, print_every)
  
  out <- matrix(NA, p + k + 1, B) 

  out[1:k, ] <- sapply(gibbs_out, function(x) x$beta)
  out[k+1,] <- sapply(gibbs_out, function(x) x$tau2)
  out[k+2,] <- sapply(gibbs_out, function(x) x$sig2)
  out[k+3,] <- sapply(gibbs_out, function(x) x$phi)
  out[k+4,] <- sapply(gibbs_out, function(x) x$nu)

  rownames(out) <- c(paste0('beta',1:k), 'tau2', 'sig2', 'phi', 'nu')
  t(out)
}


