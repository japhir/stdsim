% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calibration.R
\name{tempcal}
\alias{tempcal}
\title{Temperature calibration}
\usage{
tempcal(
  Tc,
  slope = 0.0449,
  intercept = 0.167,
  slpcnf = 0.001,
  intcnf = 0.01,
  ignorecnf = FALSE
)
}
\arguments{
\item{Tc}{The temperature in °C.}

\item{slope}{The slope of the regression.}

\item{intercept}{The intercept of the regression.}

\item{slpcnf}{The confidence of the slope of the regression.}

\item{intcnf}{The confidence of the intercept of the regression.}

\item{ignorecnf}{Whether or not to ignore the confidence interval.}
}
\value{
A \link[tibble:tibble-package]{tibble} with input Tc and estimated
\eqn{\Delta_{47}}{Δ[47]} value with lower and upper bounds.
}
\description{
A clumped isotope temperature calibration of the form: y = a * 10^6 / T^2 + b
}
\details{
Defaults to Bonifacie et al. 2017
\eqn{\Delta_{47}}{Δ[47]} = (0.0449 ± 0.001 * 10^6) / T^2 + (0.167 ± 0.01)
}
\seealso{
revcal
}
