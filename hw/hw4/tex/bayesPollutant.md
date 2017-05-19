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
    - \newcommand{\y}{\mathrm{\mathbf{y}}}
    - \newcommand{\R}{\mathrm{\mathbf{R}}}
    - \newcommand{\bbeta}{\bm{\beta}}
    - \newcommand{\X}{\mathrm{\mathbf X}}
    - \newcommand{\w}{\bm{w}}
    - \newcommand{\bmu}{\bm{\mu}}
    - \newcommand{\s}{\bm{s}}
    - \newcommand{\zero}{\bm{0}}
    - \newcommand{\IG}{\text{IG}}
    - \newcommand{\Unif}{\text{Unif}}
include-before:
- \title{Bayesian Analysis of Pollutants Data}
- \author{Arthur Lui \\ AMS 245 - Spatial Statistics \\ UC Santa Cruz \\\\ \today}
- \maketitle
---

\abstract{
  \keywords{}
}

# Introduction

# Data

# Exploratory Data Analysis

# Methods

## Model
$$
\begin{split}
\y(\s) &= \bmu(\s) + \bm\epsilon \\
\bmu(\s) &= \X(\s)\bbeta + \w(\s) \\
\end{split}
$$

Let $\psi$ be $(\nu, \kappa, \phi)$, the parameters in the covariance function.
$$
\begin{split}
\y \mid \bmu, \tau^2 &\sim \N_n(\bmu, \tau^2 \I)\\
\bmu \mid \bbeta, \psi, \sigma^2 &\sim \N_n(\X\bbeta, \sigma^2 \R_\psi) \\
\end{split}
$$

The collapsed model with the accompanying priors are:
$$
\begin{split}
\y \mid \tau^2, \sigma^2, \psi, \bbeta &\sim 
\N_n(\X\bbeta, \tau^2 \I + \sigma^2\R_\psi)\\
%%%
\tau^2 &\sim \IG(a_\tau,b_\tau) \\
\sigma^2 &\sim \IG(a_\sigma,b_\sigma) \\
p(\bbeta) &\propto 1\\
\\
\psi:\\
\phi   &\sim \Unif(a_\phi, b_\phi) \\        % 0   - 10
\nu    &\sim \Unif(a_\nu,  b_\nu) \\         % 1.5 - 2.5
\end{split}
$$



# Analysis

## Model Fit

# Conclusions
DUMMY REFERENCE @rasmussen2006gaussian

# References


[comment]: <> (%
  These are comments
%)


