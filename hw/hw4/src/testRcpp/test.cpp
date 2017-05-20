#include<Rcpp.h>
#include<functional>

using namespace Rcpp;

// [[Rcpp::plugins(cpp11)]]



//[[Rcpp::export]]
double add_one(double x) {
  //auto adder = [&](double num, double to_add) {
  //  return  num + to_add;
  //};
  //return x + 1;
  auto one = 1.0;
  return x + one;
  //return adder(x, one);
}

