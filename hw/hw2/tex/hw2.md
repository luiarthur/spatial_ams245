---
title: "HW2 - Spatial Statistics"
author: Arthur Lui
date: " 2 May 2017"
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
    # Commands for this project
    - \newcommand{\F}{\mathcal{F}}
    - \newcommand{\K}{\mathcal{K}}
---

[comment]: <> (%
  These are comments
%)

**1. Prove the results about the smoothness of the members of the Matern family.**

???

**2. Use the spectral representation to show that the product of two valid
correlation functions is a valid correlation function.**

Let $\F$ be the Fourier transform operator, and $\F^{-1}$ be the inverse 
Fourier transform operator.  Then by the convolution theorem,

$$
\F^{-1}\bc{\F(f) \F(g)} = f * g = \int_{-\infty}^\infty f(t)g(k-t)dt.
$$

To show that $\rho(\tau) = \rho_1(\tau)\rho_2(\tau)$ is a valid
correlation function, where $\rho_1(\tau)$ and $\rho_2(\tau)$ are 
valid correlation functions, we need to show that 
$\F^{-1}\bc{\rho(\tau)} = f(k)$ is non-negative.

Let $f_1(k)$ and $f_2(k)$ be the spectral densities corresponding to
$\rho_1(\tau)$ and $\rho_2(\tau)$ respectively. Then,

\begin{align*}
\F^{-1}\bc{\rho(\tau)} &= \F^{-1}\bc{\rho_1(\tau) \rho_2(\tau)}  \\
&= \F^{-1}\bc{\F\bc{f_1(k)} \F\bc{f_2(k)}} \\
&= f_1(k) * f_2(k) &\text{(convolution theorem)} \\
&= \int_{-\infty}^\infty f_1(t) f_2(k-t) dt \\
&\ge 0.
\end{align*}

The last inequality holds because $f_1(t) \ge 0$ and $f_2(t) \ge 0$ 
for all $t$.

**3. The spectral density of a correlation in the Matern family has tails whose
thickness depends on the smoothness parameter. Conjecture: the smoothness of
the corresponding random field depends on the number of moments of the spectral
density. What can you say about this conjecture?**

For the Matern family of correlation functions, 

$$
\begin{cases}
\rho(\tau) \propto (a\tau)^\nu \K_\nu(a\tau) \\
f(x) \propto (x^2 + a^2)^{-\nu-n/2} \\
\end{cases}
$$

So, the $k^{th}$ moment of the spectral density can be computed as:

\begin{align*}
\E\bk{X^k} &= \int_{-\infty}^\infty x^k f(x) ~dx \\
&\propto \int_{-\infty}^\infty x^k (a^2 + x^2)^{-\nu-n/2} ~dx \\
&\propto \int_{-\infty}^\infty (a^2 + x^2)^{-\nu-n/2} ~dx^{k+1} \\
&\propto \frac{x^{k+1}}{(a^2+x^2)^{\nu+n/2}} \Bigm|_{-\infty}^\infty -
\int_{-\infty}^\infty x^{k+1} ~d(a^2+x^2)^{-\nu-n/2} \\
&\propto \frac{x^{k+1}}{(a^2+x^2)^{\nu+n/2}} \Bigm|_{-\infty}^\infty +
(\nu+\frac{n}{2})\int_{-\infty}^\infty x^{k+1} (a^2+x^2)^{-\nu-n/2-1} ~dx \\
\end{align*}

The first term in the last expression is only finite when 

$$
\begin{split}
k+1 &\le \nu+\frac{n}{2}\\
\Rightarrow
\nu &\ge \frac{k-n+1}{2} \\
\end{split}
$$

This is also true for the second term.

Therefore, the $k^{th}$ moment exists when $\nu \ge \frac{k-n+1}{2}$.
This inequality tells us that the smoothness increases with the number of
moments of the spectral density.

**4.  Use the K-L representation to approximate the exponential correlation for
range parameter equal to 1. Plot the approximation for several orders and
compare to the actual correlation.**

**5. Repeat for the approximation given on Page 13 of the fifth set of
slides.**

**6. Generate 100 realizations of a univariate Gaussian process with
exponential correlation with range parameter 1. Compare the empirically
estimated eigenvalues and eigenfunctions to the ones given by the K-L and the
approximation on Page 12.**
