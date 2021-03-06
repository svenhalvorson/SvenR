% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/round_per.R
\name{round_per}
\alias{round_per}
\title{Round Percents}
\usage{
round_per(x, digits = 1)
}
\arguments{
\item{x}{A numeric vector}

\item{digits}{The number of digits to round to}
}
\description{
Rounds 100*x, formats to desired number of digits
}
\examples{
round_per(c(0.5, 0.6789, 1.0241))
}
