loglikeSillRange <- function(sig2,tau2,phi,kappa,y,X,s) {
  n <- length(y)
  I_n <- diag(n)
  D <- as.matrix(dist(s))
  V <- sig2 * geoR::matern(D, phi=phi, kappa=kappa) + tau2 * I_n
  Vi <- solve(V)
  XViX <- t(X) %*% Vi %*% X
  b.hat <- solve(XViX) %*% (t(X) %*% Vi %*% y) 
  res <- y - X %*% b.hat
  S <- t(res) %*% Vi %*% res

  #ld_V <- unlist(determinant(V, log=TRUE))[1]
  #ld_XViX <- unlist(determinant(XViX, log=TRUE))[1]
  ld_V <- log(det(V))
  ld_XViX <- log(det(XViX))
  (-1/2) * (ld_V + ld_XViX) - S/2
}

loglikeRange <- function(phi, kappa, tau2OverSig2, y, X, s) {
  n <- length(y)
  k <- ncol(X)
  I_n <- diag(n)
  D <- as.matrix(dist(s))
  V <- geoR::matern(D, phi=phi, kappa=kappa) + tau2OverSig2 * I_n
  Vi <- solve(V)
  XViX <- t(X) %*% Vi %*% X
  b.hat <- solve(XViX) %*% (t(X) %*% Vi %*% y) 
  res <- y - X %*% b.hat
  S <- t(res) %*% Vi %*% res

  #ld_V <- unlist(determinant(V, log=TRUE))[1]
  #ld_XViX <- unlist(determinant(XViX, log=TRUE))[1]
  ld_V <- log(det(V))
  ld_XViX <- log(det(XViX))
  (-1/2) * (ld_V + ld_XViX) - (n-k)/2*log(S)
}
