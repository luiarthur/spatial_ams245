eigen_approx <- function(d, J=100, L=1) {
  #j <- 1:J
  j <- seq(-L,L, len=J)
  ### CHECK THIS ###
  f <- function(k) 1 / (1 + k^2)
  #f <- function(k) 1 / (1 + k*1i)

  lam <- f(j * pi / (2 * L))

  psi <- function(d) {
    p <- 1i * j * pi * d / (2*L)
    exp_p <- exp(p)
    #exp_p / sum(exp_p) # do I normalize like this?
    exp_p
  }
 
  # Note: 1/J == psi(0)
  #out <- sum( lam * Conj(psi(0)) * psi(d) )
  #out <- sum( lam * psi(0) * Conj(psi(d)) )
  out <- sum(lam *  psi(d)) / sum(lam * psi(0)) # normalizing?

  #stopifnot(Im(out) == 0)
  #Re(out)
  Re(out)
}

