#semicov.est <- function(y,s) {
#  n <- length(y)
#  stopifnot(n == NROW(s))
#
#  gam <- sapply(1:n, function(i) (y[i] - y[i])^2) / 2
#
#  cbind(s, gam)
#}
#
#x <- sort(rnorm(100))
#semicov.est(x,1:100)
