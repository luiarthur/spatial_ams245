#include<Rcpp.h>
#include<functional> // std::function

using namespace Rcpp;

// Enable C++11 via this plugin (Rcpp 0.10.3 or later)
// [[Rcpp::plugins("cpp11")]]


// Generic Gibbs Sampler
template <typename S>
void gibbs(S state, 
          std::function<void(S&)> update, // function to update state
          std::function<void(const S&, int)> ass // function to assign to out,
          int B, int burn, int print_every) {

  for (int i=0; i<B+burn; i++) {
    update(state);
    if (i > burn) {
      ass(state, i-burn-1);
    }

    if (print_every > 0 && (i+1) % print_every == 0) {
      Rcout << "\rProgress:  " << i+1 << "/" << B+burn << "\t";
    }
  }

  if (print_every > 0) { Rcout << std::endl; }
}

// Uniariate Metropolis step with Normal proposal
double metropolis(double curr, std::function<double(double)> ll, 
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


