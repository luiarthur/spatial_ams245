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
    - \pagestyle{plain}
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
and $n_{ij}$ is the number of neighbors of $z_i$. For this analysis, a knots
neighbors are its **nearest** knots. (i.e., the knots directly north,
east, south, and west of any given knot.) In theory, by this construction, a
knot can have at most four neighbors, and at least one neighbor. However, for
the set of knots chosen in this analysis, each knot had exactly two, three, or
four neighbor.

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
Table \ref{post1} summarizes the posterior distribution of parameters in $\M_1$.
The table reports the posterior means, standard deviations, and 95% credible 
intervals. All the coefficients appear important (as their credible intervals
do not contain 0). The intercept is large, which compensates for the longitude
having large negative values. The coefficient for longitude suggests that
ignoring the spatial effect of location, for every unit increase in longitude,
the ozone level average increase is 1.45 (ppb). Likewise, the interpretation of
the coefficient for log-altitude is ignoring the spatial effect of location,
for every unit increase in log-altitude, the ozone level average increase is
2.17 (ppb). Heuristically, (south-)eastern locations and more elevated locations
have higher ozone levels. This is reasonable as in California, the
south-eastern locations hotter (which are known to be more prone to higher
ozone levels) and locations which are higher naturally have higher ozone
levels. Note that here, $\sigma^2$ is the variance of the convolution
coefficient $z$, $\tau^2$ is the observational variance, and $\nu$ is the smoothness
parameter in the spherical Bezier kernel.

\begin{table}[H]
\input{img/post1.tex}
\caption{Posterior summary of model parameters in $\M_1$.}
\label{post1}
\end{table}

Table \ref{post2} summarizes the posterior distribution of parameters in $\M_2$.
Note that here, $\lambda$ is the precision scale of the convolution coefficients.

\begin{table}[H]
\input{img/post2.tex}
\caption{Posterior summary of model parameters in $\M_2$.}
\label{post2}
\end{table}

Table \ref{post} summarizes the differences between common model parameters 
(i.e. parameters of $\M_1$ - parameters of $\M_2$). It does not make sense
to compare $\lambda$ to $\sigma^2$, so the two parameters are not compared. 
Note that the coefficient for log-altitude is significantly different for
the two models, with that of $\M_1$ being 0.2 units higher in expectation.

\begin{table}[H]
\input{img/post.tex}
\caption{Posterior summary of differences between common model parameters (parameters of $\M_1$ - parameters of $\M_2$).}
\label{post}
\end{table}

## Posterior Predictive 

Figure \ref{pred} shows the posterior predictive for both models. As mentioned
before, there are 807 prediction locations. But for better visualization, the
plots are smoothed (using the `MBA::mba.surf` function in `R`) to have higher
resolution. The middle column of plots are simply the data, plotted for convenient
reference. The top-left panel is the posterior predictive mean under $\M_1$. 
The panel directly below is the posterior predictive mean under $\M_2$.
There appear to be no striking differences. The next two panels below (still
in the first column) are the posterior predictive standard deviations under the
two models. The similarities are that at the knots where not as many observations
are available, the uncertainty is higher. Moreover, at the top-left corner of 
the maps, the uncertainty under $\M_2$ is higher than that of $\M_2$. This is
likely due to the structure of the precision matrix in $\M_2$, which only
permits correlation with neighbors.

The panels on the right in Figure \ref{pred} display the posterior distributions
of the system mean $X^*\beta$ for both models. In that column, the first two plots
show the expectation. Notably, the surface for $\M_2$ has fewer red patches. This
is likely due to the model absorbing more of the variability due to altitude
into the spatial modeling. (This is possibly associated with the difference in the
estimates for the coefficient for log-altitude.) The next two panels show the
posterior standard deviations. Once again, the uncertainty is greater at the 
corners of the maps, with $\M_2$ having greater variance overall, but especially
in the corners.

\begin{figure*}
  \centering
  \includegraphics[width=.8\textwidth]{img/pred.pdf}
  \caption{Posterior predictive mean and standard deviations. Middle column is 
  the data (for reference).
  }
  \label{pred}
\end{figure*}

To summarize, the posterior predictive mean surfaces under the two models are
similar, with the only difference being the uncertainty at the corners of
the maps. $\M_2$ has greater uncertainty at the corners.

## Residual Analysis
Figure \ref{resid} shows the posterior mean of the residuals under the two models.
Visually, the residuals seem to have the same patterns. At some locations where
the ozone levels are unusually high or low, the residuals are larger in magnitude.
Suggesting either that the models are not capturing the tails of the behavior
at the tails of the distribution, or the extreme observations are outliers.

\begin{figure}[ht]
  \centering
  \includegraphics[width=.4\textwidth]{img/resid.pdf}
  \caption{Posterior mean of residuals.}
  \label{resid}
\end{figure}

The posterior probability of the residuals of $\M_1$ being greater that of
$\M_2$ is \input{img/postResidProb.tex}. That is, $\M_1$ (iid Normal priors for
convolution weights) may have better fit.

# Conclusions
Fitting convolution processes to model the data can take less computation time
than Gaussian processes. In this analysis, two convolution process models
are explored. One with iid Normal priors for the convolution coefficients, and 
another with a GMRF prior. The model parameters are mostly similar, with the
exception of the coefficient related to altitude. The posterior predictive mean
surfaces under both models appear to be very similar, with the only notable
difference being that the uncertainty at the corners (boundaries) of the map
are higher for the GMRF model. A residual analysis reveals that the residuals
of $\M_2$ (GMRF prior) are higher than that of $\M_1$ (iid Normal priors). This
suggests that the simpler model with Gaussian priors for the convolution
coefficients may have better model fit, while being more parsimonious. 

[comment]: <> (%
For figures and tables to stretch across two columns
use \begin{figure*} \end{figure*} and
\begin{table*}\end{table*}
%)
