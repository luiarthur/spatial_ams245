#include "mcmc.h"
// want to do all this most efficiently without NumericVector's. 
// Just vectors. then make wrapper for R.

struct State { 
  arma::vec beta;
  double tau2; // nugget
  double sig2; // covariance function scale
  double phi;  // range
  double nu;   // smoothness
};

/*  d:   distance
 *  phi: range
 *  nu:  smoothness
 *  bessel: http://dirk.eddelbuettel.com/code/rcpp/html/Rmath_8h_source.html
 */

double logdmvnorm(arma::vec y, arma::vec m, arma::mat S) {
  double ld_S, sign;
  arma::log_det(ld_S, sign, S);

  const int n = y.size();
  const auto c = arma::reshape(y - m, n, 1);
  
  const arma::mat K = c.t() * inv(S) * c;
  return -0.5 * (ld_S + K(0,0));
}

double matern(double d, double phi, double nu) { // GOOD
  // bessel_k = besselK in R
  const double u = (d > 0) ? d / phi : 1E-10;
  const double logR = -((nu-1) * log(2) + R::lgammafn(nu)) + 
                      nu * log(u) + log(R::bessel_k(u, nu, 1));
  return exp(logR);
}

//[[Rcpp::export]]
arma::mat fit(arma::vec y, arma::mat X,
              arma::mat s, 
              arma::mat stepSig,
              double a_tau, double b_tau,
              double a_sig, double b_sig,
              double a_phi, double b_phi,
              double a_nu,  double b_nu,
              int B, int burn, int printEvery) {

  // Initialize
  const int n = X.n_rows;
  const int k = X.n_cols;
  const int p = 4; // number of params in cov matrix
  const arma::vec init_beta = arma::zeros<arma::vec>(k);
  const auto init_tau2 = 1.0;
  const auto init_sig2 = 1.0;
  const auto init_phi = (a_phi + b_phi) / 2.0;
  const auto init_nu = (a_nu + b_nu) / 2.0;
  const auto I_n = arma::eye<arma::mat>(n, n);
  auto init = State{ init_beta, init_tau2, init_sig2, init_phi, init_nu };

  const auto bla = logdmvnorm(y, y, I_n);

  // Distance Matrix
  Function dist = Environment("package:stats")["dist"];
  Function as_matrix = Environment("package:base")["as.matrix"];
  /* as<arma::mat>(x) => cast NumericMatrix as arma::mat
   * wrap(x) => cast SEXP as Rcpp type (NumericMatrix / NumericVector)
   */
  arma::mat D = as<arma::mat>( wrap(as_matrix(dist(s))) );

  // preallocate output
  arma::mat out(k + p, B);

  // Update Fn
  auto update = [&y, &X, &D, &I_n, n, k, p] (State& state) {
    arma::mat R(n, n);
    for (int i=0; i<n; i++) {
      for (int j=0; j<n; j++) {
        R(i, j) = matern(D(i,j), state.phi, state.nu);
      }
    }
    arma::mat V = state.tau2 * I_n + state.sig2 * R;

    // update beta
    auto const Vi = arma::inv(V);
    auto const XtVi = X.t() * Vi;
    auto const Sig_hat = arma::inv(XtVi * X);
    auto const beta_hat = Sig_hat * XtVi * y;
    state.beta = metropolis::rmvnorm(beta_hat, Sig_hat);
     
    // update cov params FIXME
    //auto ll[&state, &V](double p) {
    //  
    //}

  };


  //// Assign Function
  //auto ass = [&out](State const &state, int i) {
  //  NumericVector col( state.v.begin(), state.v.end() );
  //  out(_, i) = col;
  //};


  //gibbs<State>(init, update, ass, B, burn, printEvery);

  //return out;
  return D;
}
