#include "mcmc.h"
// want to do all this most efficiently without NumericVector's. 
// Just vectors. then make wrapper for R.

struct State { 
  NumericVector beta;
  double tau2; // nugget
  double sig2; // covariance function scale
  double phi;  // range
  double nu;   // smoothness
};

//[[Rcpp::export]]
NumericMatrix fit(NumericVector y, NumericMatrix X,
                  NumericMatrix s, 
                  NumericMatrix stepSig,
                  double a_tau, double b_tau,
                  double a_sig, double b_sig,
                  double a_phi, double b_phi,
                  double a_nu,  double b_nu,
                  int B, int burn, int printEvery) {

  // Initialize
  //const int n = y.size();
  //const int k = X.
  //std::vector<double> init_v(y.size(), 0.5);
  //auto init = State{ init_v };
  //NumericMatrix out(y.size(), B);


  //// Update Fn
  //auto update = [alpha, cs, y, m] (State& state) {
  //  auto lf = [&y,&m](double p, int i) {
  //    return y[i] * log(p) + (m - y[i]) * log(1-p);
  //  };
  //  auto lg0 = [](double p){return 0.0;};
  //  auto rg0 = [](){return R::runif(0,1);};

  //  algo8(alpha, state.v, cs, lf, lg0, rg0, metLogit);
  //};


  //// Assign Function
  //auto ass = [&out](State const &state, int i) {
  //  NumericVector col( state.v.begin(), state.v.end() );
  //  out(_, i) = col;
  //};


  //gibbs<State>(init, update, ass, B, burn, printEvery);

  //return out;
  return X;
}
