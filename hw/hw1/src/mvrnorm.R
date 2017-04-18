mvrnorm <- function(M,S,n=nrow(S)) M + t(chol(S)) %*% rnorm(n)

mvrnorm_generator <- function(S) {
  stopifnot(ncol(S) == nrow(S))
  function(M) M + t(chol(S)) %*% rnorm(ncol(S))
}
