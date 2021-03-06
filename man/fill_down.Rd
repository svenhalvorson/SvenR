% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fill_down.R
\name{fill_down}
\alias{fill_down}
\title{Fill Down}
\usage{
fill_down(x, empty_string = FALSE, reverse = FALSE)
}
\arguments{
\item{x}{An atomic vector}

\item{empty_string}{Should empty strings be treated as NA?}

\item{reverse}{Should we fill up instead?}
}
\description{
Fill missing value with most recent non-missing value
}
\examples{
NM = c(NA, 'Ruidoso', NA, '', NA, 'Corona', NA, 'Roswell')
fill_down(NM)
fill_down(NM, empty_string = TRUE)
fill_down(NM, reverse = TRUE)
}
\author{
Sven Halvorson
}
