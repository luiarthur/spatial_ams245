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

//[[Rcpp::export]]
double logdmvnorm(arma::vec y, arma::vec m, arma::mat S) {
  double ld_S, sign;
  arma::log_det(ld_S, sign, S);

  const int n = y.size();
  const auto c = y - m;
  
  const arma::vec v = c.t() * S.i() * c;
  return -0.5 * (ld_S + v[0] + n * log(2*M_PI));
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
              arma::vec init_beta,
              double a_tau, double b_tau, double init_tau2,
              double a_sig, double b_sig, double init_sig2,
              double a_phi, double b_phi, double init_phi,
              double a_nu,  double b_nu,  double init_nu,
              int B, int burn, int printEvery) {

  // Initialize
  const int n = X.n_rows;
  const int k = X.n_cols;
  const int p = 4; // number of params in cov matrix
  //const arma::vec init_beta = arma::zeros<arma::vec>(k);
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
  auto update = [&] (State& state) {
    arma::mat R(n, n);
    for (int i=0; i<n; i++) for (int j=0; j<n; j++) {
      R(i, j) = matern(D(i,j), state.phi, state.nu);
    }
    arma::mat V = state.tau2 * I_n + state.sig2 * R;

    // update beta
    const arma::mat   Vi = V.i();
    const arma::mat   XtVi = X.t() * Vi;
    const arma::mat   Sig_hat = (XtVi * X).i();
    const arma::vec   beta_hat = Sig_hat * XtVi * y;
    state.beta = rmvnorm(beta_hat, Sig_hat);
     
    // update cov params FIXME
    auto ll = [&](arma::vec trans_v) {
      const double tau2 = exp(trans_v[0]);
      const double sig2 = exp(trans_v[1]);
      const double phi = inv_logit(trans_v[2], a_phi, b_phi);
      const double nu = inv_logit(trans_v[3], a_nu, b_nu);

      arma::mat R(n, n);
      for (int i=0; i<n; i++) for (int j=0; j<n; j++) {
        R(i, j) = matern(D(i,j), phi, nu);
      }
      arma::mat V = tau2 * I_n + sig2 * R;

      return logdmvnorm(y, X * state.beta, V);
    };

    auto lp = [&](arma::vec trans_v) {
      return metropolis::lp_log_invgamma(trans_v[0], a_tau, b_tau) + 
             metropolis::lp_log_invgamma(trans_v[1], a_sig, b_sig) + 
             metropolis::lp_logit_unif(trans_v[2]) + 
             metropolis::lp_logit_unif(trans_v[3]);
    };

    const arma::vec curr = { log(state.tau2),
                             log(state.sig2),
                             logit(state.phi, a_phi, b_phi), 
                             logit(state.nu, a_nu, b_nu) };
    const arma::vec nxt = metropolis::mv(curr, ll, lp, stepSig);
    
    state.tau2 = exp(nxt[0]);
    state.sig2 = exp(nxt[1]);
    state.phi = inv_logit(nxt[2], a_phi, b_phi);
    state.sig2 = inv_logit(nxt[3], a_nu, b_nu);
  };

  //// Assign Function
  auto ass = [&](State const &state, int i) {
    for (int j=0; j<k; j++) {
      out(j, i) = state.beta(j);
    }
    out(k + 0, i) = state.tau2;
    out(k + 1, i) = state.sig2;
    out(k + 2, i) = state.phi;
    out(k + 3, i) = state.nu;
  };


  gibbs<State>(init, update, ass, B, burn, printEvery);

  //return D;
  return out.t();
}
