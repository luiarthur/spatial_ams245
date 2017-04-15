### HW: ###
# Plot all the covariograms and variograms in the tables of the second set of
# slides. Take the variance to be 1, and take the range parameter to be such
# that the correlation is .05 at a distance of one unit


semi_variogram <- function(cov_fn) {
  #' @param cov_fn: covariance functino with
  #'                parameters cov_fn(distance, range, variance, nu=0)

  function(d, phi, sig2, nu) {
    cov_fn(0, phi, sig2, nu) - cov_fn(d, phi, sig2, nu)
  }
}


# List of covariance functions with parameters (distance, range, variance)
cov_fn <- list(sphere = function(d, phi, sig2=1, nu=0) {
                 ifelse (d > phi, 
                         0,
                         sig2 * (1 - 1.5 * d / phi + .5 * (d / phi) ^ 3))
               }, 
               pow_exp = function(d, phi, sig2, nu=1) {
                 stopifnot(nu > 0 && nu < 2)
                 sig2 * exp(-abs(d / phi) ^ nu)
               },
               rational_quad = function(d, phi, sig2, nu=0) {
                 sig2 * (phi^2 / (d^2 + phi^2) )
               }, 
               wave = function(d, phi, sig2, nu=0) {
                 x <- d / phi
                 sig2 * (sin(x) / x)
               }, 
               matern = function(d, phi, sig2, nu=0) {
                 x <- sqrt(2 * nu) * d / phi
                 sig2  / (2^(nu-1) * gamma(nu)) * x^nu * besselK(x, nu)
               })
