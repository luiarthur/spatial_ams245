---
# Uncomment if using natbib:
bibliography: BIB.bib
bibliographystyle: plain 

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
    - \newcommand{\y}{\mathrm{\mathbf{y}}}
    - \newcommand{\R}{\mathrm{\mathbf{R}}}
    - \newcommand{\bbeta}{\bm{\beta}}
    - \newcommand{\X}{\mathrm{\mathbf X}}
    - \newcommand{\V}{\mathrm{\mathbf V}}
    - \newcommand{\w}{\bm{w}}
    - \newcommand{\bmu}{\bm{\mu}}
    - \newcommand{\s}{\bm{s}}
    - \newcommand{\zero}{\bm{0}}
    - \newcommand{\IG}{\text{IG}}
    - \newcommand{\GP}{\text{GP}}
    - \newcommand{\Unif}{\text{Unif}}
include-before:
- \title{Bayesian Analysis of Pollutants Data}
- \author{Arthur Lui \\ AMS 245 - Spatial Statistics \\ UC Santa Cruz \\\\ \today}
- \maketitle
---

\abstract{
  The United States Environmental Protection Agency (EPA) monitors the air quality
  constantly to regulate air quality in the United States. One measurement of air
  quality is ozone levels. Air quality in any geographical area is spatially correlated,
  and so are best modeled with spatial models. In addition, Bayesian models provide
  much modeling flexibility while providing intuitive interpretation of model
  parameter estimates and predictions.  In this assignment, I will investigate the 
  covariance structure and trends of ozone levels in the state of California.
  A Gaussian process with a trend function and matern correlation function are used 
  in the Bayesian model.
  \keywords{Gaussian process, matern correlation, MCMC block sampling,
  auxiliary variables}
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

## Exploratory Data Analysis
A heat map of the average ozone levels in each monitoring location is plotted in
Figure \ref{map}. One can observe that coastal areas have lower levels of ozone 
(here and throughout measured in parts per billion), while in-land areas tend
to have moderate to high levels of ozone. In addition, spatial correlation is
clearly observed.

![Heat map of average ozone levels in California.](img/map.pdf){id='map'}

In order to more accurately model the spatial correlation, obvious trends
should first be sought out and removed. Figure \ref{pairsRaw} shows the
histograms and paired scatter plots of ozone levels, latitude, longitude, and
elevation. Clearly, linear relationships exist between ozone levels and both
latitude and longitude.  But the relationship between ozone levels and
elevation is unclear. Figure \ref{mypairs} shows the same plot after
log-transforming elevation.  The transformation reveals a linear relationship
between log elevation and ozone levels

![Histogram and paired scatter plots for ozone level, latitude, longitude, and
elevation](img/pairsRaw.pdf){id='pairsRaw'}

![Histogram and paired scatter plots for ozone level, latitude, longitude, and
log elevation](img/mypairs.pdf){id='mypairs'}

# Methods

## Model
The model fitted to the data was
$$
\begin{split}
\y(\s) &= \bmu(\s) + \bm\epsilon \\
\bmu(\s) &= \X(\s)\bbeta + \w(\s) \\
\end{split}
$$
where $\bm\epsilon \sim \N(\zero,\tau^2 \I)$, $\w \sim \GP(\zero, \sigma^2
\R(\cdot, \cdot))$, and $\R(\cdot, \cdot)$ is the correlation function. This
model suggests errors at the observational level and spatial correlation of the
ozone levels across the state. The design matrix $\X$ is chosen to contain a
column of ones, longitude, and log elevation. Latitude was not included as
latitude and longitude are strongly correlated (due to the shape of the state).
Using only one instead of both of the location values may reduce
multicollinearity. Note that $\sigma^2 \R$ is then the covariance function.

The matern correlation, governed by range $(\phi)$ and smoothness $(\kappa)$
parameters, is chosen as the correlation function $(\R)$ for modeling
flexibility. For computational convenience, let $\gamma^2 = \tau^2 / \sigma^2$
,and let $z$ be an auxiliary variable to be used to estimate the smoothness
parameter $\kappa$. Then the collapsed model with the accompanying
priors is:

\begin{align*}
\y \mid \tau^2, \psi, \bbeta &\sim 
\N_n(\X\bbeta, \tau^2 \V_\psi)\\
%%%
\tau^2 &\sim   \IG(2,1) \\
p(\bbeta) &\propto 1\\
\\
\sigma^2 &\sim \IG(2,1) \\
\phi &\sim \Unif(0, 2) \\
z    &\sim \Unif(0, 3) \\
\kappa \mid z &= \begin{cases}
0.5, & \text{ if } z \in (0,1] \\
1.5, & \text{ if } z \in (1,2] \\
2.5, & \text{ if } z \in (2,3] \\
\end{cases}
\end{align*}
where $\V_\psi = \I + \R/\gamma^2$ and $\psi = (\gamma^2, \phi, \kappa)$
are the parameters that govern the covariance matrix $\V$. 
Note that when $\tau^2 \sim \IG(a_\tau, b_\tau)$ and
$\sigma^2 \sim \IG(a_\sigma, b_\sigma)$, the prior distribution for $\gamma^2 = \tau^2 / \sigma^2$
is $p(\gamma^2) \propto (\gamma^2)^{a_\sigma-1}(\gamma^2 b_\sigma + b_\tau)^{-(a_\tau +
a_\sigma)}$.

The priors for $\tau^2$ and $\sigma^2$ were chosen to have a prior mean of
unity and prior infinite variance, to reflect objectivity and great
uncertainty. The prior for range $\phi$ was chosen to only include values
between 0 and 2 as those were the plausible range of values in a maximum
likelihood estimation of the model with vary values for the smoothness
parameter. Finally, prior mass is only given to value of the smoothness
$\kappa$ corresponding to 0.5, 1.5, and 2.5 as the interest in estimating
$\kappa$ lies mainly in the differentiability of the sample paths of the
Gaussian process. This is an interesting possibility due to the use
of the matern correlation function.

A reference prior such as that proposed by @berger2001objective can
also be considered if objective priors are desired.

Note that in the expression for the density of the joint posterior, $\bbeta$
and $\tau^2$ can be integrated out. Furthermore, the posterior
distribution of $\tau^2$ conditioned on $\psi$ but marginalized over
$\bbeta$ can also be obtained in closed form. Similarly, the posterior
distribution of $\bbeta$ conditioned on $\tau^2$ and $\psi$ can be
obtained in closed form. The resulting full conditionals are:

\begin{align*}
\bbeta \mid \y, \tau^2, \psi &\sim \N(\hat\bbeta, \tau^2(\X^T V_\psi^{-1} \X)^{-1}) \\
\tau^2 \mid \y, \psi &\sim \IG\p{\frac{n-k}{2} + a_\tau, \frac{S^2_\psi}{2} + b_\tau} \\
p(\psi \mid \y) &\propto p(\psi)\times \abs{\V_\psi}^{-1/2}\abs{\X^T V_\psi^{-1} \X}^{-1/2} \times \\
                &\quad\quad (S^2_\psi/2 + b_\tau)^{-\frac{n-k}{2} - a_\tau}\\
\end{align*}
where $S^2_\psi = (\y - \X\hat\bbeta)^T (\X^T\V_\psi^{-1}\X)^{-1} (\y - \X\hat\bbeta)$
and $\hat\bbeta = (\X^T\V_\psi^{-1}\X)\X^T\V_\psi^{-1}\y$.

## Sampling from Joint Posterior
Sampling from the joint posterior can be done using standard MCMC techniques. 
Specifically, a Gibbs sampler can be used to iteratively update and sample
from the full conditional distribution of each parameter to obtain samples
from the joint posterior. However, care should be taken to avoid unnecessarily
evaluating the likelihood as it requires the inversion of an $n \times n$ matrix. 
An MCMC block sampling scheme where all parameters are updated simultaneously 
is therefore desirable (as it requires evaluating the likelihood only once per
MCMC iteration) and is outlined as follows.

Let $q(\bbeta, \tau^2, \psi) = p(\bbeta \mid \y, \tau^2, \psi) p(\tau^2 \mid
\y, \psi) q_\psi(\psi)$ be the proposal density used in the metropolis algorithm
where $q_\psi(\psi)$ is a (multivariate) proposal density for $\psi$.
Then if $\psi_c$ represents the current sample in the for $\psi$ in the MCMC
and $\psi_p$ represents the proposed one, then the acceptance probability is

$$\rho = \frac{p(\psi_p\mid \y) q_\psi(\psi_c)}{p(\psi_c\mid \y) q_\psi(\psi_p)}.$$

A computationally efficient execution of the metropolis step is then to 
(1) propose $\psi_p$ by sampling from $q_\psi(\cdot)$,
(2) accept the proposed state $\psi_p$ with probability $\rho$, and
(3) if the $\psi_p$ is accepted, then sample $\tau^2$ using $\psi_p$, 
and then sample $\bbeta$ using the new $\tau^2$ and $\psi_p$.
Note that with the appropriate transformation on $\psi_p$, a multivariate
proposal distribution centered on $\psi_c$ can be used. In that case,
$q_\psi$ is also cancelled from the expression. Note, however, that
when transformation on parameters are done, the prior densities need to be
multiplied by the appropriate Jacobian.

# Analysis

## Parameter Posterior Distributions
The posterior distribution of $\beta$ the parameters associated with the design
matrix are shown in Figure \ref{beta}. The posterior mean for the coefficient
corresponding to intercept, longitude, and log elevation are 223, 1.60, and
1.77 respectively.

![Posterior distribution of covariates $\beta$ representing an intercept term,
longitude, and log elevation. Diagonals are the univariate posterior
distributions. Upper triangle are the bivariate distributions. Lower triangle
shows the posterior correlation between parameters.](img/beta.pdf){id='beta'}

The posterior distribution of $\psi$ is summarizes in Figure \ref{psi}.  The
posterior mean for the range $\phi$, nugget $\tau^2$, and covariance scale
$\sigma^2$ are 0.826, 8.85, and 19.0 respectively. These results are similar
to those obtained using maximum-likelihood estimation.

![Posterior distribution of $\psi$ representing range $\phi$,
nugget $\tau^2$, and covariance scale $\sigma^2$.](img/psi.pdf){id='psi'}

The table below summarizes the posterior distribution of the 
smoothness parameter $\kappa$.
\input{img/kappa_mat.tex}
A smoothness of $\kappa = 2.5$ appears to be most likely. This suggests that
most likely, the resulting Gaussian process has sample paths that are
twice differentiable.

## Model Fit
To assess model fit, Figure \ref{qq} shows the posterior predictive means
with 95% credible intervals, plotted against the corresponding observed 
ozone levels. A coverage of 98% is obtained and the model seems to model
the data well, with slight exceptions at the tails of the distribution.

![Posterior predictive means (with 95% credible intervals) vs observed ozone
levels.](img/qq.pdf){id='qq'}

Figure \ref{resid} provides the residuals by location, computed as the posterior
predictive mean minus the observed ozone level at each location. 
No obvious trends can be observed in the residuals, indicating good model fit.

![Residuals by location.](img/resid.pdf){id='resid'}

# Conclusions
Modeling ozone levels with a Gaussian process Bayesian model containing a trend
component and a matern correlation function to model the spatial correlation
yields promising model fit. Using relatively uninformative priors for model
parameters and making use of an auxiliary variable to model smoothness
parameter seem to yield parameter estimates comparable to that of the MLE's.
Future work would be to include predictions of the ozone levels at new
locations. This requires information about the new locations' elevation, and so
was not included in the study.

# References

[comment]: <> (%
  These are comments
%)
