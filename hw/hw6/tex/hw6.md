---
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
    - \pagestyle{empty}
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
    # Other header-includes:
include-before:
- \title{Process Convolution with Different Priors for Convolution Coefficient}
- \author{Arthur Lui \\ UC Santa Cruz \\\\ \today}
- \maketitle
---

\abstract{
  The United States Environmental Protection Agency (EPA) monitors the air quality
  constantly to regulate air quality in the United States. One measurement of air
  quality is ozone levels. Air quality in any geographical area is spatially correlated,
  and so can be naturally modeled with spatial models. In addition, Bayesian models provide
  much modeling flexibility while providing intuitive interpretation of model
  parameter estimates and predictions. This analysis, investigates the 
  model fit of a process convolution with two different priors for the
  convolution coefficients - (1) independent Normal priors and (2) a Markov
  random field prior. The fitted models are compared.

  \keywords{Gaussian process, process convolution, Markov random field prior}
}

# Introduction to Data
The data for this analysis consists of the annual summary air data provided by
the United States Environmental Protection Agency (EPA) from 2015 for the state
of California. The state had 135 unique monitoring stations with the parameters
of interest, namely 

- `Parameter Name` = "Ozone"
- `Sample Duration` = "8-HR RUN AVG BEGIN HOUR"
- `Pollutant Standard` = "Ozone 8-Hour 2008"
- `Event Type` is one of "No Events", "Concurred Events Excluded", or "Events Excluded", and
- `Completeness.Indicator` = "Y".

The parameters used in the design matrix in this analysis are an intercept term,
longitude, and log-altitude (or log-elevation). Consequently, those variables
are extracted from the database. The response variable being ozone level (ppb).
Figure \ref{data} shows the Ozone levels at the 135 observed locations.
The small circles on the graph are the knot points used in the analysis.
They will be discussed in a later section.

\begin{figure}[H]
\includegraphics[scale=.5]{img/data.pdf}
\caption{Ozone levels (ppb) at observed locations. Small circles represent the knot points used in the process convolution.}
\label{data}
\end{figure}

# Methods

## Convolution Process
Given a set of observations $y_{s1}, ..., y_{s_n}$ at locations
$s1, ..., s_n$, the (discrete) Gaussian convolution process model has the 
form

$$
y_{s_i} = \mu(s_i) + \sum_{j=1}^m k(s_i - u_j; \psi) z_j + \epsilon_{s_i}
$$

where $\epsilon_{s_i} \sim \N(0,\tau^2)$. The model requires a set of
predetermined knot points $\bc{u_1, ..., u_m}$, which can chosen to be
equidistant from each other within the domain of the observation locations.
The model also requires a convolution kernel. The kernel used in this
analysis is the spherical Bezier kernel, having the form

$$
k(s; \nu) = \begin{cases}
(1 - \norm{s}^2)^\nu & \text{ if } \norm{s} < 1, \text{ for } \nu > 0 \\
0 & \text{ otherwise.}\\
\end{cases}
$$

The model is fully specified with priors for $\psi (= \nu)$, $\tau^2$. The mean
function $\mu(s_i)$ can be chosen to be the product of some design matrix and
unknown coefficients $X_{s_i} \beta$. A suitable prior for the coefficients of
this linear component is $p(\beta) \propto 1$. An inverse Gamma prior is
suitable for the $\tau^2$ as it is a conjugate prior. The prior for $\tau^2$
can be weakly informative. The prior used for this analysis is $\tau^2 \sim
\text{IG}(2,1)$ to have a prior mean of 1 and infinite prior variance.  There
can be no conjugate prior for $\nu$, and so an inverse Gamma prior is placed on
$\nu$. Again, the prior used for $\nu$ is $\nu \sim \text{IG}(2,1)$. Priors for
$\bc{z_1,...,z_m}$ are also needed and will be discussed in the next two
sections. 

### Independent Normal Priors for Convolution Coefficients
One choice of priors for $\bm z$ are independent Gaussian priors $z_j \mid
\sigma^2 \ind \N(0,\sigma^2)$. The full conditional distribution of $\bm z$
is again a Normal distribution, and so can be updated as a vector efficiently.
An inverse Gamma (conjugate) prior can be placed for $\sigma^2$. The inverse
Gamma distribution can be weakly informative. The prior used for this analysis
is $\sigma^2 \sim \text{IG}(2,1)$.

### Markov Random Field Prior for Convolution Coefficients
Alternatively, a Markov random field prior can be placed on $\bm z$.
What follows is a brief definition of Gaussian Markov random fields.
A random vector $\bm x\in \mathbb{R}^n$ with Gaussian Markov random field (GMRF)
with mean $\mu$ and precision matrix $W$ if and only if its density has
the form

$$
p(\bm x) \propto \abs{W}^{1/2} \exp\bc{-\frac{1}{2}(\bm x - \mu)^T W(\bm x - \mu)}
$$

where $W_{ij} = 0 \iff i\sim j$ and $i\sim j$ denotes that $i$ is a neighbor of $j$.

Placing a GMRF prior on $\bm z$, we have that $\bm z \sim \text{GMRF}(\lambda W)$
where $\lambda$ is a precision scale and $W$ is a precision matrix with 
$$
W_{ij} = \begin{cases}
n_{ij} & \text { if } i=j \\ 
-1 & \text { if } i\sim j \\
0 & \text {otherwise} 
\end{cases}
$$
and $n_{ij}$ is the number of neighbors of $z_i$.

The full conditional distribution of $z$ is again a Normal distribution.
A suitable prior for the precision scale $\lambda$ is a Gamma prior.
The prior can be weakly informative. The form used for this analysis
is $\lambda \sim \text{Gamma}(.01,.01)$ to have a prior mean of 1 and prior
variance of 100.

## Determining the Knot Points
The knot points chosen for this analysis are 36 equally spaced within the
domain where data are observed. This is for convenience in the case of GMRF
priors for the convolution coefficients.

## Determining the Prediction Locations
Prediction locations require not only the desired prediction coordinates,
but the altitude (or log altitude) of at the locations as well. As this information
is not available at all possible locations, only locations where that information
is provided from the raw data are used. 807 such locations (including
the data used to fit the model) are available.

# Analysis
The joint posterior distribution of the model parameters were sampled
from using Markov Chain Monte Carlo (MCMC). Specifically, a Gibbs
sampler with the aforementioned updates for each parameter were 
used to sequentially sample from the full conditional of each
parameter. The chains were run for 4000 iterations, with the first 
3000 iterations discarded.

For convenience, let $\M_1$ be the model with iid Normal
priors for the convolution coefficients, and $\M_2$ be
the model with the GMRF prior for the convolution coefficients.

## Posterior of Model Parameters

\input{img/post1.tex}
\input{img/post2.tex}
\input{img/post.tex}

## Posterior Predictive Means

\begin{figure*}
  \centering
  \includegraphics[width=.9\textwidth]{img/pred.pdf}
  \caption{}
  \label{fig:pred}
\end{figure*}

## Posterior Predictive Variance
\begin{figure*}
  \centering
  \includegraphics[width=.9\textwidth]{img/predvar.pdf}
  \caption{}
  \label{fig:predvar}
\end{figure*}


## Residual Analysis
The posterior probability of the residuals of $\M_1$ being greater that of
$\M_2$ is \input{img/postResidProb.tex}. That is, $\M_1$ (iid Normal priors for
convolution weights) may have better fit.

# Conclusions


[comment]: <> (%
For figures and tables to stretch across two columns
use \begin{figure*} \end{figure*} and
\begin{table*}\end{table*}
%)
