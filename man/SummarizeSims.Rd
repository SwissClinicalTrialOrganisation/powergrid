% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/powergrid.R
\name{SummarizeSims}
\alias{SummarizeSims}
\title{Summary of object that has simulations saved.}
\usage{
SummarizeSims(x, summary_function, ...)
}
\arguments{
\item{x}{Object of class \code{power_array}}

\item{summary_function}{function to apply across simulations}

\item{...}{Further arguments passed to 'summary_function'}
}
\value{
An object of class \code{power_array}, with attributes \code{summarized =
  TRUE}.
}
\description{
Summarizes objects of class \code{power_array} that have individual
simulations saved across simulations.
}
\author{
Gilles Dutilh
}
