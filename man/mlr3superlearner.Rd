% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mlr3superlearner.R
\name{mlr3superlearner}
\alias{mlr3superlearner}
\title{Super Learner Algorithm}
\usage{
mlr3superlearner(
  data,
  target,
  library,
  metalearner,
  outcome_type = c("binomial", "continuous"),
  folds = 10L,
  newdata = NULL,
  group = NULL,
  info = FALSE
)
}
\arguments{
\item{data}{[\code{data.frame}]\cr
A \code{data.frame} containing predictors and target variable.}

\item{target}{[\code{character(1)}]\cr
The name of the target variable in \code{data}.}

\item{library}{[\code{character}]\cr
A vector of algorithms to be used for prediction.}

\item{metalearner}{[\code{character(1)}]\cr}

\item{outcome_type}{[\code{character(1)}]\cr
The outcome variable type.}

\item{folds}{[\code{numeric(1)}]\cr
The number of cross-validation folds.}

\item{newdata}{[\code{list}]\cr
A \code{list} of \code{data.frames} to generate predictions from.}

\item{group}{[\code{character(1)}]\cr
Name of a grouping variable in \code{data}. Assumed to be discrete;
observations in the same group are treated like a "block" of observations
kept together during sample splitting.}

\item{info}{[\code{logical(1)}]\cr
Print learner fitting information to the console.}
}
\value{
A list of class \code{mlr3superlearner}.
}
\description{
Implementation of the Super Learner algorithm using the `mlr3` framework.
}
\examples{
library(mlr3superlearner)
n <- 1e3
W <- matrix(rnorm(n*3), ncol = 3)
A <- rbinom(n, 1, 1 / (1 + exp(-(.2*W[,1] - .1*W[,2] + .4*W[,3]))))
Y <- rbinom(n,1, plogis(A + 0.2*W[,1] + 0.1*W[,2] + 0.2*W[,3]^2 ))
tmp <- data.frame(W, A, Y)
fit <- mlr3superlearner(tmp, "Y", c("glm", "glmnet"), "glm", "binomial")
predict(fit, tmp)
}
