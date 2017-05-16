---
title: "Title"
author: Arthur Lui
date: "16 May 2017"
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
---

For this assignment, I used the annual summary data from 2015 for
the state of California. The state had 135 unique monitoring stations
with the parameters of interest, namely 

- `Parameter Name` = "Ozone"
- `Sample Duration` = "8-HR RUN AVG BEGIN HOUR"
- `Pollutant Standard` = "Ozone 8-Hour 2008"
- `Event Type` is one of "No Events", "Concurred Events Excluded", or "Events Excluded", and
- `Completeness.Indicator` = "Y".

[comment]: <> (%
  I also only included data with `Elevation` > 10. Mostly for convenience.
%)

**3. Based on graphical exploration, is there evidence of a first or second
order trend function of location and altitude? Is there evidence that a
transformation is needed in order to make the data closer to normality?**

From Figure \ref{lcmeans}, some type of trend is clearly present between
location and county means.

![log county means](img/logCountyMeans.pdf){ id='lcmeans' height=50%}

Figure \ref{mypairs} displays the bivariate relationships of the data.
Specifically, the county ozone means, latitude, longitude, 
and log elevation (altitude) are examined. These variables are linearly
related. So a first order trend should be assumed between the variables
and the response. Note that the correlation between latitude and 
longitude is quite strong (-.835) and they are linearly related as well.
So, only including one of the two variables in detrending the data may
suffice.

![Pairs plot of data.](img/mypairs.pdf){ id='mypairs' height=50%}

**4. Obtain the residuals after fitting the trend function resulting from the previous question, if any. Plot the variogram. Explore possible anisotropies using a directional variogram.**

The pairs plot for the detrended data (the residuals) is plotted again in
Figure \ref{detrendedPairs}. The histogram of the responses 
(left top corner) appears more Normal. And the trends between variables
and the response seem to have mostly disappeared.

![Detrended observations](img/detrendedPairs.pdf){ id='detrendedPairs' height=50%}

The variograms for the data are included in Figure \ref{vario}. Note
that the top panel is plotted before detrending the data while the 
lower panel is plotted after detrending. Both plots explore
possible anisotropies using directional variograms. 
The directional variograms do not indicate any obvious geometric 
anisotropies. But there appears to be evidence for a nugget effect. 

![Variograms](img/vario.pdf){ id='vario' height=50%}

**5. Use least squares to fit the covariograms in the Matern family with smoothness equal to .5; 1; 1.5; 2.5. Plot the results. Use the plots and the values of the LSE to select the best fit.**

The covariograms in the Matern family are fit with different smoothness
and are shown in Figure \ref{covario}. The model with $\kappa=2$ appears
to have the smallest sum of squared loss (42950). The estimated
nugget for that model is $\hat\tau^2=3.3875$, with $\hat\sigma^2=19.51$ and
range $\hat\phi = 0.3206$.

![Covariograms](img/covario.pdf){ id='covario' }

**6. Plot the likelihood function for the sill and the range corresponding to each of the correlations in the previous point. If a nugget is needed, you can plug an estimated value.**

Figure \ref{marginal1} shows the marginal likelihood for $\sigma^2, \phi$.
The maximum likelihood estimators are similarly in value to those
estimated previously. 

![Variance and range loglikelihood](img/marginalSig2Range.pdf){ id='marginal1' height=50% }

**7. Plot the marginal likelihood for the range parameter for each of the examples above.**

Figure \ref{philike} shows the marginal likelihood for $\phi$, the
ratio $\tau^2 / \sigma^2$ was fixed to be the ratio of the fitted values. 
The marginal MLE for the $\phi$'s are again similar to those estimated
before. However, it is reasonable for the marginal estimates to deviate 
from the multivariate MLE's because.

![Marginal Likelihood for $\phi$ ](img/philike.pdf){ id='philike' height=50%}

[comment]: <> (% example image embedding
> ![some caption.\label{mylabel}](path/to/img/img.pdf){ height=70% }
%)


