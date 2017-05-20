library(Rcpp)
Sys.setenv("PKG_CXXFLAGS"="-std=c++11")
sourceCpp("test.cpp")

add_one(10)

