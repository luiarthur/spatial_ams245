---
title: "Spatial Statistics HW5"
author: Arthur Lui
date: "\\today"
geometry: margin=1in
fontsize: 12pt

# Uncomment if using natbib:

# bibliography: BIB.bib
# bibliographystyle: plain 

# This is how you use bibtex refs: @nameOfRef
# see: http://www.mdlerch.com/tutorial-for-pandoc-citations-markdown-to-latex.html

header-includes: 
#{{{1
    - \usepackage{bm}
    - \usepackage{bbm}
    - \usepackage{graphicx}
    #- \pagestyle{empty}
    - \newcommand{\norm}[1]{\left\lVert#1\right\rVert}
    - \newcommand{\p}[1]{\left(#1\right)}
    - \newcommand{\bk}[1]{\left[#1\right]}
    - \newcommand{\bc}[1]{ \left\{#1\right\} }
    - \newcommand{\abs}[1]{ \left|#1\right| }
    - \newcommand{\mat}{ \begin{pmatrix} }
    - \newcommand{\tam}{ \end{pmatrix} }
    - \newcommand{\suml}{ \sum_{i=1}^n }
    - \newcommand{\prodl}{ \prod_{i=1}^n }
    - \newcommand{\ds}{ \displaystyle }
    - \newcommand{\df}[2]{ \frac{d#1}{d#2} }
    - \newcommand{\ddf}[2]{ \frac{d^2#1}{d{#2}^2} }
    - \newcommand{\pd}[2]{ \frac{\partial#1}{\partial#2} }
    - \newcommand{\pdd}[2]{\frac{\partial^2#1}{\partial{#2}^2} }
    - \newcommand{\N}{ \mathcal{N} }
    - \newcommand{\E}{ \text{E} }
    - \def\given{~\bigg|~}
    # Figures in correct place
    - \usepackage{float}
    - \def\beginmyfig{\begin{figure}[H]\center}
    - \def\endmyfig{\end{figure}}
    - \newcommand{\iid}{\overset{iid}{\sim}}
    - \newcommand{\ind}{\overset{ind}{\sim}}
    - \newcommand{\I}{\mathrm{\mathbf{I}}}
    #
    - \allowdisplaybreaks
    - \def\M{\mathcal{M}}
#}}}1
    # For this assignment:
    # - \def\bla
---

[comment]: <> (%
  These are comments
%)

Figure \ref{data} shows the observations gathered at some locations for the
variables ozone (O3), nitrogen dioxide (NO2) and PM2.5. In only three 
locations are all three variables observed. Though in most other areas
where one of the variables are observed, often another variable is also
observed there. We will compare the properties of fitting a univariate
Gaussian process (GP) and multivariate predictive GP using the `spBayes`
package in `R`.

# Data
![Data for Ozone, NO2, and PM2.5. Observations for each variable are not available simultaneously for all locations. In fact, only three locations have observations for all three variables.](img/data.pdf){id='data'}


# Posterior Distribution of Coefficients (Univariate GP)

First, a univariate GP is fit to the data for each variable. That is, three
separate GP's are fit to the data. Each fit with a matern covariance function
and linear trends for longitude and log-elevation. Figures \ref{ogp},
\ref{ngp}, and \ref{pgp} show the posterior distributions of the coefficients.
It is worth noting that for NO2, it appears that longitude and the intercept do
not significantly contribute to the model. Also, for PM2.5, none of the variables
contribute significantly to the model.

![Posterior distribution of Coefficients in univariate GP model for Ozone (measured in parts per billion or ppb).](img/ozoneBeta.pdf){ height=50% id='ogp'}

![Posterior distribution of Coefficients in univariate GP model for nitrogen dioxide (NO2).](img/NO2Beta.pdf){ height=50% id='ngp'}

![Posterior distribution of Coefficients in univariate GP model for PM2.5.](img/PMBeta.pdf){ height=50% id='pgp'}

Due to limitations of the `spBayes` package, predictions were made at the
locations where there is at least one observation (ozone, NO2, or PM2.5).  The
posterior predictive means at those locations for each variable are used in the
multivariate predictive process.

# Posterior Distribution of Coefficients (Multivariate GP)

Next, a multivariate GP is fit to the data, again using a matern covariance
function and linear trends for longitude and log-elevation.  Figures \ref{omvgp},
\ref{nmvgp}, and \ref{pmvgp} show the posterior distributions of the coefficients.

![Posterior distribution of Coefficients in multivariate GP model for Ozone (measured in parts per billion or ppb).](img/ozoneMVBeta.pdf){ height=50% id='omvgp'}

![Posterior distribution of Coefficients in multivariate GP model for nitrogen dioxide (NO2).](img/NO2MVBeta.pdf){ height=50% id='nmvgp'}

![Posterior distribution of Coefficients in multivariate GP model for PM2.5.](img/PMMVBeta.pdf){ height=50% id='pmvgp'}

Predictions are made at yet another set of new locations where there information about elevation (one of the covariates)
is available. 100 such locations were available from the raw data. 

# Posterior Predictive Surface

Figure \ref{hd} shows the posterior predictive surfaces for the univariate and
multivariate GP models for each variable (together with the data for
comparison).  In the univariate model, we see that the predictions simply smooth
over the observations. In the multivariate model, the prediction surface
resembles that of the univariate model. A model comparison can be done
by computing out-of-sample MSE's for each model. But I did not do this
because the model took quite long to run.

![Posterior Predictive surfaces for univariate GP (left) and multivariate predictive process (right) models.](img/allHD.pdf){id='hd'}
