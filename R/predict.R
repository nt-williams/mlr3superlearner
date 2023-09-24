#' Predict method for \code{mlr3superlearner} object
#'
#' @param object [\code{mlr3superlearner}]\cr
#'  An object returned from \code{mlr3superlearner()}.
#' @param newdata data [\code{data.frame}]\cr
#'  A \code{data.frame} containing predictors.
#' @param ... Unused.
#'
#' @return A vector of the predicted values.
#' @exportS3Method
#'
#' @seealso \code{\link{mlr3superlearner}}
#'
#' @examples
#' if (requireNamespace("ranger", quietly = TRUE)) {
#'   n <- 1e3
#'   W <- matrix(rnorm(n*3), ncol = 3)
#'   A <- rbinom(n, 1, 1 / (1 + exp(-(.2*W[,1] - .1*W[,2] + .4*W[,3]))))
#'   Y <- rbinom(n,1, plogis(A + 0.2*W[,1] + 0.1*W[,2] + 0.2*W[,3]^2 ))
#'   tmp <- data.frame(W, A, Y)
#'   fit <- mlr3superlearner(tmp, "Y", c("glm", "ranger"), outcome_type = "binomial")
#'   predict(fit, tmp)
#' }
predict.mlr3superlearner <- function(object, newdata, ...) {
  .f <- ifelse(object$outcome_type == "continuous",
               function(x, data) x$predict_newdata(data)$response,
               function(x, data) x$predict_newdata(data)$prob[, "1"])
  if (object$discrete) {
    out <- .f(object$learners[[1]], newdata[, object$x, drop = F])
    return(out)
  }
  z <- lapply(object$learners, .f, newdata[, object$x, drop = F])
  z <- matrix(Reduce(`c`, z), ncol = length(object$learners))
  colnames(z) <- unlist(lapply(object$learners, function(x) x$id))
  weights <- object$weights
  use <- names(weights[weights != 0])
  crossprod(t(z[, use, drop = FALSE]), weights[use])[, 1]
}
