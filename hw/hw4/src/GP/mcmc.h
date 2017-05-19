#include<RcppArmadillo.h> // linear algebra
#include<functional>      // std::function

using namespace Rcpp;

// Enable C++11 via this plugin (Rcpp 0.10.3 or later)
// [[Rcpp::plugins("cpp11")]]

// [[Rcpp::depends(RcppArmadillo)]]


// Generic Gibbs Sampler
template <typename S>
void gibbs(S state, 
          std::function<void(S&)> update, // function to update state
          std::function<void(const S&, int)> assign_to_out, // function to assign to out
          int B, int burn, int print_every) {

  for (int i=0; i<B+burn; i++) {
    update(state);
    if (i > burn) {
      assign_to_out(state, i-burn-1);
    }

    if (print_every > 0 && (i+1) % print_every == 0) {
      Rcout << "\rProgress:  " << i+1 << "/" << B+burn << "\t";
    }
  }

  if (print_every > 0) { Rcout << std::endl; }
}

double logit(double p) {
  return log(p / (1 - p);
}

double inv_logit(double x) {
  return 1 / (1 + exp(-x));
}


// Weighted sampling: takes prob. array and size; returns index.
int wsample_index(double p[], int n) { // GOOD
  const double p_sum = std::accumulate(p, p+n, 0.0);
  const double u = R::runif(0,p_sum);

  int i = 0;
  double cumsum = 0;

  do {
    cumsum += p[i];
    i++;
  } while (cumsum < u);

  return i-1;
}

namespace metropolis {
  arma::vec rmvnorm(m, S) {
    int n = M.n_rows;
    arma::mat e = arma::randn(n);
    return M + arma::chol(S).t() * e;
  }

  // Uniariate Metropolis step with Normal proposal
  double uni(double curr, std::function<double(double)> ll, 
                    std::function<double(double)> lp, double stepSig) {
    const double cand = R::rnorm(curr,stepSig);
    const double u = R::runif(0,1);
    double out;

    if (ll(cand) + lp(cand) - ll(curr) - lp(curr) > log(u)) {
      out = cand;
    } else {
      out = curr;
    }

    return out;
  }

  // Uniariate Metropolis step with Normal proposal
  NumericVector mv(NumericVector curr, std::function<double(NumericVector)> ll, 
                   std::function<double(NumericVector)> lp, NumericMatrix stepSig) {
    const double cand = rmvnorm(curr, stepSig);
    const double u = R::runif(0, 1);
    NumericVector out;

    if (ll(cand) + lp(cand) - ll(curr) - lp(curr) > log(u)) {
      out = cand;
    } else {
      out = curr;
    }

    return out;
  }

  double lp_gamma(double x, double shape, double rate) {
    return (shape - 1) * log(x) - rate * x;
  }

  double lp_gamma_with_const(double x, double shape, double rate) {
    return lp_gamma(x, shape, rate) + shape * log(rate) - lgamma(shape);
  }

  double lp_igamma(double x, double a, double bNumer) {
    return -(a + 1) * log(x) - bNumer / x;
  }

  double lp_igamma_with_const(double x, double a, double bNumer) {
    return lp_igamma(x, a, bNumer) + a * log(bNumer) - lgamma(a);
  }

  double lp_log_gamma(double log_x, double shape, double rate) {
    return lp_gamma(exp(log_x), shape, rate) + log_x;
  }

  double lp_log_igamma(double log_x, double a, double bNumer) {
    return lp_igamma(exp(log_x), shape, rate) + log_x;
  }

  double lp_log_gamma_with_const(double log_x, double shape, double rate) {
    return lp_gamma_with_const(exp(log_x), shape, rate) + log_x;
  }

  double lp_log_igamma_with_const(double log_x, double a, double bNumer) {
    return lp_igamma_with_const(exp(log_x), shape, rate) + log_x;
  }

  double lp_logit_unif(double logit_u) {
    return logit_u - 2 * log(1+ exp(logit_u));
  }
}
